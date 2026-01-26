# Rizm (Beta)

**Language / 言語**: [English](README.md) | [日本語](README.ja.md)

---

Rizm is a self-hosted workspace system designed to run entirely in your environment.

This repository provides beta builds and minimal documentation for early evaluation.

**Try the demo**: [https://demo.test-perspective.com/](https://demo.test-perspective.com/)

## Overview

Rizm enables teams to manage structured information in a configurable workspace.

- Runs in your environment
- Workspace structure is defined by configuration
- Designed for internal/team use

Capabilities depend on your configuration and the version.

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
  - **Linux**: `setup-linux.sh` will install Docker Engine and the Docker Compose plugin if missing (Ubuntu/Debian; requires `sudo`)  \n+    If your distribution is not supported, the script will stop and print manual install instructions: [Docker documentation](https://docs.docker.com/engine/install/)

### Getting the Repository

First, clone this repository to your local machine:

```bash
git clone https://github.com/test-perspective/rizm-beta.git
cd rizm-beta
```

If you don't have Git installed, you can download the repository as a ZIP file from [GitHub](https://github.com/test-perspective/rizm-beta) and extract it.

### Quick Start

**Start Guide**: For detailed instructions, see the [Rizm Start Guide](https://kenputer-documents.scrollhelp.site/rizm/rizm-start-guide).

#### Option 1: Local Testing (HTTP)

For quick local testing without a domain:

**Windows:**
```powershell
.\scripts\setup-win.ps1 --mode local
```

**Linux:**
```bash
./scripts/setup-linux.sh local
```

**macOS:**
```bash
./scripts/setup-macos.sh local
```

Access Rizm at: `http://localhost:8080`

#### Option 2: Domain Deployment (HTTPS)

For deployments with your own domain and automatic SSL certificates (Let’s Encrypt):

**Windows:**
```powershell
.\scripts\setup-win.ps1 --mode domain --domain your-domain.com --email your-email@example.com
```

**Linux:**
```bash
./scripts/setup-linux.sh domain your-domain.com your-email@example.com
```

**macOS:**
```bash
./scripts/setup-macos.sh domain your-domain.com your-email@example.com
```

**Requirements for domain mode:**
- A domain name pointing to your server's IP address
- Ports 80 and 443 open in your firewall
- An email address for Let’s Encrypt notifications

Access Rizm at: `https://your-domain.com`

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

## Feedback

Feedback is welcome and appreciated.

- [GitHub Issues](https://github.com/test-perspective/rizm-beta/issues)

## License

Apache-2.0. See [`LICENSE`](LICENSE).

## Notes

This beta focuses on usability and operational feedback. More details will be shared as the project evolves.
