# Se especifica el backend para el estado de Terraform, en este caso un bucket S3.
terraform {
  backend "s3" {
    bucket               = "s3testha"
    key                  = "tfstate/s3testha.tfstate"
    workspace_key_prefix = "test-ha"
    region               = "us-east-1"
    /*
    endpoints = {
      s3 = "https://s3.us-east-1.amazonaws.com"
    }*/

  }
}