locals {
  name       = "sandbox-database"
  project_id = "tsemaye-sandbox"
  region     = "us-east1"
}

# refer to https://github.com/terraform-google-modules/terraform-google-sql-db/blob/main/examples/mysql-ha/main.tf
# to see example high availability configuration
module "db-cluster" {
  source     = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version    = "26.0"
  project_id = local.project_id

  # basic instance settings
  name              = "${local.name}-instance-${var.environment}"
  database_version  = "MYSQL_8_4"
  activation_policy = "ON_DEMAND"
  tier              = "db-f1-micro"
  edition           = "ENTERPRISE"
  availability_type = "REGIONAL"
  region = local.region

  # datbase settings
  root_password = random_password.root_password.result
  db_name       = "sandbox"
  db_charset    = "utf8mb4"
  db_collation  = "utf8mb4_general_ci"
}


resource "random_password" "root_password" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

module "db-secrets" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.9"
  project_id = local.project_id
  secrets = [
    {
      name        = "/sandbox/${local.name}/${var.environment}/root-password"
      secret_data = random_password.root_password.result
    }
  ]
}