terraform {
  backend "s3" {
    key    = "minecraft/state.tfstate"
    region = "us-east-2"
  }
}
