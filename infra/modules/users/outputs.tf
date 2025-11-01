output "username" {
  description = "The created database username"
  value       = google_sql_user.this.name
}

output "password" {
  description = "The generated password for the user"
  value       = random_password.user_password.result
  sensitive   = true
}
