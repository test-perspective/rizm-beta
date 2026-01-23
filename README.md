# Rizm (Beta)

Rizm is a self-hosted workspace system designed to run entirely in your own environment.

This repository provides beta releases and minimal documentation for early evaluation.

## Overview

Rizm enables teams to manage structured information in a configurable workspace.

- Runs on your own environment
- Workspace structure is defined by configuration
- Built-in web UI
- Designed for internal and team-level use

Exact capabilities depend on configuration and version.

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

- Docker and Docker Compose installed
  - **Windows/macOS**: Docker Desktop includes Docker Compose
  - **Linux**: Install Docker Engine and Docker Compose plugin
    - Ubuntu/Debian: `sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
    - See [Docker documentation](https://docs.docker.com/engine/install/) for other distributions

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

For production use with your own domain and automatic SSL certificates:

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
- Domain name pointing to your server's IP address
- Ports 80 and 443 open in your firewall
- Email address for Let's Encrypt certificate notifications

Access Rizm at: `https://your-domain.com`

### Manual Setup

If you prefer to set up manually:

1. Clone or download this repository
2. Copy `.env.example` to `.env` and edit as needed
3. Choose a compose file:
   - `compose/docker-compose.local.yml` for local testing
   - `compose/docker-compose.domain.yml` for domain deployment
4. Start with Docker Compose:
   ```bash
   docker compose -f compose/docker-compose.local.yml up -d
   # or
   docker compose -f compose/docker-compose.domain.yml up -d
   ```

### Default Credentials

After first startup, you can log in with:

- **Email**: `admin@example.local`
- **Password**: `change-this-password`

**Important**: Change the default password in production environments.

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

- GitHub Issues
- Discussions (if enabled)

## License

TBD

## Notes

This beta focuses on usability and operational feedback.
More details will be shared as the project evolves.
