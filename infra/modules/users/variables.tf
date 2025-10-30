variable "instance" {
  description = "Name of the target Cloud SQL instance where the user should be created"
  type        = string
}

variable "name" {
  description = "Username to create in the Cloud SQL instance"
  type        = string
}

variable "host" {
  description = "Allowed host for the user (MySQL only). Use % to allow from any host."
  type        = string
  default     = "%"
}

variable "database_grants" {
  description = "List of database grants to apply. Each grant should specify database name and list of privileges."
  type = list(object({
    database   = string
    privileges = list(string)
  }))
  default = []
}
