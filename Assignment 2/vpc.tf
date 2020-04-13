creation

resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-vpc1"
  }
}

Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-igw"
  }
}

Public Route Table

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-public-route1"
  }
}

Private Route Table

resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    nat_gateway_id = aws_nat_gateway.my-test-nat-gateway.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "my-private-route-table1"
  }
}

Public Subnet
resource "aws_subnet" "public_subnet" {
  cidr_block              = "10.1.1.0/24"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "tf-public-subnet1"
  }
}

Private Subnet
resource "aws_subnet" "private_subnet" {
  cidr_block        = "10.1.2.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-south-1b"

  tags = {
    Name = "tf-private-subnet1"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnet.id
  depends_on     = [aws_route_table.public_route, aws_subnet.public_subnet]
}

resource "aws_route_table_association" "private_subnet_assoc" {
  route_table_id = aws_default_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet.id
  depends_on     = [aws_default_route_table.private_route, aws_subnet.private_subnet]
}

resource "aws_security_group" "test_sg" {
  name   = "terraform-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.test_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.test_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.test_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_eip" "my-test-eip" {
  vpc = true
}

resource "aws_nat_gateway" "my-test-nat-gateway" {
  allocation_id = aws_eip.my-test-eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_instance" "web_server1" {
ami = "ami-03b5297d565ef30a6"
instance_type = "t2.micro"
subnet_id = aws_subnet.public_subnet.id

}

resource "aws_instance" "web_server2" {
ami = "ami-03b5297d565ef30a6"
instance_type = "t2.micro"
subnet_id = aws_subnet.private_subnet.id

}