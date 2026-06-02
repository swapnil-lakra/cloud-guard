import os
import json
import boto3
from flask import Flask, jsonify
from prometheus_client import make_wsgi_app, Gauge, CollectorRegistry, generate_latest, CONTENT_TYPE_LATEST
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from dotenv import load_dotenv



app = Flask(__name__)
load_dotenv()

# DynamoDB Table name from env
TABLE_NAME = os.environ.get('FINDINGS_TABLE', 'cloudguard-findings')

#Prometheus metrics
registry = CollectorRegistry()
finding_total = Gauge('cloudguard_findings_total', 'Total number of findings', ['severity'], registry=registry)
cost_savings = Gauge('cloudguard_total_estimated_savings','Total estimated monthly savings in USD', registry=registry)

try:
    dynamodb = boto3.resource('dynamodb', region_name=os.environ.get('AWS_DEFAULT_REGION','ap-south-1'))
    table = dynamodb.Table(TABLE_NAME)
    table.load()
except Exception as e:
    print(f"❌ Error connecting to DynamoDB: {e}")
    table = None

def get_findings():
    if not table:
        return []
    
    try:
        findings = []
        response = table.scan()
        findings.extend(response.get('Items', []))

        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            findings.extend(response.get('Items', []))
        return findings
    except Exception as e:
        print(f"❌ Error scanning DynamoDB: {e}")
        return []

@app.route('/')
def home() : 
    return jsonify({"service": 'CloudGuard API', "status":"running"})

@app.route('/health')
def health() :
    return jsonify({"status": "healthy"})   

@app.route('/findings')
def findings() :
    items = get_findings()
    return jsonify(items)

@app.route('/metrics')
def metrics() :
    items = get_findings()
    severity_counts = {}
    total_savings = 0.0
    for item in items:
        sev = item.get('severity', 'UNKNOWN')
        severity_counts[sev] = severity_counts.get(sev, 0) + 1
        savings_str = item.get('estimated_savings')
        if savings_str:
            try:
                total_savings += float(savings_str)
            except:
                pass

    for sev, count in severity_counts.items():
        finding_total.labels(severity=sev).set(count)
    finding_total.labels(severity='ALL').set(len(items))
    cost_savings.set(total_savings)
    return generate_latest(registry), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
