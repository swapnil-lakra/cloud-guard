resource "aws_kms_key" "cloudguard" {
    description = "Cloudguard KMS key for encryption"
    deletion_window_in_days = 7
    enable_key_rotation = true

    tags = {
        Name = "${var.project_name}-kms-key"
    }
}

resource "aws_kms_alias" "cloudguard" {
    name = "alias/${var.project_name}-key"
    target_key_id = aws_kms_key.cloudguard.id
}