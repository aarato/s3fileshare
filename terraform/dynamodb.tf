###
### DYNAMODB
###

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0"
  name     = "${local.name}_clipboard_connection_table"
  hash_key = "connectionId"

  attributes = [
    {
      name = "connectionId"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}