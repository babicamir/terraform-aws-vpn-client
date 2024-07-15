# AWS S3 bucket for VPN config files
resource "aws_s3_bucket" "vpn-config-files" {
  bucket        = "${lower(var.project-name)}-${var.environment}-vpn-config-files"
  force_destroy = true
  tags = (merge(var.tags,
    { Name = "${lower(var.project-name)}-${var.environment}-vpn-config-files" },
    { CostType = "AlwaysCreated" },
    { BackupPolicy = "n/a" },
  ))
}
resource "aws_s3_bucket_public_access_block" "vpn-config-files" {
  bucket                  = aws_s3_bucket.vpn-config-files.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "vpn-config-files" {
  bucket = aws_s3_bucket.vpn-config-files.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = ""
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = false
  }
}
resource "aws_s3_bucket_policy" "vpn-config-files" {
  bucket = aws_s3_bucket.vpn-config-files.id
  policy = data.aws_iam_policy_document.vpn-config-files.json
}
data "aws_iam_policy_document" "vpn-config-files" {
  statement {
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${lower(var.project-name)}-${var.environment}-vpn-config-files",
      "arn:aws:s3:::${lower(var.project-name)}-${var.environment}-vpn-config-files/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}