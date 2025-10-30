locals {
  name       = "sandbox-database"
  project_id = "tsemaye-sandbox"
  region     = "us-east1"
}

resource "google_sql_database_instance" "db_master_instance" {
  name             = "${local.name}-master-instance-${var.environment}"
  database_version = "MYSQL_8_4"
  region           = local.region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier              = "db-f1-micro"
    edition           = "ENTERPRISE"
    availability_type = "ZONAL"
  }
  root_password       = random_password.root_password.result
  deletion_protection = false
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
  format       = "JSON"
}

resource "google_parameter_manager_parameter_version" "db_params_version" {
  parameter            = google_parameter_manager_parameter.db_params.id
  parameter_version_id = var.environment
  parameter_data = jsonencode({
    "rootPassword" : random_password.root_password.result
  })
}