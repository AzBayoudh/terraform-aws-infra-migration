resource "aws_iam_role" "lambda_existing_role" {
  name = "CloudResumeTestAPI-role-ov1jrjsq"
  path = "/service-role/"


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

resource "aws_iam_role_policy" "dynamo_api_access_inline" {
  name = "Dynamo_API_Access"
  role = aws_iam_role.lambda_existing_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:PutItem"]
      Resource = "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/CloudResumeTest"
    }]
  })
}


#  Managed policy attachment (customer-managed) that my CLI listed as attached
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attached" {
  role       = aws_iam_role.lambda_existing_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/service-role/AWSLambdaBasicExecutionRole-6b01225b-0039-44ea-b4d9-64aa5911f9b1"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_attached" {
  role       = aws_iam_role.lambda_existing_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

