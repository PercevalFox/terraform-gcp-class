# A lancer chaqu"un individuellement avec son prénom
gsutil mb -l europe-west9 gs://tf-state-orange-training-NOM
# Active le versioning (Filet de sécurité)
gsutil versioning set on gs://tf-state-orange-training-NOM
