DEPLOYING A SINGLE WEB SERVER:

provider "aws" {
access_key= "${var.access_key}"
secret_key= "${var.secret_key}"
region= "${var.region}"
}

variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "vpc_cidr" {}
variable "public_cidr" {}
variable "instance_type" {}
variable "key_pair" {}

access_key="chsdvckcsjcbjzxdcjhvsd"
secret_key="xzjhbcjhvsjchvjhvdchzx"
region="us-west-1"
vpc_cidr="12.0.0.0/16"
public_cidr="12.0.0.1/24"
instance_type="t2.micro"
key_pair="vishnu"

resource "aws_vpc" "main" {
cidr_block="${var.vpc_cidr}"
tags={
Name="${var.vpc_tag}"
}
}

resource "aws_subnet" "main" {
vpc_id="${aws_vpc.main.id}"
cidr_block="${var.public_cidr}"
tags={
Name="${var.pub_subnet_tag}"
}
}

resource "aws_security_group" "webserver-sg" {
name="webserver-sg"
vpc_id="${aws_vpc.main.id}"
ingress
{
from_port=80
to_port=80
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}
egress
{
from_port=0
to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"]
}

resource "aws_instance" "webserver" {
ami="${var.amiid}"
user_data=<<-EOF
#!/bin/bash -xe
sudo yum update -y
sudo yum install httpd -y
sudo /etc/init.d/httpd start
while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; echo 'Hello, World!'; } | nc -l 8080; done
EOF
count=1
instance_type="t2.micro"
key_name="${var.key_pair}"
subnet_id="${aws_subnet.main.id}"
associate_public_ip_address=true
security_groups=["${aws_security_group.Webserver-sg.id}"]
}

