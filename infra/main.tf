locals {
  # values that could be moved to variables
  name           = "sandbox-database"
  default_schema = "sandbox"
  project_id     = "tsemaye-sandbox"
  region         = "us-east1"

  # hard coded values should be a part of module
  users = {
    admin = {
      name = "admin"
      database_grants = [
        {
          database   = "sandbox"
          privileges = ["ALL"]
        },
        {
          database   = "liquibase"
          privileges = ["ALL"]
        }
      ]
    }
    liquibase = {
      name = "liquibase"
      database_grants = [
        {
          database   = "sandbox"
          privileges = ["ALL"]
        },
        {
          database   = "liquibase"
          privileges = ["ALL"]
        }
      ]
    }
  }
}

resource "google_sql_database_instance" "db_master_instance" {
  name             = "${local.name}-master-instance-${var.environment}"
  database_version = "MYSQL_8_4"
  region           = local.region

  settings {
    tier              = "db-f1-micro"
    edition           = "ENTERPRISE"
    availability_type = "ZONAL"

    # eventually move to private access
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0" # WARNING: This allows all IPs - replace with your specific IP for production
      }
    }
  }
  root_password       = random_password.root_password.result
  deletion_protection = false
}

# this is being kept for terraform mysql provider runs but eventually it should use some other form of authentication
# to connect to the database.
resource "random_password" "root_password" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "google_sql_database" "default_schema" {
  name     = local.default_schema
  instance = google_sql_database_instance.db_master_instance.name
}

resource "google_sql_database" "liquibase_schema" {
  name     = "liquibase"
  instance = google_sql_database_instance.db_master_instance.name
}

module "users" {
  for_each = local.users

  source          = "./modules/users"
  instance        = google_sql_database_instance.db_master_instance.name
  name            = each.value.name
  database_grants = each.value.database_grants
}

resource "google_parameter_manager_parameter" "db_params" {
  parameter_id = local.name
  format       = "JSON"
}

resource "google_parameter_manager_parameter_version" "db_params_version" {
  parameter            = google_parameter_manager_parameter.db_params.id
  parameter_version_id = var.environment
  parameter_data = jsonencode(merge(
    {
      "rootUsername" : "root"
      "rootPassword" : random_password.root_password.result
      "host" : google_sql_database_instance.db_master_instance.public_ip_address
      "port" : "3306"
    },
    {
      for user_key, user in module.users :
      "${user_key}Username" => user.username
    },
    {
      for user_key, user in module.users :
      "${user_key}Password" => user.password
    }
  ))
}
