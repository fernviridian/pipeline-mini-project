provider "aws" {
    version = "2.19.0"
    region = "${var.aws_region}"
}

# get account id
data "aws_caller_identity" "current" {}