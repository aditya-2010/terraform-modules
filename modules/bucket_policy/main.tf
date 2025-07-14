variable "bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "oai_iam_arn" {
  description = "OAI IAM ARN"
  type        = string
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [var.oai_iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_policy.json
}
