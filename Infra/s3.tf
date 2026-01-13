resource "aws_s3_bucket" "existing_cloud_resume_bucket" {
  bucket = "azizaws.com"

  lifecycle {
   prevent_destroy = true
  }
}       

resource "aws_s3_bucket_website_configuration" "cloud_resume_site" {
  bucket = aws_s3_bucket.existing_cloud_resume_bucket.id


  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "cloud_resume_bucket_versioning" {
  bucket = aws_s3_bucket.existing_cloud_resume_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloud_resume_bucket_public_access" {
  bucket = aws_s3_bucket.existing_cloud_resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "cloud_resume_bucket_policy" {
  bucket = aws_s3_bucket.existing_cloud_resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::azizaws.com/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::azizaws.com/lambda/*"
      }
    ]
  })
}
