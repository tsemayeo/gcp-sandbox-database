locals {
  users = {
    admin = {
      name = "admin"
      database_grants = [
        {
          database   = var.default_schema
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
          database   = var.default_schema
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
    activation_policy = "ALWAYS"

    # eventually move to private access
    ip_configuration {
      ipv4_enabled = true
    }
  }
  deletion_protection = false
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
