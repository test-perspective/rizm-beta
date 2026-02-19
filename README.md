# Rizm (Beta)

**Language / 言語**: [English](README.md) | [日本語](README.ja.md)

---

Rizm is a self-hosted workspace system designed to run entirely in your environment.

This repository provides beta builds and minimal documentation for early evaluation.

**Try the demo**: [https://demo.test-perspective.com/](https://demo.test-perspective.com/)

To log in on the demo site, use **"Sign in as Admin"** on the login page.

## Overview

Rizm enables teams to manage structured information in a configurable workspace.

- Runs in your environment
- Workspace structure is defined by configuration
- Designed for internal/team use

Capabilities depend on your configuration and the version.

<img width="1476" height="831" alt="board" src="https://github.com/user-attachments/assets/e6a229e8-2739-410e-8aee-09ef50192e83" />

<p></p>

<img width="1482" height="824" alt="wiki" src="https://github.com/user-attachments/assets/45dca702-2cfd-4cc8-9181-fc97d0752272" />

<p></p>

**Start Guide**: For detailed instructions, see the [Rizm Start Guide](https://kenputer-documents.scrollhelp.site/rizm/rizm-start-guide).

## Beta Status

This is an early beta.

- Features and behavior may change
- Documentation is intentionally minimal
- Not recommended for mission-critical use

## Availability

- Self-hosted deployment
- No external services required for operation

## Getting Started

### Prerequisites

- Rizm requires Docker and Docker Compose (`docker compose`).
  - **Windows/macOS**: the setup scripts will install Docker Desktop if needed (and start it if installed)
  - **Linux**: `setup-linux.sh` will install Docker Engine and the Docker Compose plugin if missing (Ubuntu/Debian; requires `sudo`)
    - If your distribution is not supported, the script will stop and print manual install instructions: [Docker documentation](https://docs.docker.com/engine/install/)

### Getting the Repository

First, clone this repository to your local machine:

```bash
git clone https://github.com/test-perspective/rizm-beta.git
cd rizm-beta
```

If you don't have Git installed, you can download the repository as a ZIP file from [GitHub](https://github.com/test-perspective/rizm-beta) and extract it.

### Quick Start

#### Option 1: Local Testing (HTTP)

For quick local testing without a domain:

**Windows:**
```powershell
.\scripts\setup-win.cmd local
```

**Linux:**
```bash
bash ./scripts/setup-linux.sh local
```

**macOS:**
```bash
bash ./scripts/setup-macos.sh local
```

Access Rizm at: `http://localhost:8080`

To stop:

```bash
docker compose -f compose/docker-compose.local.yml down
```

If you get a permission error on Linux (e.g., Ubuntu 24), run:

```bash
sudo docker compose -f compose/docker-compose.local.yml down
```

#### Option 2: Domain Deployment (HTTPS)

For deployments with your own domain and automatic SSL certificates (Let's Encrypt):

**Windows:**
```powershell
.\scripts\setup-win.cmd domain your-domain.com your-email@example.com
```

**Linux:**
```bash
bash ./scripts/setup-linux.sh domain your-domain.com your-email@example.com
```

**macOS:**
```bash
bash ./scripts/setup-macos.sh domain your-domain.com your-email@example.com
```

**Requirements for domain mode:**
- A domain name pointing to your server's IP address
- Ports 80 and 443 open in your firewall
- An email address for Let's Encrypt notifications

Access Rizm at: `https://your-domain.com`

If your browser shows `ERR_SSL_UNRECOGNIZED_NAME_ALERT`, check the following on the server:

```bash
# 1) Make sure the domain is set in .env
cat .env | egrep '^(APP_DOMAIN|LETSENCRYPT_EMAIL)='

# 2) Make sure containers are running
sudo docker compose -f compose/docker-compose.domain.yml ps

# 3) Check proxy / ACME logs (certificate issuance + vhost)
sudo docker logs nginx-proxy --tail 200
sudo docker logs acme-companion --tail 200
```

Note: Let's Encrypt requires port 80 (HTTP) reachable from the Internet for HTTP-01 validation.

#### Attachment upload size limit (default and customization)

In domain mode, Rizm applies `client_max_body_size 512m;` by default via nginx-proxy, so new users can upload larger files without extra manual steps.

- Config file: `nginx-proxy/vhost.d/default`
- Default value: `512m`

To change the limit (example: 1 GB):

```bash
# 1) Edit the value
# client_max_body_size 1g;

# 2) Recreate proxy-related containers
docker compose -f compose/docker-compose.domain.yml up -d --force-recreate nginx-proxy web acme-companion

# 3) Verify applied config
docker compose -f compose/docker-compose.domain.yml exec nginx-proxy sh -lc "nginx -T 2>/dev/null | grep -n client_max_body_size"
```

#### MCP (HTTP)

Create an API key on the My Profile screen and enter it in `your-generated-api-key-here` below.

```json
{
  "mcpServers": {
    "rizm-http": {
      "url": "https://your-domain.com/api/mcp",
      "headers": {
        "Authorization": "Bearer your-generated-api-key-here"
      }
    }
  }
}
```

### Manual Setup

If you prefer to set up manually instead of using the setup scripts:

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/test-perspective/rizm-beta.git
   cd rizm-beta
   ```

2. **Copy the environment file**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and adjust settings as needed.

3. **Choose a compose file**:
   - `compose/docker-compose.local.yml` for local testing
   - `compose/docker-compose.domain.yml` for domain deployment

4. **Start with Docker Compose**:
   ```bash
   docker compose -f compose/docker-compose.local.yml up -d
   # or for domain deployment:
   docker compose -f compose/docker-compose.domain.yml up -d
   ```

### Default Credentials

After the first startup, you can log in with:

- **Email**: `admin@example.local`
- **Password**: `change-this-password`

**Important**: Change the default password before any real deployment.

### Managing the Installation

**Check status:**
```bash
docker compose -f compose/docker-compose.local.yml ps
```

**View logs:**
```bash
docker compose -f compose/docker-compose.local.yml logs -f
```

**Stop:**
```bash
docker compose -f compose/docker-compose.local.yml down
```

### Updating

To update to a newer version:

```bash
git pull
docker compose -f compose/docker-compose.local.yml pull
docker compose -f compose/docker-compose.local.yml up -d
```

For domain deployment, use `compose/docker-compose.domain.yml` instead.

## Feedback

Feedback is welcome and appreciated.

- **Contact**: support@test-perspective.com
- **Company**: Test Perspective Inc.
- [GitHub Issues](https://github.com/test-perspective/rizm-beta/issues)

## Licensing & Future Updates

### License for current version
The Docker images (Beta) provided by this repository are licensed under the **Apache License 2.0**.

- **Commercial/personal use:** Free to use.
- **Continued use:** There is no expiration for this version.

### Future updates
This project is under active development, and future releases may revise distribution, licensing, or support terms.

- New features or specific releases may be offered under terms different from the current license.
- If changes occur, we will announce them in this repository in advance or at the time of release.
- The currently published Apache 2.0 images will not become retroactively unavailable.

## Technology Stack

Overview of Rizm's technology stack. For a detailed dependency list (SBOM), see [THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES).

| Category | Main Technologies |
|----------|-------------------|
| **Frontend** | React, TypeScript, Tailwind CSS, Vite, MUI Material, BlockNote, Monaco Editor |
| **Backend** | Rust (Axum, Tokio) |
| **Infra / Middleware** | Docker, Nginx, SQLite |

Note: This distribution uses MUI X Data Grid Premium under the MUI X commercial license.

## License

Apache-2.0. See [`LICENSE`](LICENSE).

## Notes

This beta focuses on usability and operational feedback. More details will be shared as the project evolves.
