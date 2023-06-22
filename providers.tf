terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.4.0"
    }
  }
}

provider "aws" {
  # default Configuration options
  region = "eu-central-1"
  profile = "touchacademy"
}
