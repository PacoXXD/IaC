locals {
  cname = "${var.subdomain}.${var.domain}"
}

# S3
resource "aws_s3_bucket" "s3" {
  bucket = "${var.name}"

  # acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["${var.allowed_origins}"]

    # expose_headers = ["ETag"]
    max_age_seconds = 3000
  }
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["${var.allowed_origins}", "http://localhost:8080"]

    # expose_headers = ["ETag"]
    max_age_seconds = 3000
  }
  logging {
    target_bucket = "${var.s3_access_log_bucket}"
    target_prefix = "${var.name}/"
  }
  lifecycle_rule = "${var.lifecycle_rule}"
}

# Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${format("%s cf access identity", var.name)}"
}

# CloudFront
resource "aws_cloudfront_distribution" "cf" {
  origin {
    domain_name = "${aws_s3_bucket.s3.bucket_regional_domain_name}"
    origin_id   = "${var.name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = "${compact(list(var.route53_enabled ? local.cname : ""))}"

  default_cache_behavior {
    target_origin_id       = "${var.name}"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }
  }

  price_class = "${var.price_class}"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_cert_arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

# CF to S3 access policy
data "aws_iam_policy_document" "policy_cf_s3" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  # statement {
  #   actions   = ["s3:ListBucket"]
  #   resources = ["${aws_s3_bucket.s3.arn}"]

  #   principals {
  #     type        = "AWS"
  #     identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
  #   }
  # }
}

resource "aws_s3_bucket_policy" "policy_s3" {
  bucket = "${aws_s3_bucket.s3.id}"
  policy = "${data.aws_iam_policy_document.policy_cf_s3.json}"
}

# Route 53
data "aws_route53_zone" "zone" {
  count = "${var.route53_enabled}"
  name  = "${var.domain}"
}

resource "aws_route53_record" "record" {
  # count = "${var.route53_enabled}"

  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${local.cname}"

  type = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cf.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cf.hosted_zone_id}"
    evaluate_target_health = false
  }
}
