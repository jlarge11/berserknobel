variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  site_name = "dailywombat"
  domain = "${local.site_name}.com"

  tags = {
    site = local.site_name
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-west-1"
}

terraform {
  backend "remote" {
    organization = "dailywombat"

    workspaces {
      prefix = "site-"
    }
  }
}

resource "aws_route53_zone" "site_zone" {
  name = local.domain
  tags = local.tags
}

resource "aws_route53_record" "site_dns_record" {
  zone_id = aws_route53_zone.site_zone.zone_id

  name = local.domain
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.site_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "site_bucket" {
  bucket = local.domain
  tags = local.tags
  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

data "terraform_remote_state" "cert" {
  backend = "remote"

  config = {
    organization = local.site_name

    workspaces = {
      name = "cert-prod" # or cert-${var.environment} and set environment in TF cloud
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for dailwombat.com"
}

data "aws_iam_policy_document" "site_bucket_iam_policy_doc" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.site_bucket_iam_policy_doc.json
}

resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_domain_name
    origin_id = "${local.domain}-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  tags = local.tags
  enabled = true
  aliases = [local.domain]
  price_class = "PriceClass_100"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS",
                        "PATCH", "POST", "PUT"]

    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.domain}-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 1000
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.terraform_remote_state.cert.outputs.cert_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
