provider "aws" {
  region = "us-east-1"
}


resource "aws_iam_role" "lambda_existing_role" {
  name = "CloudResumeTestAPI-role-ov1jrjsq"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_existing_inline_policy" {
  name = "lambda_inline_policy"
  role = aws_iam_role.lambda_existing_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/CloudResumeTest"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/main.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "existing_lambda_function" {
  function_name    = "CloudResumeTestAPI"
  role             = aws_iam_role.lambda_existing_role.arn
  handler          = "main.handler"
  runtime          = "python3.13"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}



