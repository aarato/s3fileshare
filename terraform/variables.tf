variable "name" {
  default=""
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
  default = ""
  type = string
  description = "Default password for admin user."
}

resource "random_string" "password" {
  length           = 16
  special          = false
}

resource "random_string" "name" {
  length           = 8
  upper          = false
  lower          = false
  special        = false
  numeric        = true
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

locals {
  name                                   = var.name != "" ? var.name : random_string.name.result
  password                               = var.password != "" ? var.password : random_string.password.result
  cognito_change_pass_name               = "${lower(local.name)}-${lower(var.app_environment)}-cognito_change_pass"
  cognito_change_pass_source_dir         = "${path.module}/aws_lambda_functions/cognito_change_pass"
  cognito_change_pass_zip_file           = "${path.module}/aws_lambda_functions/${local.cognito_change_pass_name}.zip"
  cognito_activate_guest_name            = "${lower(local.name)}-${lower(var.app_environment)}-cognito_activate_guest"
  cognito_activate_guest_source_dir      = "${path.module}/aws_lambda_functions/cognito_activate_guest"
  cognito_activate_guest_zip_file        = "${path.module}/aws_lambda_functions/${local.cognito_activate_guest_name}.zip"
  cognito_deactivate_guest_name            = "${lower(local.name)}-${lower(var.app_environment)}-cognito_deactivate_guest"
  cognito_deactivate_guest_source_dir      = "${path.module}/aws_lambda_functions/cognito_deactivate_guest"
  cognito_deactivate_guest_zip_file        = "${path.module}/aws_lambda_functions/${local.cognito_deactivate_guest_name}.zip"
  create_cognito_user_name               = "${lower(local.name)}-${lower(var.app_environment)}-create_cognito_user"
  create_cognito_user_source_dir         = "${path.module}/aws_lambda_functions/create_cognito_user"
  create_cognito_user_zip_file           = "${path.module}/aws_lambda_functions/${local.create_cognito_user_name}.zip"
  clipboard_onconnect_name               = "${lower(local.name)}-${lower(var.app_environment)}-clipboard_onconnect"
  clipboard_onconnect_source_dir         = "${path.module}/aws_lambda_functions/clipboard_onconnect"
  clipboard_onconnect_zip_file           = "${path.module}/aws_lambda_functions/${local.clipboard_onconnect_name}.zip"
  clipboard_disconnect_name              = "${lower(local.name)}-${lower(var.app_environment)}-clipboard_disconnect"
  clipboard_disconnect_source_dir        = "${path.module}/aws_lambda_functions/clipboard_disconnect"
  clipboard_disconnect_zip_file          = "${path.module}/aws_lambda_functions/${local.clipboard_disconnect_name}.zip"
  clipboard_sendmessage_name             = "${lower(local.name)}-${lower(var.app_environment)}-clipboard_sendmessage"
  clipboard_sendmessage_source_dir       = "${path.module}/aws_lambda_functions/clipboard_sendmessage"
  clipboard_sendmessage_zip_file         = "${path.module}/aws_lambda_functions/${local.clipboard_sendmessage_name}.zip"
}

