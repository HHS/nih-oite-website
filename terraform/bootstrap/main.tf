locals {
  cf_api_url      = "https://api.fr.cloud.gov"
  s3_service_name = "nih_oite_experiments-terraform-state"
}

module "s3" {
  source = "../shared/s3"

  cf_api_url      = local.cf_api_url
  cf_user         = var.cf_user
  cf_password     = var.cf_password
  cf_org_name     = "sandbox-gsa"
  cf_space_name   = "ryan.ahearn"
  s3_service_name = local.s3_service_name
  s3_plan_name    = "basic-sandbox"
}

resource "cloudfoundry_service_key" "bucket_creds" {
  name             = "${local.s3_service_name}-access"
  service_instance = module.s3.bucket_id
}

output "bucket_credentials" {
  value = cloudfoundry_service_key.bucket_creds.credentials
}
