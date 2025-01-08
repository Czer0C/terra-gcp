provider "google" {
  credentials = file("/home/divin/.ssh/gcp.json")
  project = "video-streaming-446003"
  region  = "us-central1"
}

resource "google_compute_instance" "ansible_ready_instance" {
  name         = "ansible-instance"
  machine_type = "e2-small"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20241219"
    }
  }

  network_interface {
    network       = "default"
    access_config {} # Ephemeral external IP
  }

  metadata = {
    ssh-keys = "gcp:${file("~/.ssh/id_ed25519.pub")}"
  }

  tags = ["allow-ssh"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

output "instance_ip" {
  value = google_compute_instance.ansible_ready_instance.network_interface[0].access_config[0].nat_ip
}
