# User Documentation

## Overview

This project deploys a small web stack using Docker Compose. The stack provides:

* **Nginx** — a web server that handles HTTP requests.
* **WordPress** — the website and administration interface.
* **PHP-FPM** — executes PHP code used by WordPress.
* **MariaDB** — the database storing WordPress content and users.

All services run in isolated containers and communicate over a private Docker network.

---

## Starting and Stopping the Project

### Start

From the root of the repository:

```bash
make
```

This builds the images (if needed) and starts all containers in the background.

### Stop

```bash
make down
```

This stops and removes the containers while keeping persistent data intact.

### Full Cleanup (including data)

```bash
make fclean
```

This removes containers, images, and all persisted data. Use with care.

---

## Accessing the Website

* **Website**: open your browser and go to

```
https://localhost
```

* **WordPress admin panel**:

```
https://localhost/wp-admin
```

Log in using the administrator credentials defined in the secrets.

---

## Credentials Management

Credentials are **not hard-coded**. They are generated once during project startup and stored as Docker secrets.

You can find them in:

```
secrets/
```

Typical secrets include:

* Database root password
* WordPress database user password
* WordPress admin password
* WordPress user password

To change credentials:

1. Edit the corresponding file in `secrets/`.
2. Rebuild and restart the stack:

```bash
make re
```

---

## Checking Service Status

### List running containers

```bash
docker ps
```

All services should be in a `running` or `healthy` state.

### Inspect logs

```bash
docker compose logs
```

For a specific service:

```bash
docker compose logs nginx
```

### Health checks

MariaDB and WordPress containers expose health checks. Docker Compose waits for these before starting dependent services.

---

## Common Issues

* **Website not reachable**: ensure containers are running and ports are not already in use.
* **Database connection errors**: verify secrets and restart the stack.
* **Permission issues**: check that the data directories exist and are writable.
