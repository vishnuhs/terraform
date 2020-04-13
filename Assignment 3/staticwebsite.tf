resources and variables files

resource "aws_s3_bucket" "logs" {
  bucket = "${var.site_name}-site-logs"
  acl = "log-delivery-write"
}

resource "aws_s3_bucket" "www_site" {
  bucket = "www.${var.site_name}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site_name}/"
  }

  website {
    index_document = "index.html"
  }
}

variable "site_name" {
  description = "My site"
}

resource "aws_s3_bucket" "www_site" {
  bucket = "www.${var.site_name}"

  logging {
    target_bucket = "www.${var.site_name}"
  }

  website {
    index_document = "index.html"
  }
}


for s3 bucket

data "template_file" "bucket_policy" {
  template = "${file("bucket_policy.json")}
  vars {
    origin_access_identity_arn = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    bucket = "${aws_s3_bucket.www_site.arn}"
  }
}

resource "aws_s3_bucket" "www_site" {
  bucket = "www.${var.site_name}"
  policy = "${data.template_file.bucket_policy.rendered}"
}

bucket policy

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "OnlyCloudfrontReadAccess",
      "Principal": {
        "AWS": "${origin_access_identity_arn}"
      },
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${bucket}/*"
    }
  ]
}

for DNS 

resource "aws_route53_record" "www_site" {
  zone_id = "${data.aws_route53_zone.site.zone_id}"
  name = "www.${var.site_name}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id  = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}


bucket configuration

context 's3 bucket' do

  describe command('aws s3 ls s3://dperez-test-bucket') do
    its(:stdout) { should_match /Access Denied/ }
  end

  describe command('curl -i https://s3.amazonaws.com/dperez-test-bucket') do
    its(:stdout) { should_match /Access Denied/ }
  end
end

context 'cloudfront' do
  describe command('curl -i https://www.mysite.com') do
    its(:stdout) { should_match /200 OK/ }
  end

  describe command('curl -i http://www.mysite.com') do
    its(:stdout) { should_match /301 Redirect/ }
  end
end