resource "aws_instance" "count_server" {
count = 2
ami = "ami-03b5297d565ef30a6"
instance_type = "t2.micro"
tags = {
  Name = "Terraform-${count.index + 1}"
  }
}