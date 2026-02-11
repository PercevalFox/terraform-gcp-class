terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "terraform-orange-course"  # <--- METTRE L'ID
  region  = "europe-west9"
}

# Exercice 1 : Le Réseau
resource "google_compute_network" "vpc_main" {
  name                    = "orange-vpc-01"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_main" {
  name          = "orange-subnet-paris"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west9"
  network       = google_compute_network.vpc_main.id
}

# Exercice 2 : La VM
# Une VM simple, sans IP publique pour commencer
resource "google_compute_instance" "vm_web" {
  name         = "orange-web-01"
  machine_type = "e2-micro"
  zone         = "europe-west9-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_main.id
    # access_config {} # Pas d'IP publique = Sécurité by design (SbD)
  }
  
  labels = {
    env = "training"
    owner = "orangepro"
  }
}
