######################################################
# Terraform Module for S3 Static Website Hosting
######################################################
######################################################
# Variables
######################################################
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_document" {
  type    = string
  default = "error.html"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

######################################################
# Outputs
######################################################
output "bucket_name" {
  value = aws_s3_bucket.s3.bucket
}

output "website_endpoint" {
  value = aws_s3_bucket.s3.website_endpoint
}

######################################################
# Resources
######################################################
resource "aws_s3_bucket" "s3" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_website_configuration" "s3" {
  bucket = aws_s3_bucket.s3.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}
