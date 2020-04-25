variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

locals {
  site_name = "www.dailywombat.com"

  tags = {
    site = "dailywombat"
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "daily-wombat-terraform-state"
    key    = "main"
    dynamodb_table = "tf_state_lock"
    region = "us-west-2"
  }
}

data "external" "cert_request" {
  program = ["bash", "./request_cert.sh"]

  query = {
    site_name = "${local.site_name}"
  }
}

resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.site_name}"
  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_route53_zone" "site_zone" {
  name = "${var.site_name}"
}

resource "aws_route53_record" "site_cname" {
  zone_id = "${aws_route53_zone.site_zone.zone_id}"
  name = "${var.site_name}"
  type = "NS"
  ttl = "30"

  records = [
    "${aws_route53_zone.site_zone.name_servers.0}",
    "${aws_route53_zone.site_zone.name_servers.1}",
    "${aws_route53_zone.site_zone.name_servers.2}",
    "${aws_route53_zone.site_zone.name_servers.3}"
  ]
}

resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.site_bucket.bucket_domain_name}"
    origin_id = "${var.site_name}-origin"
  }

  enabled = true
  aliases = ["${var.site_name}"]
  price_class = "PriceClass_100"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS",
                        "PATCH", "POST", "PUT"]

    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.site_name}-origin"

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
    acm_certificate_arn = "${data.external.cert_request.result.CertificateArn}"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
