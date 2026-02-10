provider "google" {
  project = "terraform-orange-course"
  region  = "europe-west9"
}

# On réutilise le réseau du matin (ou on le recrée vite fait a voir)
resource "google_compute_network" "vpc" {
  name = "vpc-modules-demo"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-modules-demo"
  ip_cidr_range = "10.10.0.0/24"
  region        = "europe-west9"
  network       = google_compute_network.vpc.id
}

# APPEL DU MODULE : Instance 1 (DEV)
module "vm_dev" {
  source     = "../../modules/simple-vm" # Chemin relatif local
  
  project_id = "terraform-orange-course"
  region     = "europe-west9"
  vm_name    = "app-dev-01"
  subnet_id  = google_compute_subnetwork.subnet.id
}

# APPEL DU MODULE : Instance 2 (PROD)
module "vm_prod" {
  source     = "../../modules/simple-vm"
  
  project_id = "terraform-orange-course"
  region     = "europe-west9"
  vm_name    = "app-prod-01"
  subnet_id  = google_compute_subnetwork.subnet.id
}
