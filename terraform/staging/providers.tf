terraform {
  required_version = "~> 1.0"
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.15.0"
    }
  }

  backend "s3" {
    bucket  = "cg-c239b06e-b226-4f92-a84e-83e0b393bd27"
    key     = "terraform.tfstate.stage"
    encrypt = "true"
    region  = "us-gov-west-1"
    profile = "nih_oite_experiments-terraform-backend"
  }
}

provider "cloudfoundry" {
  api_url      = "https://api.fr.cloud.gov"
  user         = var.cf_user
  password     = var.cf_password
  app_logs_max = 30
}
