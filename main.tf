resource "random_id" "unique" {
  byte_length = 1
}

resource "google_compute_instance" "ome" {
  name         = "ome-${random_id.unique.hex}"
  machine_type = "n2-standard-8"
  tags         = ["ome-${random_id.unique.hex}"]

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

resource "google_compute_firewall" "ome" {
  name    = "ome-${random_id.unique.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["1935", "3333"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ome-${random_id.unique.hex}"]
}

resource "fastly_service_vcl" "llhls" {
  name = "llhls"

  domain {
    name = "llhls-${random_id.unique.hex}.global.ssl.fastly.net"
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