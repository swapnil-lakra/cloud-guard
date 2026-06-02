# lambda / index.py

import boto3
import os
import json
import uuid
from datetime import datetime, timezone

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context) :
    account_id = boto3.client('sts').get_caller_identity()['Account']
    findings = []
    
    # Scan S3 buckets
    try :
        findings.extend(check_s3_buckets(account_id))
    except Exception as e :
        print(f"Error scanning S3: {e}")
        
    # Scan Security Groups
    try :
        findings.extend(check_security_groups(account_id))
    except Exception as e :
        print(f"Error scanning S3: {e}")
        
    # Scan IAM users (console MFA)
    try :
        findings.extend(check_iam_users(account_id))
    except Exception as e :
        print(f"Error scanning IAM : {e}")
    
    # Store all fidings in DynamoDB
    for item in findings :
        table.put_item(Item=item)
        print(f"Stored findings : {item['finding_id']} - {item['severity']}")
    
    # Publish high severity findings to SNS
    high_findings = [f for f in findings if f['severity'] == 'HIGH']
    if high_findings :
        sns_topic_arn = os.environ['SNS_TOPIC_ARN']
        if sns_topic_arn :
           sns_client = boto3.client('sns')
           message = f"CloudGuard Alert: {len(high_findings)} high severity findings detected. \n\n"
           for hf in high_findings:
               message += f"- [{hf['resource_type']}] {hf['details']}\n"
           sns_client.publish(
               TopicArn=sns_topic_arn,
               Subject="CloudGuard High Severity Alert",
               Message=message
           )
           print("Published SNS alert for high severity findings")
        else :
            print("SNS_TOPIC_ARN not set, skipping SNS alert")
    
    return {
        'statusCode' : 200,
        'body' : json.dumps(f"Inserted {len(findings)} findings")
    }
    
def check_s3_buckets(account_id) :
    s3 = boto3.client('s3')
    buckets = s3.list_buckets()['Buckets']
    findings = []
    for bucket in buckets :
        bucket_name = bucket['Name']
        public = False
        reason = ""
        # Check PublicAccessBlock
        try :
            pab = s3.get_public_access_block(Bucket=bucket_name)
            config = pab['PublicAccessBlockConfiguration']
            if not (config.get('BlockPublicAcls', False) and
                    config.get('IgnorePublicAcls', False) and
                    config.get('BlockPublicPolicy', False) and
                    config.get('RestrictPublicBuckets', False)) :
                public = True
                reason = "PublicAccessBlock not fully enabled"
        except s3.exceptions.ClientError as e :
            if e.response['Error']['Code'] == 'NoSuchPublicAccessBlockConfiguration' :
                public = True
                reason = "No PublicAccessBlock configured"
            else :
                print(f"Error getting PAB for {bucket_name} : {e}")
                continue 
        
        # Check bucket policy status
        if not public :
            try :
                policy_status = s3.get_bucket_policy_status(Bucket=bucket_name)
                if policy_status['PolicyStatus']['IsPublic'] :
                    public = True
                    reason = "Bucket policy allows public access"
            except s3.exceptions.ClientError as e :
                if e.response['Error']['Code'] != 'NoSuchBucketPolicy' :
                    print(f"Error getting policy status for {bucket_name} : {e}")
        
        if public :
            findings.append(create_finding(
                account_id, 'S3', bucket_name, 'public_bucket',
                severity='HIGH',
                details=f"S3 bucket {bucket_name} is public {reason}"
            ))
    
    return findings

def check_security_groups(account_id) :
    ec2 = boto3.client('ec2')
    sgs = ec2.describe_security_groups()['SecurityGroups']
    findings = []
    dangerous_ports = {22:'SSH',3389:'RDP',3306:'MySQL',5432:'PostgresSQL',27017:'MongoDB'}
    
    for sg in sgs :
        for perm in sg.net('IpPermissions',[]):
            for ip_range in perm.get('IpRanges',[]):
                if ip_range.get('CidrIp') == '0.0.0.0/0':
                    from_port = perm.get('FromPort',-1)
                    to_port = perm.get("ToPort",-1)
                    if from_port == -1 and to_port == -1:
                        severity = 'HIGH'
                        details = f"Security Group {sg['GroupId']} open all ports to 0.0.0.0/0"
                    
                    elif from_port in dangerous_ports or to_port in dangerous_ports :
                        severity = 'HIGH'
                        details = f"Security Group {sg['GroupId']} open dangerous port {from_port} to 0.0.0.0/0"
                    
                    else :
                        severity = 'MEDIUM'
                        details = f"Security Group {sg['GroupId']} open port range {from_port}-{to_port} to 0.0.0.0/0"
                        
                    findings.append(create_finding(
                        account_id, 'SecurityGroup', sg['GroupId'], 'open_world',
                        severity=severity,
                        details=details
                    ))
                    break
    return findings

def check_iam_users(account_id) :
    iam = boto3.client("iam")
    users = iam.list_users()['Users']
    findings = []
    for user in users :
        user_name = user['UserName']
        try :
            login = iam.get_login_profile(UserName=user_name)
            # user has console access
            mfa_devices = iam.list_mfa_devices(UserName=user_name)['MFADevices']
            if not mfa_devices :
                findings.append(create_finding(
                    account_id, 'IAMUser', user_name, 'no_mfa_console',
                    severity='HIGH',
                    details=f"IAM user {user_name} has console access but no MFA devices"
                ))
        except iam.exceptions.NoSuchEntityException :
            # no login profile means no console access, skip
            pass
        return findings
    
def create_finding(account_id, resource_type, resource_id, check_type, severity, details) :
    return {
        'account_id' : account_id,
        'finding_id' : f"{resource_type}-{resource_id}-{check_type}",
        'resource_type' : resource_type,
        'resource_id' : resource_id,
        'check_type' : check_type,
        'severity' : severity,
        'details' : details,
        'timestamp' : datetime.now(timezone.utc).isoformat()
    }