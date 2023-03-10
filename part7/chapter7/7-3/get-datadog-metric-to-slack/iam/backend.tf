terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = s3.bucket
    key            = s3.key
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
