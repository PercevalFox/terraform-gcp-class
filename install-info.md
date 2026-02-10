# On met à jour l'OS et on installe les dépendances de base
```
sudo apt update && sudo apt install -y gnupg software-properties-common curl git apt-transport-https ca-certificates gnupg
```

# On récupère la clé de signature officielle HashiCorp
```
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

# On vérifie l'empreinte de la clé
```
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

# Ajout du repo officiel
```
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

# Update (au cas où) et Install de tf
```
sudo apt update
sudo apt install terraform
```

# Vérification de la version pour qu'on soit sur que ce soit bien installé sur la machine
```
terraform -version
```

# Autocompletion plus pratique (ATTENTION PAS EN PROD !!!!!!!)
```
terraform -install-autocomplete
source ~/.bashrc
```

# Ajouter la clé de signature Google Cloud
```
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
```

# Télécharger la clé publique
```
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
```

# Maj depot et installer gcp cli
```
sudo apt update && sudo apt install -y google-cloud-cli
```

# Vérification
```
gcloud --version
```

# Authentification GCP (pas de clé Service Account en dev, faille de sécu majeure)
```
gcloud auth login
```

# Créer notre projet
```
gcloud projects create terraform-orange-course --name="Formation Terraform Orange"
```

# Liste nos projets
```
gcloud projects list
```

# Config du projet pour la formation 
```
gcloud config set project terraform-orange-course
```

# Dis à l'auth ADC d'utiliser ce projet pour les quotas (fixe le warning)
```
gcloud auth application-default set-quota-project terraform-orange-course
```

# lister le compte de factu
```
gcloud beta billing accounts list
```

# Ajouter le compte de factu, sinon ca marche pas
```
gcloud beta billing projects link terraform-orange-course --billing-account XXXXX-XXXXXX-XXXXXX
```

# set un quota sur un projet précis
```
gcloud auth application-default set-quota-project terraform-orange-course
```

# Allumer les moteurs de l'API sinon terraform va echouer
```
gcloud services enable compute.googleapis.com --project terraform-orange-course
```

# On va tester maintenant un terra simple
```
nano main.tf
```

```
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # Ici on met le nom du projet et la région pour tester
  project = "terraform-orange-course" 
  region  = "europe-west9"
}

# réseau de test
resource "google_compute_network" "vpc_test" {
  name                    = "vpc-test-terraform"
  auto_create_subnetworks = false
}
```

# on va init puis plan
```
terraform init
```

```
terraform plan
```

# et pour finir on va apply
```
terraform apply -auto-approve
```

# et après on detruit pour eviter que ca oute de l'argent
```
terraform destroy -auto-approve
```
