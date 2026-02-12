# Terraform - Cheat sheet

> Objectif : pour chaque commande, **quand** on l'utilises.

---

## Plan / Apply

### `terraform plan`
**Cas d’usage général :**
- Prévisualiser **exactement** ce qui va changer avant de toucher l’infra.
- Revue en PR/MR : on veut un diff lisible (ajouts/modifs/destructions).
- Détection de drift (quelqu’un a modifié à la main / config a bougé).

**Options utiles :**
- `-var-file=dev.tfvars`  
  > Charger un set de variables (souvent par environnement).
- `-var="x=y"`  
  > Surcharger une variable à la volée (debug/CI), à éviter pour la prod (traçabilité).
- `-out=tfplan`   
  > Générer un plan “figé” (reproductible) à appliquer tel quel.
- `-refresh=false` *(rare, debug)*  
  > Ne pas relire l’état réel. Utile pour diagnostiquer un plan lent ou des appels API instables, **mais** peut masquer du drift.
- `-target=...` *(à éviter sauf urgence)*  
  > Cibler une ressource précise quand on dois débloquer une situation (hotfix). Risque : contourne une partie des dépendances.
- `-destroy`  
  > Simuler une destruction complète pour valider l’impact avant un arrêt d’environnement.

**Exemples :**
```
terraform plan -var-file=dev.tfvars
terraform plan -var-file=dev.tfvars -out tfplan
terraform plan -destroy -out destroy.plan
```

---

### `terraform apply`
**Cas d’usage général :**
- Appliquer les changements calculés par Terraform.
- En équipe : appliquer **le plan validé** (pas un recalcul au moment du apply).

**Options utiles :**
- `terraform apply tfplan` ✅  
  > Applique exactement le plan généré (recommandé en CI/prod).
- `-auto-approve` *(CI uniquement, avec garde-fous)*  
  > Pas de prompt interactif. À réserver à des pipelines protégés (branch protections, approvals, envs).

**Exemples :**
```
terraform apply tfplan
terraform apply -auto-approve   # pipeline contrôlé
```

---

### `terraform destroy`
**Cas d’usage général :**
- Détruire un environnement éphémère (sandbox, review app, POC).
- Nettoyer une infra de test pour réduire coûts.
- Décommissionner proprement (quand tout est bien dans le state).

**Options utiles :**
- `-target=...` *(dangereux)*  
  > Détruire un composant spécifique (ex: une ressource coincée). Très risqué si dépendances.
- `-auto-approve`  
  > Mode non interactif (CI), à protéger.

**Exemples :**
```
terraform destroy -var-file=dev.tfvars
terraform destroy -auto-approve  # CI
terraform destroy -target=aws_instance.web
```
FYI : Evitez de destroy une ressource directement  
Preferez cette méthode : plan + destroy si le résultat est bon
```
terraform plan -destroy -target=module.app.aws_instance.web
terraform destroy -target=module.app.aws_instance.web
```
Note supplémentaire :  
pour voir les targets 
```
terraform state list
```
---

## Infos & introspection

### `terraform show`
**Cas d’usage général :**
- Lire un `tfplan` pour comprendre le détail (utile en CI).
- Inspecter le state (ou un plan) quand tu débug un diff surprenant.

**Exemples :**
```
terraform show tfplan
terraform show
```

---

### `terraform output`
**Cas d’usage général :**
- Récupérer un endpoint, un ID, un ARN, une URL de LB… pour enchaîner avec un autre step (tests, déploiement).
- En CI : passer des infos à l’étape suivante.

**Option utile :**
- `-json`  
  > Format machine-friendly (CI / scripts).

**Exemples :**
```
terraform output
terraform output -json
terraform output my_endpoint
```

---

### `terraform providers`
**Cas d’usage général :**
- Auditer quels providers sont utilisés (et lesquels viennent des modules).
- Diagnostiquer un souci de versions/compatibilités de providers.

**Exemple :**
```
terraform providers
```

---

### `terraform console`
**Cas d’usage général :**
- Tester une expression HCL avant de la mettre dans le code :
  - `for` / `if` / `flatten` / `merge`
  - `jsonencode`, `yamldecode`, `cidrsubnet`, etc.
- Débugger des `locals`/variables complexes.

**Exemple :**
```
terraform console
```

---

### `terraform graph`
**Cas d’usage général :**
- Comprendre pourquoi l’ordre d’exécution est bizarre.
- Visualiser les dépendances entre modules/resources (debug gros stacks).

**Exemple :**
```
terraform graph | dot -Tsvg > graph.svg
```

---

## Gestion du state (mode “admin”)

### `terraform state list`
**Cas d’usage général :**
- Voir ce que Terraform **pense** gérer (inventaire).
- Retrouver l’adresse exacte (`<addr>`) d’une ressource pour `show/mv/rm/import`.

**Exemple :**
```
terraform state list
```

---

### `terraform state show <addr>`
**Cas d’usage général :**
- Comprendre pourquoi Terraform veut changer un champ.
- Vérifier la valeur actuelle dans le state (IDs, attributs calculés, etc.).

**Exemple :**
```
terraform state show aws_security_group.this
```

---

### `terraform state mv <old> <new>`
**Cas d’usage général :**
- Refactor/rename **sans recréer** (ex : renommer une ressource, déplacer dans un module).
- Migration de structure quand on range le code.

> Note : souvent remplacé par un bloc `moved {}` (refacto versionné dans le code).

**Exemple :**
```
terraform state mv aws_security_group.old aws_security_group.this
```

---

### `terraform state rm <addr>`
**Cas d’usage général :**
- Sortir une ressource de la gestion Terraform **sans la détruire** :
  - ressource désormais gérée ailleurs
  - ressource à “décrocher” pour stopper les diffs
- Débloquer une situation (ressource supprimée à la main mais encore dans le state).

⚠️ Risque : Terraform “oublie” la ressource. Si on la redéclare ensuite, il peut vouloir la recréer.

**Exemple :**
```
terraform state rm aws_s3_bucket.logs
```

---

### `terraform refresh` # Utile à l'ancienne
**Cas d’usage général :**
- Forcer une resynch state <> réel (surtout pour diagnostiquer).
- Aujourd’hui, on préfère souvent `plan/apply` qui refresh déjà.

**Exemple :**
```
terraform refresh -var-file=dev.tfvars
```

---

### `terraform taint` / `terraform untaint`
**Cas d’usage général :**
- Marquer une ressource pour **recréation** au prochain apply (ex : elle est “cassée” mais Terraform ne voit pas pourquoi).
- Commande plutôt legacy : utile encore sur certains workflows.

**Exemples :**
```
terraform taint aws_instance.web
terraform untaint aws_instance.web
```

---

## `plan` / `apply` / `destroy` sans options 

### `terraform plan` (sans options)
Terraform utilise :
- les valeurs par défaut (`default`) dans `variables.tf`
- `terraform.tfvars` et les `*.auto.tfvars` (si présents)
- les variables d’environnement `TF_VAR_*` (si utilisées)

**Commande :**
```
terraform plan
```

---

### `terraform apply`
Terraform **recalcule un plan** au moment du `apply`, l’affiche, puis demande confirmation.

**Commande :**
```
terraform apply
```

> En prod/CI, on préfère souvent :
```
terraform plan -out tfplan
terraform apply tfplan
```
Pour appliquer **exactement** le plan relu/validé.

---

### `terraform destroy` 
Détruit **tout ce qui est géré par ce state** (donc tout ce que ce dossier/root module gère), puis demande confirmation.

**Commande :**
```
terraform destroy
```

---

### Pré-requis pour que ça marche
- être dans le **bon dossier** (bon environnement)
- `terraform init` déjà fait (providers + backend OK)
- credentials provider OK (AWS/Azure/GCP…)
- variables obligatoires renseignées (defaults, tfvars, env vars…)

---

### Tip “safe” en multi-env
Évite les erreurs de dossier avec `-chdir` :

```bash
terraform -chdir=envs/dev plan
terraform -chdir=envs/dev apply
terraform -chdir=envs/dev destroy
```
