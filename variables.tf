variable "fastly_api_key" {
  type = string
}

variable "google_project" {
  type = string
}

variable "google_region" {
  type    = string
  default = "us-east1"
}

variable "google_zone" {
  type    = string
  default = "us-east1-b"
}

variable "ssh_pub_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}