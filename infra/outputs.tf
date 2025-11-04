output "secrets" {
  description = "Complete information for all Secret Manager secrets including names, IDs, values, and metadata"
  value = {
    for key, secret_config in local.secrets : key => {
      
      # Resource information
      secret_id        = google_secret_manager_secret.secrets[key].secret_id
      secret_name      = google_secret_manager_secret.secrets[key].name
      resource_id      = google_secret_manager_secret.secrets[key].id
      version_id       = google_secret_manager_secret_version.secret_versions[key].id
      version_name     = google_secret_manager_secret_version.secret_versions[key].name
      
      # Secret value
      value = secret_config.value
    }
  }
  sensitive = true
}
