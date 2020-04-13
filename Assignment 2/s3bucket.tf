resource "aws_s3_bucket" "log_bucket" {
  bucket = "vishnu"
  acl    = "log-delivery-write"
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "tf-bucket" {
  bucket = "vishnu"
  acl = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }

  server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

  tags = {
    Name = "my-terraform-bucket"
  }

}