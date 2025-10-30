provider "google" {
  project = local.project_id
  region  = local.region
}

provider "random" {}

