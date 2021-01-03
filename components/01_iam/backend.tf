terraform {
  backend "s3" {
    bucket = "tf-test-tatsukoni"
    region  = "ap-northeast-1"
    key     = "iam.tfstate"
    encrypt = true
  }
}
