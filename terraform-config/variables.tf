variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "aws_region" {
    default = "us-west-2"
}

variable "fargate_cidrs" {
    default = "10.0.1.0/24"
}

variable "fargate_azs" {
    default = "us-west-2a"
}

variable "alb_cidrs" {
    default = "10.0.2.0/24,10.0.3.0/24"
}

variable "alb_azs" {
    default = "us-west-2a,us-west-2b"
}

variable "github_oauth_token" {}
variable "repo_owner" {}
variable "repo_name" {}
variable "branch" {
    default = "master"
}

variable "poll_source_changes" {
    description = "Poll source code repository for changes. Useful if you cannot configure Github webhooks."
    default = true
}