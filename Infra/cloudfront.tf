# 1. THE SECURITY KEY (Origin Access Control)
# This creates a special key that only CloudFront holds.
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "security-key-for-s3"
  description                       = "Allow CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. THE BOUNCER (CloudFront Distribution)
resource "aws_cloudfront_distribution" "s3_distribution" {
  
  # A. The Origin (Where the files live)
  origin {
    domain_name              = "${var.bucket_name}.s3.amazonaws.com"
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  # B. General Settings
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html" # The file to show when users visit "/"

  # C. The ID Badge (Connect the ACM Certificate)
  aliases = [var.domain_name, "www.${var.domain_name}"]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # D. Behavior (How to handle visitors)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    # Forward query strings? No (Creating a static site)
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Redirect insecure HTTP to HTTPS
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # E. Restrictions (Who can visit?)
  restrictions {
    geo_restriction {
      restriction_type = "none" # Open to the world
    }
  }
}

# 3. THE S3 BUCKET POLICY (The Lock on the Door)
# This updates your S3 bucket to say: "Only open for the CloudFront Key"
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = var.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${var.bucket_name}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}



