# Terraform Docker Configuration

Cette configuration Terraform permet de déployer l'infrastructure Docker du projet TP Final avec le provider Docker.

## Prérequis

- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- Docker Desktop ou Docker Engine en cours d'exécution
- Les Dockerfiles doivent être présents dans les dossiers `backend/` et `frontend/`
- Les scripts SQL d'initialisation dans le dossier `database/` (`00-init.sql` et `01-populate.sql`)

## Structure des fichiers

- `providers.tf` - Configuration du provider Docker
- `variables.tf` - Déclaration des variables
- `terraform.tfvars` - Valeurs par défaut des variables
- `main.tf` - Ressources Docker (réseau, volumes, conteneurs)
- `outputs.tf` - Outputs affichés après déploiement

## Configuration

### Variables disponibles

Vous pouvez modifier les valeurs dans `terraform.tfvars` :

```hcl
# Database configuration
postgres_user          = "postgres"
postgres_password      = "password123"
postgres_db            = "tpfinal"

# Ports
backend_port           = 8081
frontend_port          = 3000
postgres_external_port = 5434  # Port externe pour PostgreSQL
backend_external_port  = 8081
```

### Adaptation pour Linux/Mac

Si vous êtes sur Linux ou Mac, modifiez le fichier `providers.tf` :

```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"  # Linux/Mac
  # host = "npipe:////./pipe/docker_engine"  # Windows
}
```

## Utilisation

### 1. Initialisation

Initialiser Terraform et télécharger le provider Docker :

```bash
cd terraform
terraform init
```

### 2. Planification

Vérifier les ressources qui seront créées :

```bash
terraform plan
```

### 3. Déploiement

Créer l'infrastructure :

```bash
terraform apply
```

Terraform affichera les ressources à créer et demandera confirmation. Tapez `yes` pour continuer.

### 4. Vérification

Après le déploiement, Terraform affichera les outputs :

- URL du frontend : `http://localhost:3000`
- URL du backend : `http://localhost:8081`
- Port PostgreSQL : `5434`

Vérifier que les conteneurs sont en cours d'exécution :

```bash
docker ps
```

Vous devriez voir 3 conteneurs actifs :
- `tp-final-db` (PostgreSQL - status: healthy)
- `tp-final-backend` (Backend Go)
- `tp-final-frontend` (Frontend)

Vérifier les logs en cas de problème :

```bash
docker logs tp-final-backend
docker logs tp-final-db
docker logs tp-final-frontend
```

### 5. Destruction

Pour supprimer toute l'infrastructure :

```bash
terraform destroy
```

## Ressources créées

1. **Réseau Docker** : `clicker-network` (bridge)
   - Alias réseau : `postgres` (pour le conteneur PostgreSQL)
2. **Volume** : `postgres_data` (données PostgreSQL persistantes)
3. **Images Docker** :
   - `postgres:15-alpine` (image officielle)
   - `tp-final-backend:latest` (build depuis `../backend`)
   - `tp-final-frontend:latest` (build depuis `../frontend`)
4. **Conteneurs** :
   - `tp-final-db` (PostgreSQL 15-alpine avec healthcheck)
   - `tp-final-backend` (Application backend Go)
   - `tp-final-frontend` (Application frontend Nginx)

## Commandes utiles

### Voir l'état actuel de l'infrastructure

```bash
terraform show
```

### Afficher uniquement les outputs

```bash
terraform output
```

### Valider la configuration sans appliquer

```bash
terraform validate
```

### Formater les fichiers Terraform

```bash
terraform fmt
```

## Dépannage

### Erreur de connexion Docker

Si Terraform ne peut pas se connecter à Docker :

- Vérifiez que Docker Desktop est démarré
- Sous Windows, vérifiez que le named pipe est correct dans `providers.tf`
- Sous Linux/Mac, vérifiez les permissions sur `/var/run/docker.sock`

### Ports déjà utilisés

Si vous obtenez une erreur "bind: address already in use" :

1. Vérifiez quel processus utilise le port :
   ```bash
   # Windows
   netstat -ano | findstr :5434

   # Linux/Mac
   lsof -i :5434
   ```

2. Modifiez le port dans `terraform.tfvars` :
   ```hcl
   postgres_external_port = 5435  # Changer le port
   frontend_port = 3001           # Si 3000 est occupé
   ```

3. Réappliquez la configuration :
   ```bash
   terraform apply
   ```

### Backend ne peut pas se connecter à PostgreSQL

Si le backend affiche "Failed to ping database: no such host" :

- Vérifiez que l'alias réseau "postgres" est bien configuré dans `main.tf`
- Assurez-vous que le conteneur PostgreSQL est démarré et "healthy"
- Vérifiez les logs : `docker logs tp-final-db`

### Nettoyer les anciens conteneurs

Avant de déployer avec Terraform, nettoyez les anciens conteneurs Docker Compose :

```bash
docker ps -a  # Lister tous les conteneurs
docker stop <container_id>  # Arrêter les conteneurs
docker rm <container_id>    # Supprimer les conteneurs
```

### Rebuild des images

Pour forcer la reconstruction des images Docker :

```bash
terraform taint docker_image.backend
terraform taint docker_image.frontend
terraform apply
```

Ou détruire et recréer complètement :

```bash
terraform destroy
terraform apply
```

## Différences avec Docker Compose

### Avantages de Terraform

- **Gestion d'état** : Terraform gère l'état de l'infrastructure (fichier `.tfstate`)
- **Tracking des modifications** : Permet de versionner et suivre les modifications
- **Infrastructure as Code** : Configuration déclarative et reproductible
- **CI/CD** : Peut être intégré dans des pipelines CI/CD
- **Multi-environnements** : Permet de gérer plusieurs environnements (dev, staging, prod)
- **Plan avant exécution** : `terraform plan` montre ce qui va être modifié avant de l'appliquer
- **Dependency management** : Gère automatiquement les dépendances entre ressources

### Comparaison avec Docker Compose

| Fonctionnalité | Docker Compose | Terraform |
|----------------|----------------|-----------|
| Simplicité | Plus simple pour démarrer | Configuration plus détaillée |
| État | Pas de gestion d'état | Fichier `.tfstate` |
| Plan | Pas de preview | `terraform plan` |
| Multi-provider | Docker uniquement | Peut gérer cloud, DNS, etc. |
| Production | Dev/Test | Dev + Production |

## Architecture réseau

Le conteneur PostgreSQL possède deux identifiants réseau :
- Nom du conteneur : `tp-final-db`
- Alias réseau : `postgres` (utilisé par le backend pour la connexion)

Cela permet au backend d'utiliser `DB_HOST=postgres` pour se connecter, tout comme avec Docker Compose.

## Fichiers importants

- `.terraform/` - Cache du provider (ne pas versionner)
- `.terraform.lock.hcl` - Lock file des providers (versionner)
- `terraform.tfstate` - État actuel de l'infrastructure (ne pas versionner, contient des secrets)
- `terraform.tfstate.backup` - Backup de l'état précédent (ne pas versionner)
- `.gitignore` - Exclut les fichiers sensibles du versioning
