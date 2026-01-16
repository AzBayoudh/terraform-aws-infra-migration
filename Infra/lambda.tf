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

resource "aws_lambda_function_url" "existing_lambda_function_url" {
    function_name = aws_lambda_function.existing_lambda_function.function_name
    authorization_type = "NONE"

    cors {
        allow_origins = ["*"]
        allow_methods = ["GET"] # Keep it simple: just GET
    }

}

resource "aws_lambda_permission" "allow_public" {
  statement_id           = "AllowPublicURL"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.existing_lambda_function.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}