# Developer Documentation

This document explains how to set up, build, run, and maintain this Inception project **as it is implemented in this repository**. It assumes no prior knowledge of the internal scripts or Docker setup.

---

## 1. Prerequisites

You need the following installed on your system:

* **Docker** (engine + CLI)
* **Docker Compose v2** (available via `docker compose`)
* **GNU Make**
* **OpenSSL** (used for generating TLS certificates and secrets)

Your user must be allowed to run Docker commands without `sudo`.

---

## 2. Project Layout

```
.
├── Makefile
├── secrets/
│   ├── *.txt
│   └── certificate/
│       ├── cert.pem
│       └── key.pem
├── srcs/
│   ├── docker-compose.yaml
│   ├── .env
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       ├── wordpress/
│       └── tools/
│           └── generate_secrets.sh
```

Key points:

* **`srcs/`** is the Docker Compose project directory.
* **`secrets/`** is created at runtime and stores generated credentials and TLS files.
* **Persistent data** is stored on the host, outside the repository, under `/home/<LOGIN>/data/`. If LOGIN is not explicitly provided when running `make`, it defaults to `nkhamich` as defined in the Makefile.

---

## 3. Environment Configuration

### `.env` file

The file `srcs/.env` must exist before running the project. It defines non-secret configuration values such as:

* Database name and user
* WordPress admin and user names/emails
* Domain name

Secrets **must not** be stored in this file.

---

## 4. Secrets and Certificates

Secrets are generated automatically via a dedicated script.

### Secret generation

The Makefile target `secrets` runs:

```
srcs/requirements/tools/generate_secrets.sh
```

This script:

* Loads variables from `srcs/.env`
* Generates strong random passwords (if missing)
* Creates Docker secret files under `secrets/`
* Generates a self-signed TLS certificate for HTTPS

Generated files include:

* `secrets/db_password.txt`
* `secrets/db_root_password.txt`
* `secrets/wp_admin_password.txt`
* `secrets/wp_user_password.txt`
* `secrets/certificate/cert.pem`
* `secrets/certificate/key.pem`

A summary file `secrets/credentials.txt` is also created for convenience.

Permissions are set restrictively (`600` for secrets, `644` for public certs).

---

## 5. Data Persistence

Persistent data is stored **on the host**, outside Docker, using bind-mounted volumes.

Paths are derived from the `LOGIN` variable:

```
/home/<LOGIN>/data/mysql
/home/<LOGIN>/data/wordpress
```

These directories are:

* Created automatically by `make`
* Mounted into containers via Docker volumes
* Preserved across container restarts and rebuilds

Removing containers does **not** delete this data.

---

## 6. Building and Running the Project

### 6.1 Default build and start

From the repository root:

```bash
make
```

This command:

1. Creates host data directories
2. Generates secrets and certificates (if missing)
3. Builds Docker images
4. Starts all services in detached mode

### 6.2 Stop containers

```bash
make down
```

Containers are stopped, but data and secrets remain.

### 6.3 Full cleanup

```bash
make fclean
```

This:

* Stops containers
* Removes images and volumes
* Deletes generated secrets and certificates

Persistent data directories are **not** removed automatically.

---

## 7. Container and Service Management

### View running containers

```bash
docker ps
```

### View logs

```bash
make logs
```

or directly:

```bash
docker compose --project-directory srcs logs -f
```

### Enter a container

```bash
docker exec -it wordpress sh
```

---

## 8. Service Dependencies and Health Checks

Services are started in a strict order using health checks:

* **MariaDB** must accept connections
* **WordPress** must finish setup and start PHP-FPM
* **Nginx** starts only after WordPress is healthy

Health checks are defined in `docker-compose.yml` and actively prevent race conditions during startup.

---

## 9. Notes for Development

* Secrets are injected via Docker secrets, not environment variables.
* Containers communicate exclusively through the `inception` bridge network.
* TLS is terminated at Nginx using a self-signed certificate.
* No service relies on external networks or unmanaged volumes.

This setup is intentionally explicit and deterministic to match Inception evaluation requirements.
