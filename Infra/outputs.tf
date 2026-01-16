output "lambda_url" {
  value = aws_lambda_function_url.existing_lambda_function_url.function_url
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.main.zone_id
}