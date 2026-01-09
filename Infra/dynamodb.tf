resource "aws_dynamodb_table" "cloud_resume_test_table" {
  name         = "CloudResumeTest"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = false

  tags = {
  project = "CloudResumeChallenge"
   
  }

}