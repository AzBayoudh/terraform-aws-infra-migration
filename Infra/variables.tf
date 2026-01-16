#Domain variables
variable "domain_name" {
    default = "azizaws.com"
    description = "The domain name for the resume website"
    type = string
}

#s3 vairables
variable "bucket_name" {
    default = "azizaws.com"
    description = "The S3 bucket name storing frontend files for the resume website"
    type = string
}

#Lambda variables

