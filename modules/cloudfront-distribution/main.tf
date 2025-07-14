######################################################
# Terraform Module: CloudFront Distribution
######################################################
######################################################
# Variables
######################################################
variable "s3_website_endpoint" {
  type        = string
  description = "S3 static website endpoint"
}

variable "aliases" {
  type        = list(string)
  description = "List of aliases for the CloudFront distribution"
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default root object for the CloudFront distribution"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "Price class for the CloudFront distribution"
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}

######################################################
# Outputs
######################################################
output "domain_name" {
  value = aws_cloudfront_distribution.website.domain_name
}

######################################################
# Resources
######################################################
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.s3_website_endpoint}"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  aliases             = var.aliases
  default_root_object = var.default_root_object
  price_class         = var.price_class

  origin {
    domain_name = var.s3_website_endpoint
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id = "s3-origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.tags
}
