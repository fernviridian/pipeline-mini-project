resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "default" {
    route_table_id = "${aws_vpc.vpc.main_route_table_id}"
    gateway_id     = "${aws_internet_gateway.gw.id}"
    destination_cidr_block = "0.0.0.0/0"
}