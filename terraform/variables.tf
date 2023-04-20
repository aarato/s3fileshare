variable "name" {
  # default="MyAwesomeUniqeS3BucketName"
  type = string
  description = "Unique AWS S3 bucket name that is also used as a prefix for ALL resource names created by Terraform."
}

variable "s3folder" {
  default="files"
  type = string
  description = "S3 folder name where secured files are to be stored"
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

# Application definition

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "app_environment" {
  type        = string
  description = "Application environment"
}
