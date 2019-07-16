resource "aws_security_group" "ecs" {
  name        = "ecs-task-security-group"
  description = "allow inbound from internet"
  vpc_id      = "${aws_vpc.vpc.id}"

  # TODO make this restrictive to only ALB subnet!!!
  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}