terraform {
  required_version = ">= 1.3.0" #Forcing which version of Terraform needs to be used
  required_providers {
    aws = {
      version = "<= 5.0.0" #Forcing which version of plugin needs to be used.
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "devopsterraformjenkinsdev"
    key            = "multibranch-dev.tfstate"
    region         = "us-east-1"
    #dynamodb_table = "devopsb25-terraform-state-lock-dynamo"
    #encrypt        = true
  }
}