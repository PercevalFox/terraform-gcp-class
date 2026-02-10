provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_compute_network" "vpc_main" {
  name                    = "orange-vpc-refactored" # On change le nom pour éviter les conflits
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_main" {
  name          = "orange-subnet-refactored"
  ip_cidr_range = "10.0.2.0/24" # Nouveau range
  region        = var.gcp_region
  network       = google_compute_network.vpc_main.id
}

resource "google_compute_instance" "vm_web" {
  name         = "orange-web-refactored"
  machine_type = var.machine_type
  zone         = "${var.gcp_region}-a" # Interpolation dynamique

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_main.id
  }
}
