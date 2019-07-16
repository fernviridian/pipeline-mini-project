resource "aws_ecs_cluster" "demo" {
  name = "demo"
}

# ECS Service Role
resource "aws_iam_role" "iam_ecs_service_role" {
  name = "iam_ecs_service_role"
  path = "/"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs_service_role_policy"
  role = "${aws_iam_role.iam_ecs_service_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:Describe*",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets"
        ],
        "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "iam_ecs_task_role" {
  name = "iam_ecs_task_role"
  path = "/"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "ecs_task_role_policy"
  role = "${aws_iam_role.iam_ecs_task_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# service definition
resource "aws_ecs_service" "flask" {
  name            = "flask"
  cluster         = "${aws_ecs_cluster.demo.id}"
  task_definition = "${aws_ecs_task_definition.flask.arn}"
  desired_count   = 1
  #iam_role        = "${aws_iam_role.iam_ecs_service_role.arn}"
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]
  launch_type     = "FARGATE"

  network_configuration {
      subnets = ["${aws_subnet.fargate[0].id}"]
      security_groups = ["${aws_security_group.ecs.id}"]
      assign_public_ip = "${var.assign_public_ip}"
  }

  #load_balancer {
  #  target_group_arn = "${aws_lb_target_group.foo.arn}"
  #  container_name   = "flask"
  #  container_port   = 80
  #}

}
resource "aws_ecs_task_definition" "flask" {
  family                = "flask"
  # Note using nginx:alpine as bootstrap image, real service image will come from CodePipeline build and deploy :)
  task_role_arn = "${aws_iam_role.iam_ecs_task_role.arn}"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  container_definitions = <<DEFINITION
[
  {
    "cpu": 256,
    "image": "nginx:alpine",
    "memory": 512,
    "name": "flask",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION
}
