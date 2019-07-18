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

variable "app_port" {
    default = 80
}

variable "assign_public_ip" {
    description = "Assign public ip to ECS Fargate Task"
    default = true
}

variable "load_balancer_port" {
    default = 80
}

variable "health_check_path" {
    default = "/"
}

variable "app_desired_count" {
    default = 2
}