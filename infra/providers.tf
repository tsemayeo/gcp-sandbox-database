provider "google" {
  project = local.project_id
  region  = local.region
}

provider "random" {}

provider "mysql" {
  endpoint = "${google_sql_database_instance.db_master_instance.public_ip_address}:3306"
  username = "root"
  password = random_password.root_password.result
  tls      = false # Set to true if SSL/TLS is required
}
