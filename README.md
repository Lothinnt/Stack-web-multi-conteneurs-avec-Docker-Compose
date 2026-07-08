# Stack web multi-conteneurs avec Docker Compose

Infrastructure WordPress auto-hébergée avec des images Docker buildées à la main :

- **NGINX** en reverse proxy HTTPS
- **WordPress** sur **php-fpm**
- **MariaDB**
- orchestration via **Docker Compose**
- chiffrement forcé en **TLS 1.3**

## Structure

- `docker-compose.yml` : orchestration des 3 services
- `srcs/requirements/nginx` : image NGINX + conf TLS 1.3
- `srcs/requirements/wordpress` : image php-fpm + installation WordPress
- `srcs/requirements/mariadb` : image MariaDB + bootstrap BDD

## Lancer le projet

1. Copier le fichier d'environnement :
   ```bash
   cp .env.example .env
   ```
2. Adapter les variables dans `.env`
3. Construire et démarrer :
   ```bash
   docker compose up --build -d
   ```
4. Ouvrir `https://localhost`

## Arrêter le projet

```bash
docker compose down
```
