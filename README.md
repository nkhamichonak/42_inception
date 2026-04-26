# 42 Inception

A system administration and DevOps project built as part of the 42 curriculum. It provisions a small production-like infrastructure entirely from custom **Dockerfiles**, orchestrated with **Docker Compose** — covering containerisation, networking, persistent storage, and secure credential handling.

## Stack

| Service | Role | Base image |
|---------|------|------------|
| **NGINX** | TLS reverse proxy | Alpine 3.22 |
| **WordPress + PHP-FPM** | Application layer | Alpine 3.22 |
| **MariaDB** | Relational database | Alpine 3.22 |

All services run on a shared internal bridge network and communicate by container name. Credentials are passed via **Docker secrets** (mounted as files at `/run/secrets/`), never as plain environment variables.

## Project Description

### Architecture overview

```
srcs/
├── docker-compose.yaml
└── requirements/
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/nginx.conf
    ├── wordpress/
    │   ├── Dockerfile
    │   ├── conf/www.conf
    │   └── tools/entrypoint.sh
    ├── mariadb/
    │   ├── Dockerfile
    │   ├── conf/mariadb-server.cnf
    │   └── tools/entrypoint.sh
    └── tools/
        └── generate_secrets.sh
```

### Startup sequence

Each service defines a `healthcheck`; Docker Compose uses `depends_on: condition: service_healthy` to enforce a strict startup order:

```
MariaDB  →  (healthy)  →  WordPress  →  (healthy)  →  NGINX
```

MariaDB's entrypoint initialises the data directory, creates the database and user, then shuts down cleanly before handing off to the daemon. WordPress's entrypoint polls MariaDB with `mariadb-admin ping`, copies the WordPress core, creates `wp-config.php`, runs `wp core install`, and then starts `php-fpm83`. NGINX starts last and serves only after PHP-FPM is confirmed ready.

### Why Docker?

Docker allows services to run in isolated, reproducible environments. Each service has its own filesystem, its own dependencies, and a clearly defined role. This avoids configuration conflicts and makes the system easier to understand, debug, and redeploy.

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|-----------------|--------|
| Full operating system per VM | Shares host kernel |
| Heavy and slow to start | Lightweight and fast |
| Higher resource usage | Minimal overhead |
| Strong isolation | Process-level isolation |

Docker was chosen because it provides sufficient isolation while remaining lightweight and fast — ideal for service-based architectures.

### Secrets vs Environment Variables

| Environment Variables | Docker Secrets |
|----------------------|----------------|
| Stored in plain text | Stored securely |
| Visible via inspection | Mounted as files |
| Easy but unsafe for credentials | Designed for sensitive data |

Sensitive information such as database passwords is handled using **Docker secrets** to avoid leaking credentials through configuration files or container inspection.

### Docker Network vs Host Network

| Docker Network | Host Network |
|----------------|--------------|
| Isolated internal communication | No isolation |
| Services communicate by name | Direct host exposure |
| Safer and cleaner | Risk of port conflicts |

A custom bridge network (`inception`) is used so containers can communicate internally without exposing unnecessary ports to the host machine.

### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|----------------|-------------|
| Managed by Docker | Managed by host |
| Portable and safer | Host-path dependent |
| Recommended for production | Useful for development |

Named volumes bound to `/home/<login>/data/` are used for database and WordPress data, ensuring persistence across container restarts while keeping host dependencies minimal.

## Usage

### Dependencies

| Tool | Notes |
|------|-------|
| Docker | With Compose plugin (v2+) |
| Bash | For the secrets generation script |
| `openssl` | Used by `generate_secrets.sh` to create the self-signed TLS certificate |
| `make` | Build orchestration |

### Building

```bash
make
```

`make` creates the data directories, generates secrets and a self-signed TLS certificate, then calls `docker compose up --build -d`.

| Target | Effect |
|--------|--------|
| `make` / `make all` | Generate secrets, build images, start the stack |
| `make down` | Stop containers |
| `make clean` | Alias for `make down` |
| `make fclean` | Stop + remove containers, images, volumes, secrets, and data |
| `make re` | Full rebuild (`fclean` then `all`) |
| `make logs` | Tail all container logs |

### Running

After `make`, the WordPress site is accessible at:

```
https://<your-domain>/
```

The domain is configured via the `DOMAIN_NAME` variable in `srcs/.env`.

## Constraints

> 🛠️ **Note:**
> 42 project requirements that impact the design:
> - Each service must be built from a **custom Dockerfile** — using pre-built images (other than base OS images) is forbidden.
> - Containers must use **Alpine** or **Debian** as the base image.
> - `network: host`, `--link`, and `links:` are forbidden — inter-container communication must go through a proper Docker network.
> - Credentials must never appear in Dockerfiles or as plain environment variables.
> - Containers must restart automatically on failure.

⚠️ P.S. Don't copy, learn!

Made by: nkhamich@student.codam.nl
