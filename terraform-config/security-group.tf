resource "aws_security_group" "lb" {
  name        = "load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.load_balancer_port}"
    to_port     = "${var.load_balancer_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ecs" {
  name        = "ecs-task-security-group"
  description = "allow inbound from ALB to ECS Fargate"
  vpc_id      = "${aws_vpc.vpc.id}"

  # Fargate TASK can only talk to ALB, not general internet at all
  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}