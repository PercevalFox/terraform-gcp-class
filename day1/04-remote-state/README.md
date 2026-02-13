### A lancer chaqu"un individuellement avec son prénom
```
gsutil mb -l europe-west9 gs://tf-state-orange-training-NOM
```

### Active le versioning (Filet de sécurité)
```
gsutil versioning set on gs://tf-state-orange-training-NOM
```

## ON FAIT L'INSTALL du remote-state

# La Migration 
Lancez 
```
terraform init
```

Terraform va demander : "Do you want to copy existing state to the new backend?"
Réponse : YES.  

Une fois fait, supprimez le fichier terraform.tfstate local.  

Lancez 
```
terraform plan
``` 
Ça doit marcher sans fichier local.

Maintenant, le state est chez Google. Si je perds mon PC, je prends un nouveau PC, je fais git clone, terraform init, et je suis prêt à travailler. De plus, GCS gère le Locking. Si j'essaie d'appliquer pendant que Julien applique, Terraform me bloquera avec une erreur 423. Finis les conflits.  


## Q/R générale :  
Q : On doit versionner les modules ? 
R : "Absolument. En prod, on ne pointe jamais sur une branche main qui bouge tout le temps. On pointe sur un Tag Git (ex: source = "```git::https://github.com/orange/modules.git//vm?ref=v1.2.0```"). Comme ça, l'infra est immuable."

Q : Un module peut appeler un autre module ?
R : "Oui, c'est la composition. Mais attention à ne pas faire des "Poupées Russes" trop profondes (Nesting). 2 niveaux max, sinon ça devient in-débuggable."

Q : Et si le Bucket du state est supprimé ? 
R : "C'est pour ça qu'on a activé le Versioning sur le bucket à l'étape 1. On peut restaurer le fichier state d'il y a 10 minutes. Sans ça, vous êtes morts, il faut tout réimporter à la main."


## N'OUBLIEZ PAS DE DELETE LE BUCKET : 
```
gsutil rm -r -l europe-west9 gs://tf-state-orange-training-NOM
```
