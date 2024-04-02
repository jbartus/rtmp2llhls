# generate a two hex character random suffix to avoid namespace collisions
resource "random_id" "rid" {
  byte_length = 1
}

locals {
  suffix = random_id.rid.hex
}

# launch a VM on GCP that runs OME as a container
resource "google_compute_instance" "ome" {
  name         = "ome-${local.suffix}"
  machine_type = "n2-standard-8"
  tags         = ["ome-${local.suffix}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2310-amd64"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("${var.ssh_pub_key}")}"
    user-data = file("ome.conf")
  }
}

# allow RTMP and LL-HLS (http on 3333) connections into the VM
resource "google_compute_firewall" "ome" {
  name    = "ome-${local.suffix}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["1935", "3333"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ome-${local.suffix}"]
}

# front the ome-llhls service with a fastly service
resource "fastly_service_vcl" "llhls" {
  name = "llhls"

  domain {
    name = "llhls-${local.suffix}.global.ssl.fastly.net"
  }

  backend {
    address = google_compute_instance.ome.network_interface.0.access_config.0.nat_ip
    name    = "ome-vm"
    port    = 3333
    use_ssl = "false"
    shield  = "atlanta-ga-us"
  }

  snippet {
    name    = "smiss"
    type    = "fetch"
    content = "set beresp.do_stream = true;"
  }

  force_destroy = true
}