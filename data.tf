terraform {
  backend "s3" {
    bucket = "terraform-state-jithendar"
    key    = "rs-instances/user.tfstate"
    region = "us-east-1"
  }
}