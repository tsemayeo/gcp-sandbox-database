locals {
  port           = 3306

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
          database   = var.liquibase_schema
          privileges = ["ALL"]
        }
      ]
    }
    liquibase = {
      name = var.liquibase_schema
      database_grants = [
        {
          database   = "sandbox"
          privileges = ["ALL"]
        },
        {
          database   = var.liquibase_schema
          privileges = ["ALL"]
        }
      ]
    }
  }
}

resource "google_sql_database_instance" "db_master_instance" {
  name             = "${var.project_name}-master-instance-${var.environment}"
  database_version = "MYSQL_8_4"
  region           = var.region

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
  name     = var.default_schema
  instance = google_sql_database_instance.db_master_instance.name
}

resource "google_sql_database" "liquibase_schema" {
  name     = var.liquibase_schema
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
  parameter_id = var.project_name
  format       = "JSON"
}

resource "google_parameter_manager_parameter_version" "db_params_version" {
  parameter            = google_parameter_manager_parameter.db_params.id
  parameter_version_id = var.environment
  parameter_data = jsonencode(merge(
    {
      "rootUsername" : "root"
      "rootPassword" : random_password.root_password.result
      "defaultSchema" : var.default_schema
      "liquibaseSchema" : var.liquibase_schema
      "publicIP": google_sql_database_instance.db_master_instance.public_ip_address
      "host" : "jdbc:mysql://${google_sql_database_instance.db_master_instance.public_ip_address}:${local.port}/${var.default_schema}"
      "port" : local.port
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
