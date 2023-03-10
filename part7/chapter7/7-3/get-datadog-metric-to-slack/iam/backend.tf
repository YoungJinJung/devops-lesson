terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "art-id-apnortheast2-tfstate"
    key            = "lambda/get-datadog-metric-to-s3/iam/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
