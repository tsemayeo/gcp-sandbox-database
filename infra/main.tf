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

resource "google_parameter_manager_parameter" "db_params" {
  parameter_id = local.name
  format = "JSON"
}

resource "google_parameter_manager_parameter_version" "db_params_version" {
  parameter = google_parameter_manager_parameter.parameter-basic.id
  parameter_version_id = var.environment
  parameter_data = jsonencode({
    "rootPassword": random_password.root_password.result
  })
}