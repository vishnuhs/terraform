resource "aws_eip" "eip" {
instance = aws_instance.web_server3.id
vpc  = true
}

resource "aws_route53_zone" "my-test-zone" {
  name = "vishnu.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "my-example-record" {
  name    = "www.vishnu.com"
  zone_id = aws_route53_zone.my-test-zone.id
  records = aws_eip.eip.public_ip
  type    = "A"
  ttl     = "300"
}