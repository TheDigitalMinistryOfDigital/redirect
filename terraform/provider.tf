provider "aws" {
  version = "~> 1.23.0"
  region = "${var.region}"
}

# This allows us to look up the AWS account id dynamically
data "aws_caller_identity" "current" {}
