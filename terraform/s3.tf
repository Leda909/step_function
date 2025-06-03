resource "random_id" "bucket_suffix" {
  byte_length = 6
}

# create the first bucket
resource "aws_s3_bucket" "first_bucket" {
  bucket_prefix = "${var.first_bucket_prefix}-${random_id.bucket_suffix.hex}"

  tags={
    Name="First Data Bucket"
    Environment="dev"
  }
}

# create the second bucket
resource "aws_s3_bucket" "second_bucket" {
  bucket_prefix = "${var.second_bucket_prefix}-${random_id.bucket_suffix.hex}"

  tags={
    Name="Second Data Bucket"
    Environment="dev"
  }
}