provider "aws" {
access_key = ""
secret_key = ""
region = "ap-south-1"
}

#creating a EC2 instance
resource "aws_instance" "web_server" {

ami = "ami-03b5297d565ef30a6"
instance_type = "t2.micro"
tags = {
  Name = "Terraform"
  }
iam_instance_profile = aws_iam_instance_profile.test_profile.name
key_name = "tf"
}

#creating ebs volume with size of 10 GiB
resource "aws_ebs_volume" "data-vol" {
 availability_zone = "ap-south-1a"
 size = 10
 tags = {
        Name = "data-volume"
 }
}

# creating attachment to the volume
resource "aws_volume_attachment" "vol" {
 device_name = "/dev/sdc"
 volume_id = aws_ebs_volume.data-vol.id
 instance_id = aws_instance.web_server.id
}