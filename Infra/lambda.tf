data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/main.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "existing_lambda_function" {
  function_name = "CloudResumeTestAPI"
  description   = "Resume Web Page API for view counter (Terraform-managed)"
  role          = aws_iam_role.lambda_existing_role.arn

  handler = "main.handler"
  runtime = "python3.13"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}