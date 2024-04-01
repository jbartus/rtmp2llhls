terraform {
  required_providers {
    fastly = {
      source = "fastly/fastly"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_key
}

provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}