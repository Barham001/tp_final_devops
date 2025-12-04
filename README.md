# TP final

## Participants
- Alexis Rouseré
- Barham Bahadin
- Uriel Arthur Millogo

## Propriétés d'environnement

Afin que le `docker-compose` puisse fonctionner, commencez par créer un fichier `.env` à la racine du projet.

Certaines propriétés sont importantes pour le bon fonctionnement de l'application :
- `POSTGRES_USER` : nom d'utilisateur de la BDD
- `POSTGRES_PASSWORD` : mot de passe pour la BDD
- `POSTGRES_DB` : nom de la BDD
- `BACKEND_PORT` : port du service backend (ex: 8081)
- `FRONTEND_PORT` : port du service (ex: 80)
- `DB_PORT` : port de la BDD (ex: 5432)
- `DATABASE_URL` : lien de la BDD (ex: postgres://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@postgres:\${DB_PORT}/${POSTGRES_DB})

## Lancement de l'application

Pour lancer l'architecture, veuillez suivre ces étapes :
- Se placer dans la racine du projet
- Exécuter la commande `docker-compose up --build`
- Attendre quelques instants puis aller sur `localhost:FRONTEND_PORT` (en sachant qu'il faut remplacer FRONTEND_PORT par le port défini dans `.env`)
- Enjoy !