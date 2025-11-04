locals {
  # All secrets in one block
  secrets = merge(
    # Database configuration secrets
    {
      default_schema = {
        name        = "DEFAULT_SCHEMA"
        value       = var.default_schema
        description = "Default database schema name"
      }
      liquibase_schema = {
        name        = "LIQUIBASE_SCHEMA"
        value       = var.liquibase_schema
        description = "Liquibase database schema name"
      }
      instance_connection_name = {
        name        = "INSTANCE_CONNECTION_NAME"
        value       = google_sql_database_instance.db_master_instance.connection_name
        description = "Cloud SQL instance connection name"
      }
    },
    # User usernames
    {
      for user_key in keys(local.users) :
      "${user_key}_username" => {
        name        = "${upper(user_key)}_USERNAME"
        value       = module.users[user_key].username
        description = "Username for ${user_key} user"
      }
    },
    # User passwords
    {
      for user_key in keys(local.users) :
      "${user_key}_password" => {
        name        = "${upper(user_key)}_PASSWORD"
        value       = module.users[user_key].password
        description = "Password for ${user_key} user"
      }
    }
  )
}

# Create all secrets dynamically
resource "google_secret_manager_secret" "secrets" {
  for_each = local.secrets

  secret_id = each.value.name

  replication {
    auto {
    }
  }
}

# Create all secret versions dynamically
resource "google_secret_manager_secret_version" "secret_versions" {
  for_each = local.secrets

  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value.value
}