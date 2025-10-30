terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.13.4"
}
