###
### DYNAMODB
###

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "${var.name}_clipboard_connection_table"
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