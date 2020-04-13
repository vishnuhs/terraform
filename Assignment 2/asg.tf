auto scaling groups

resource "aws_launch_configuration" "my-test-launch-config" {
  image_id        = "ami-03b5297d565ef30a6"
  instance_type   = "t2.micro"
  security_groups = [
  aws_security_group.my-asg-sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello World" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier  = [aws_subnet.public_subnet.id , aws_subnet.public_subnet1.id]
  target_group_arns    = [
    aws_lb_target_group.my-target-group.arn
]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "my-asg-sg" {
  name   = "my-asg-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "inbound_ssh1" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http1" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all1" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}