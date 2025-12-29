*This project has been created as part of the 42 curriculum by nkhamich@student.codam.nl.*

# Inception

## Description

**Inception** is a system administration and DevOps project whose goal is to introduce containerisation using **Docker** and **Docker Compose**.

The project consists of building a small infrastructure composed of several services running in isolated containers, all orchestrated through Docker Compose. Each service is built from scratch using custom Dockerfiles, following strict security and configuration rules.

The stack includes:
- An **NGINX** web server acting as a reverse proxy
- A **WordPress** application running with **PHP-FPM**
- A **MariaDB** database
- Persistent storage through Docker volumes
- Secure handling of credentials via Docker secrets
- A dedicated Docker network for inter-container communication

The emphasis is on understanding how these services interact, why containers are used instead of virtual machines, and how data, networking, and secrets are managed in a production-like setup.

---

## Instructions

### Prerequisites

- Linux or macOS
- Docker
- Docker Compose
- Bash (for the secrets script)

### Build and Run

To build and start the entire stack:

```bash
make
```

To stop the services:

```bash
make down
```

To completely clean containers, images, volumes, and data:

```bash
make fclean
```

---

## Project Description: Design and Technical Choices

### Why Docker?

Docker allows services to run in isolated, reproducible environments. Each service has:

* Its own filesystem
* Its own dependencies
* A clearly defined role

This avoids configuration conflicts and makes the system easier to understand, debug, and redeploy.

### Virtual Machines vs Docker

| Virtual Machines             | Docker                  |
| ---------------------------- | ----------------------- |
| Full operating system per VM | Shares host kernel      |
| Heavy and slow to start      | Lightweight and fast    |
| Higher resource usage        | Minimal overhead        |
| Strong isolation             | Process-level isolation |

Docker was chosen because it provides sufficient isolation while remaining lightweight and fast — ideal for service-based architectures.

---

### Secrets vs Environment Variables

| Environment Variables           | Docker Secrets              |
| ------------------------------- | --------------------------- |
| Stored in plain text            | Stored securely             |
| Visible via inspection          | Mounted as files            |
| Easy but unsafe for credentials | Designed for sensitive data |

Sensitive information such as database passwords is handled using **Docker secrets** to avoid leaking credentials through configuration files or container inspection.

---

### Docker Network vs Host Network

| Docker Network                  | Host Network           |
| ------------------------------- | ---------------------- |
| Isolated internal communication | No isolation           |
| Services communicate by name    | Direct host exposure   |
| Safer and cleaner               | Risk of port conflicts |

A custom Docker network is used so containers can communicate internally without exposing unnecessary ports to the host machine.

---

### Docker Volumes vs Bind Mounts

| Docker Volumes             | Bind Mounts            |
| -------------------------- | ---------------------- |
| Managed by Docker          | Managed by host        |
| Portable and safer         | Host-path dependent    |
| Recommended for production | Useful for development |

Volumes are used for database and WordPress data to ensure persistence across container restarts while keeping host dependencies minimal.

---

## Resources

### Documentation and References

* Docker documentation: [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose documentation: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* NGINX documentation: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
* MariaDB documentation: [https://mariadb.com/kb/en/documentation/](https://mariadb.com/kb/en/documentation/)
* WordPress documentation: [https://wordpress.org/support/](https://wordpress.org/support/)

### Use of AI

AI tools were used **as a learning and support aid**, not as a code generator. Specifically:

* To clarify Docker, networking, and volume concepts
* To understand best practices for container security
* To review configuration decisions and spot potential mistakes
* To help structure documentation clearly

All configuration files, Dockerfiles, and scripts were written manually and adapted to the project’s constraints.

---

## Notes

This project focuses on **understanding infrastructure**, not just making it work. Every configuration choice is intentional and aims to reflect real-world deployment practices while respecting the constraints of the 42 curriculum.
