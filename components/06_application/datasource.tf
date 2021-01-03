data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    "bucket" = "tf-test-tatsukoni"
    "region"  = "ap-northeast-1"
    "key"    = "network.tfstate"
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    "bucket" = "tf-test-tatsukoni"
    "region"  = "ap-northeast-1"
    "key"    = "database.tfstate"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    "bucket" = "tf-test-tatsukoni"
    "region"  = "ap-northeast-1"
    "key"    = "ecr.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    "bucket" = "tf-test-tatsukoni"
    "region"  = "ap-northeast-1"
    "key"    = "iam.tfstate"
  }
}

data "terraform_remote_state" "ssm" {
  backend = "s3"

  config = {
    "bucket" = "tf-test-tatsukoni"
    "region"  = "ap-northeast-1"
    "key"    = "ssm.tfstate"
  }
}
