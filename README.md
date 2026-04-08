# Introduction

Share files and clipboard content real-time, securely using your own AWS account. The purpose of this software is to allow untrusted platforms to download/upload data in a controlled manner using temporary IAM credentials. This repository includes all software components, frontend, backend and Terraform IaC files to create an AWS "serverless" environment in minutes.

### Features

- All files are stored on a dedicated S3 bucket which acts both as a static web frontend and as a file server.
- The built-in clipboard allows real-time communication (chat) between logged in users.
- Files uploaded to the server can be shared easily via pre-signed URL links (no login needed).
- Users can also upload/download files from the CLI (e.g. curl) using pre-signed URLs.
- Files are automatically deleted after 24 hours at midnight UTC the following day for security and cost reasons.
- Pre-signed URLs automatically expire after approximately 1 hour.

### Benefits

- The website is hosted directly on S3 path-style URL (`https://s3.amazonaws.com/[BUCKET]/index.html`) which is unlikely to be blocked by corporate proxies (e.g. Zscaler).
- Login uses IAM Access Key + Secret Key entered directly in the browser — no credentials are stored in config files.
- All S3 API calls are same-origin (`s3.amazonaws.com → s3.amazonaws.com`) so CORS is never triggered, even behind strict proxies.
- A least-privilege IAM user is automatically created by Terraform scoped only to the app's S3 folder and WebSocket API.
- Aggressive expiration policies ensure that all information stored on the server is only retained temporarily.
- Clipboard communication is securely proxied via AWS WebSocket API Gateway in real-time.

# Getting Started

### Prerequisites

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Node.js + npm](https://nodejs.org/)
- [Git](https://git-scm.com/)
- AWS credentials configured locally (`aws configure` or environment variables)

### Deploy

1. Clone this repo and change into the terraform directory:
```
git clone https://github.com/aarato/s3fileshare
cd s3fileshare/terraform
```

2. (Optional) Set a fixed bucket name and region in `terraform.auto.tfvars`:
```hcl
name   = "mybucketname"   # must be globally unique; default: random 8 digits
region = "us-east-1"      # default: us-east-1
```
> **Important:** If you leave `name` blank, a random name is generated on each apply. After `terraform destroy` + `terraform apply` the URL will be different.

3. Initialize, plan and apply:
```
terraform init
terraform plan
terraform apply
terraform output
```

4. Note the outputs:
```
app_user_access_key_id     = "AKIA..."
app_user_secret_access_key = <sensitive>   # retrieve with: terraform output -raw app_user_secret_access_key
url                        = "https://27763765.s3.us-east-1.amazonaws.com/index.html"
websocket_api              = "wss://..."
```

5. Open the path-style URL in a browser:
```
https://s3.amazonaws.com/[BUCKET]/index.html
```
> Use the path-style URL (`s3.amazonaws.com/bucket/...`), not the virtual-hosted URL in the `url` output. Path-style is same-origin for all S3 API calls and works through corporate proxies.

6. Log in with the IAM credentials from step 4:
   - **AWS Access Key ID** — from `terraform output app_user_access_key_id`
   - **AWS Secret Access Key** — from `terraform output -raw app_user_secret_access_key`

7. Upload/download files and use the clipboard to transfer text between browsers in real-time.

### Destroy

When done, tear down the entire environment:
```
terraform destroy
```

# Retrieving Credentials After Deploy

```bash
terraform output app_user_access_key_id
terraform output -raw app_user_secret_access_key
```

The secret key is marked sensitive and won't print without `-raw`.

# Building the Frontend

The `dist/` folder is pre-built and committed. To rebuild after source changes:
```
npm install
npm run build
```
Then sync to S3 (exclude `awsconfig.json` which is Terraform-managed):
```
aws s3 sync dist/ s3://[BUCKET]/ --exclude "awsconfig.json"
```

# Directory Layout

```
.
├── dist/                        Production build (committed, synced to S3 by Terraform)
├── public/                      Static assets for the web frontend
├── src/                         Vue.js source
│   ├── main.js                  Entry point
│   ├── App.vue                  Root component
│   ├── store.js                 Reactive global state
│   └── components/              Individual Vue components
│       ├── AWSWindowLogin.vue   IAM credentials login form
│       ├── AWSWindowFiles.vue   File list, upload, download, delete, share
│       ├── AWSWindowClipboard.vue  Real-time clipboard via WebSocket
│       └── AWSModalConfig.vue   AWS settings modal (bucket, region, etc.)
└── terraform/
    ├── main.tf                  Provider config, S3 frontend deployment
    ├── variables.tf             Input variables and locals
    ├── output.tf                Outputs: URL, credentials, WebSocket
    ├── s3.tf                    S3 bucket, CORS, public access, objects
    ├── iam.tf                   IAM roles for API Gateway and Cognito
    ├── iam_app_user.tf          Dedicated IAM user + access key for app login
    ├── cognito.tf               Cognito User Pool, Identity Pool, Hosted UI
    ├── api_gateway.tf           WebSocket API Gateway for clipboard
    ├── dynamodb.tf              DynamoDB table for WebSocket connection tracking
    ├── cloudwatch.tf            CloudWatch log group
    ├── lambda_*.tf              Lambda function definitions
    ├── aws_lambda_functions/    Lambda source code
    └── templates/
        └── awsconfig.json       JSON template deployed to S3 for frontend config
```
