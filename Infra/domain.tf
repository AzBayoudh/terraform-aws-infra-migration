# 1. READ: Find the Hosted Zone (Address Book) created by AWS
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# 2. CREATE: Request the Certificate (The Application)
resource "aws_acm_certificate" "site_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = ["www.${var.domain_name}"]

    lifecycle {
        create_before_destroy = true
    }
}

# 3. CONFIGURE: The Robot (Write the Secret Password to DNS)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : dvo.domain_name => dvo
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# 4. WAIT: Pause Terraform until AWS approves the ID Badge
resource "aws_acm_certificate_validation" "cert_validate" {
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 5. THE CONNECTION: Point the Domain to CloudFront
# This tells the "GPS" to send traffic to the CloudFront Bouncer.

# A. For "azizaws.com"
resource "aws_route53_record" "root_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A" # "A" record usually means IP address, but AWS allows Aliases

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# B. For "www.azizaws.com"
resource "aws_route53_record" "www_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}