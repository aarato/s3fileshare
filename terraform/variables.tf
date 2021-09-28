variable "name" {
  # default="MyAwesomeUniqeS3BucketName"
  type = string
  description = "Unique AWS S3 bucket name that is also used as a prefix for ALL resource names created by Terraform."
}

variable "region" {
  default="us-east-1"
  type = string
  description = "AWS region to be used for the environment."
}

variable "password" {
  default="Admin123#"
  type = string
  description = "Default password for admin user."
}
