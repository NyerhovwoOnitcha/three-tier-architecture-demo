provider "aws" {
  region = "eu-north-1"
}

data "aws_availability_zones" "available" {}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
