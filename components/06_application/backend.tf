terraform {
  backend "s3" {
    bucket = "tf-test-tatsukoni"
    region  = "ap-northeast-1"
    key     = "application.tfstate"
    encrypt = true
  }
}
