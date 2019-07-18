# auto associate public ips, in the future could use private ips + NAT gateway
# from: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
# If you are using public subnets, decide whether to provide a public IP address for the network interface. For a Fargate task in a public subnet to pull container images, a public IP address needs to be assigned to the task's elastic network interface, with a route to the internet or a NAT gateway that can route requests to the internet. For a Fargate task in a private subnet to pull container images, the private subnet requires a NAT gateway be attached to route requests to the internet. For more information, see Task Networking with the awsvpc Network Mode. 

resource "aws_subnet" "fargate" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.fargate_cidrs), count.index)}"
    availability_zone = "${element(split(",", var.fargate_azs), count.index)}"
    count = "${length(split(",", var.fargate_cidrs))}"
    map_public_ip_on_launch = "${var.assign_public_ip}"
}

resource "aws_subnet" "alb" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.alb_cidrs), count.index)}"
    availability_zone = "${element(split(",", var.alb_azs), count.index)}"
    count = "${length(split(",", var.alb_cidrs))}"
    map_public_ip_on_launch = true
}