resource "random_password" "user_password" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "@#%&*-_+=[]{}:,." # Avoid shell-problematic chars like !, $, (, ), etc.
}

resource "google_sql_user" "this" {
  name     = var.name
  instance = var.instance
  password = random_password.user_password.result
  host     = var.host
}

