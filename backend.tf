terraform {  
  backend "s3" {
    region         = "eu-central-1"
    bucket         = "jozef-tf-state"
    key            = "ecs.tfstate"
    dynamodb_table = "jozef-tf-state-lock"
    encrypt        = true
    profile        = "touchacademy"
  }
}