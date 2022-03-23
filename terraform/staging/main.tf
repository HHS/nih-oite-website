locals {
  cf_org_name      = "sandbox-gsa"
  cf_space_name    = "ryan.ahearn"
  env              = "staging"
  recursive_delete = true
}

module "database" {
  source = "../shared/database"

  cf_user          = var.cf_user
  cf_password      = var.cf_password
  cf_org_name      = local.cf_org_name
  cf_space_name    = local.cf_space_name
  env              = local.env
  recursive_delete = local.recursive_delete
  rds_plan_name    = "micro-psql"
}

data "cloudfoundry_space" "space" {
  org_name = local.cf_org_name
  name     = local.cf_space_name
}

data "cloudfoundry_domain" "internal" {
  name = "apps.internal"
}

data "cloudfoundry_app" "app" {
  name_or_id = "nih_oite_experiments-${local.env}"
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "gateway" {
  name_or_id = "nih_oite_experiments-${local.env}-gateway"
  space      = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_network_policy" "gateway_routing" {
  policy {
    source_app      = data.cloudfoundry_app.app.id
    destination_app = data.cloudfoundry_app.gateway.id
    port            = "8080"
  }
}
