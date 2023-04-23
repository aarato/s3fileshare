# Introduction

Share files and clipboard content real-time, securely using your own AWS account. The purpose of this software is to allow untrusted platforms to download/upload data in a controlled manner using "throwaway" credentials. This repository includes all software components, frontend, backend and Terraform IaC files to create an AWS "serverless" environment in minutes.

### Features

- All files are stored on a dedicated S3 bucket which acts both as a static web frontend and as a file server.
- The built-in clipboard allows real-time communication (chat) between logged in users.
- Files uploaded to the server can be shared easily via pre-signed URL links (no login needed!)
- Users can also upload/download files from the CLI (e.g. curl) using pre-signed URLs
- Access to the entire website can be shared by third-parties using temporary Identity tokens.
- Files are automatically deleted after 24 hours at midnight UTC the following day for security and cost reasons.
- Security tokens and pre-signed URLs automatically expire after approximately 1 hour.


### Benefits
- The website is directly hosted on an S3 Bucket so it is unlikely to be blocked.
- Authentication is controlled by AWS Cognito User Pool and it is automatically created/deleted by Terraform.
- Aggressive expiration policies ensure that all information stored on the server are only retained temporarily.
- The website can generate a pre-signed URLs to providfe access for third parties without a sign-up process.
- Clipboard communication is securely proxied via AWS real-time without even temporarily storing it in the cloud.
- Easy to remember and hard to block access to the website *https://s3.amazonaws.com//[BUCKET]/index.html*.
<!-- ![Alt Text](copyrun.gif) -->

# Getting started
1. As a prerequisite, make sure [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) are installed on your computer.
2. Clone this git repo and change into the terraform directory
```
git clone https://github.com/aarato/s3fileshare
cd ./s3fileshare/terraform
```
3. Optional, change the the variables in the variables.tf file.
- name: Unique AWS S3 bucket name that is also used as a prefix for ALL resource names created by Terraform (Default: random 8 digit)
- password: The password used for the defualt admin user (Default: random 16 characters).
- region: The AWS region where the resources will be created (Default: us-east-1).

4. Use the terraform command to initialize, plan and apply changes to your environment. You have to be in the terraform subdirectory to do this!
```
terraform init
terraform plan
terraform apply
terraform output
```
5. Copy the terraform output URL shown in the command line and open it in a browser. Login with the admin account.
```
https://[BUCKET].s3.[REGION].amazonaws.com/index.html"
```
6. Upload/Download files and inspect the corresponding AWS environment (S3, Cognito, API Gateway, Lambda, Cloudwatch). Use the clipboard to transfer text real-time between browsers.
7. When you are ready, destroy the entire AWS environment. All newly created AWS resources should be deleted.
```
- terraform destroy
```
# Password Change
Currently only the admin user is supported with an initial password provided at setup time. The admin password can be changed using AWS CLI. Example:
```
# aws cognito-idp admin-set-user-password --user-pool-id "<USER-POOL-ID>"  --username "admin" --password "<NEW-COMPLEX-PASSWORD>" --permanent
aws cognito-idp admin-set-user-password --user-pool-id "us-east-1_7GZQCV8KY"  --username "admin" --password "MyP@ssword1shere!" --permanent
```

# Directory Layout
```text
.
├── dist                -> Production front-end to S3 bucket (by 'npm run build')
├── public              -> Static files for the web front-end
├── src                 -> Vue.js folder
│   ├── main.js         -> Starting point
│   ├── App.js          -> Vue root
│   ├── store.js        -> Vuex store
│   └── components      -> Vue.js individual components for the frontend website
├── terraform           -> Terraform folder
│   ├── api_gateway.tf  -> Terraform API Gateway resources
│   ├── cloudwatch.tf   -> Terraform CloudWatch resources
│   ├── cognito.tf      -> Terraform Cognito resources
│   ├── dynamodb.tf     -> Terraform Dynamo DB resources
│   ├── iam.tf          -> Terraform IAM resources (roles & policies)
│   ├── variables.tf    -> Terraform Input variables
│   ├── output.tf       -> Terraform Output variables for Website and WebSocket URLs
│   ├── lambda.tf       -> Terraform Lambda resources (roles & policies)
│   ├── s3.tf           -> Terraform S3 resources for the web front-end
│   ├── lambda_clipboard_connect.tf     -> Terraform lambda function Node.js back-end code handling WebSocket connect
│   ├── lambda_clipboard_disconnect.tf  -> Terraform lambda function Node.js back-end code handling WebSocket disconnect     
│   ├── lambda_clipboard_sendmessage.tf -> Terraform lambda function Node.js back-end code replicating clipboard realtime changes to all connected clients   
│   ├── lambda_create_cognito_user      -> Terraform lambda function Python back-end code that creates the admin user and resets the password
│   ├── aws_lambda_functions            -> Directory containing the actual Node.js and Python code for the Lambda functions.
│   ├── main.tf         -> Terraform AWS provider and data definitions
│   ├── output.tf       -> Terraform output with URL & password
│   ├── s3.tf           -> Terraform S3 resources
│   ├── variables.tf    -> Terraform variables
│   └── template                        
│       └── awsconfig.json              -> Terraform JSON template to provide AWS resource IDs for the web front-end
└── README.md           -> This readme file
