# Infrastructure Docker — WordPress · NGINX · MariaDB

> Stack web multi-conteneurs orchestree avec **Docker Compose**.
> _Projet **Inception** de l'ecole 42._

Mise en place d'une infrastructure web complete a l'aide de **Docker** et
**Docker Compose**, où chaque service tourne dans son propre conteneur construit
**à la main** (aucune image toute faite type `nginx`, `wordpress` ou `mariadb`
tiree du Hub).

L'infrastructure sert un site **WordPress** derriere un reverse proxy **NGINX**
accessible uniquement en **HTTPS (TLS 1.3)**, avec une base de donnees **MariaDB**.

---

## Architecture

```
                    HTTPS 443 (TLS 1.3)
   Navigateur  ───────────────────────────▶  ┌─────────────┐
                                              │    NGINX    │   seul point d'entree
                                              │  (port 443) │
                                              └──────┬──────┘
                                        FastCGI :9000 │
                                              ┌──────▼──────┐
                                              │  WordPress  │   php-fpm 8.2 + wp-cli
                                              │  (php-fpm)  │
                                              └──────┬──────┘
                                            MySQL :3306 │
                                              ┌──────▼──────┐
                                              │   MariaDB   │
                                              └─────────────┘

   Reseau Docker dedie : inception_network (bridge)
   Volumes persistants  : wordpress_data, mariadb_data  (bindes sur $DATA_PATH)
```

Chaque conteneur :

| Service     | Base            | Role                                                        |
|-------------|-----------------|-------------------------------------------------------------|
| **nginx**   | `debian:bookworm` | Reverse proxy, unique port expose (443), TLS 1.3, certificat auto-signe |
| **wordpress** | `debian:bookworm` | WordPress 6+ installe via wp-cli, servi par php-fpm 8.2   |
| **mariadb** | `debian:bookworm` | Base de donnees, initialisee au premier lancement          |

---

## Prerequis

- Docker et Docker Compose (v2)
- `make`

---

## Configuration

Les secrets et chemins ne sont **pas** versionnes. Avant le premier lancement :

```bash
cp srcs/.env.example srcs/.env
# puis editer srcs/.env avec vos identifiants et le bon DATA_PATH
```

Variables principales (voir `srcs/.env.example`) :

- `DATA_PATH` : dossier hote ou sont stockees les donnees (ex. `/home/login/data`)
- `MARIADB_*` : nom de base, utilisateurs et mots de passe MariaDB
- `WP_*` : URL, titre, et les **deux** utilisateurs WordPress
  (l'administrateur dont le login ne doit **pas** contenir `admin`, + un second utilisateur)

> Le fichier `srcs/.env` est ignore par git : vos mots de passe ne partent jamais sur GitHub.

---

## Utilisation

```bash
make          # cree les dossiers de donnees, build les images et lance la stack (detache)
make stop     # arrete les conteneurs
make start    # redemarre les conteneurs
make restart  # stop + start
make clean    # arrete et supprime conteneurs + volumes docker
make fclean   # nettoyage complet : conteneurs, images, volumes et donnees hote
make re       # fclean puis rebuild complet
```

### Acceder au site

1. Ajouter le domaine a votre fichier `hosts` :

   ```bash
   echo "127.0.0.1 login.42.fr" | sudo tee -a /etc/hosts
   ```

2. Ouvrir **https://login.42.fr** (accepter l'avertissement du certificat auto-signe).
3. Interface d'administration : `https://login.42.fr/wp-login.php`.

---

## Structure du projet

```
.
├── Makefile
├── README.md
└── srcs
    ├── .env.example          # modele de configuration (a copier en .env)
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── dockerfile
        │   └── conf
        │       ├── script.sh
        │       └── 50-server.cnf
        ├── nginx
        │   ├── dockerfile
        │   └── conf
        │       └── default
        └── wordpress
            ├── dockerfile
            └── conf
                ├── script.sh
                └── www.conf
```

---

## Choix techniques

- **Aucune image pre-faite** : chaque `dockerfile` part de `debian:bookworm`
  (avant-derniere version stable) et installe/configure le service manuellement.
- **PID 1 propre** : chaque conteneur lance son service au premier plan
  (`nginx -g "daemon off;"`, `mariadbd`, `php-fpm -F`) — pas de `tail -f`,
  `sleep infinity` ni hack de ce type.
- **Attente reelle des dependances** : le conteneur WordPress attend que MariaDB
  reponde via une boucle de test (pas de `sleep` arbitraire).
- **Persistance** : les donnees MariaDB et les fichiers WordPress vivent dans des
  volumes bindes sur l'hote, donc conservees entre les redemarrages.
- **Securite** : seul NGINX est expose (port 443), uniquement en TLS 1.3 ;
  les secrets sont hors depot.

---

## Notes de conformite (sujet 42)

- Un `Dockerfile` par service, ecrits main.
- Reseau Docker dedie (`networks` present, pas de `network: host` ni `--link`).
- NGINX seul point d'entree, port 443 uniquement, TLS 1.2/1.3.
- Deux utilisateurs WordPress, l'admin sans `admin` dans le nom.
- Pas de mot de passe en dur dans les Dockerfiles ; usage d'un `.env`.
