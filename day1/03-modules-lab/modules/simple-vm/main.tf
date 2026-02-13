# Ce fichier définit CE QU'EST une VM standard
variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "vm_name" {
  type = string
}
variable "subnet_id" {
  type = string
}

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    # Pas d'IP publique par défaut dans le module = Standard Sécu
  }
  
  # On force des labels pour le reporting financier
  labels = {
    managed_by = "terraform"
    module     = "simple-vm"
  }
}
