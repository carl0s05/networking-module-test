# Se especifica el backend para el estado de Terraform, en este caso un bucket S3.
terraform {
  backend "s3" {
    bucket               = "s3hatest"
    key                  = "tfstate/s3hatest.tfstate"
    workspace_key_prefix = "test-ha"
    region               = "us-west-2"
    /*
    endpoints = {
      s3 = "https://s3.us-east-1.amazonaws.com"
    }*/

  }
}