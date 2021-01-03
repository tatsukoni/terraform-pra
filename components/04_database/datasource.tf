data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    "bucket" = "tf-test-tatsukoni"
    "region"  = "ap-northeast-1"
    "key"    = "network.tfstate"
  }
}
