variable "environment" {
  description = "environment to deploy"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "name of the project"
  type        = string
}

variable "project_id" {
  description = "gcp project id"
  type        = string
}

variable "region" {
  description = "gcp region"
  type        = string
  default     = "us-east1"
}
variable "db_tier" {
  description = "database instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "default_schema" {
  description = "default database schema name"
  type        = string
}

variable "liquibase_schema" {
  description = "liquibase database schema name"
  type        = string
  default     = "liquibase"
}