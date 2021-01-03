terraform {
  backend "s3" {
    bucket = "tf-test-tatsukoni"
    region  = "ap-northeast-1"
    key     = "network.tfstate"
    encrypt = true
  }
}
