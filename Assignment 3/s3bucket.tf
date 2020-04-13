terraform basics

terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "mykey"
    region = "us-east-1"
  }
}

for permissions

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
    }
  ]
}

dynamodb permissions

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/mytable"
    }
  ]
}

s3 remote state

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-prod"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data.terraform_remote_state.network:
  id = 2016-10-29 01:57:59.780010914 +0000 UTC
  addresses.# = 2
  addresses.0 = 52.207.220.222
  addresses.1 = 54.196.78.166
  backend = s3
  config.% = 3
  config.bucket = terraform-state-prod
  config.key = network/terraform.tfstate
  config.region = us-east-1
  elb_address = web-elb-790251200.us-east-1.elb.amazonaws.com
  public_subnet_id = subnet-1e05dd33

providers and variables

variable "workspace_iam_roles" {
  default = {
    staging    = "arn:aws:iam::STAGING-ACCOUNT-ID:role/Terraform"
    production = "arn:aws:iam::PRODUCTION-ACCOUNT-ID:role/Terraform"
  }
}

provider "aws" {
  # No credentials explicitly set here because they come from either the
  # environment or the global credentials file.

  assume_role = "${var.workspace_iam_roles[terraform.workspace]}"
}