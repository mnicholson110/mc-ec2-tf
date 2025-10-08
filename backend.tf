terraform {
  backend "s3" {
    key    = "state.tfstate"
    region = "us-east-2"
  }
}
