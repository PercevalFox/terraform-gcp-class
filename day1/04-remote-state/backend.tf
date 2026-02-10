terraform {
  backend "gcs" {
    bucket  = "tf-state-orange-training-NOM" # Remplacez par VOTRE bucket crée precedemment
    prefix  = "terraform/state"
  }
}
