<p align="center">
  <img src="https://github.com/user-attachments/assets/e6a229e8-2739-410e-8aee-09ef50192e83" alt="Board view" width="49%" />
  <img src="https://github.com/user-attachments/assets/45dca702-2cfd-4cc8-9181-fc97d0752272" alt="Wiki view" width="49%" />
</p>

# Self-hosted workspace for AI-native teams

**Language / 言語**: [English](README.md) | [日本語](README.ja.md)

[![GitHub Stars](https://img.shields.io/github/stars/test-perspective/rizm-beta?style=social)](https://github.com/test-perspective/rizm-beta/stargazers)
[![Latest Release](https://img.shields.io/github/v/release/test-perspective/rizm-beta)](https://github.com/test-perspective/rizm-beta/releases/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/license/apache-2-0)
[![X](https://img.shields.io/badge/X-@kenabe__tp-1DA1F2?logo=x)](https://x.com/kenabe_tp)
[![Forum](https://img.shields.io/badge/Forum-Community-blue)](https://forum.test-perspective.com/)

Rizm runs entirely in your environment. Data × Manifest = UI. Have the AI Administrator generate a UI optimized for your workflow.

[**Docs**](https://rizm.test-perspective.com/) |
[**Changelog**](https://github.com/test-perspective/rizm-beta/releases) |
[**Demo**](https://demo.test-perspective.com/) |
[**Forum**](https://forum.test-perspective.com/)

## Why Rizm?

Rizm is a self-hosted workspace built to keep planning and execution in one continuous flow. Teams can manage work in boards, tables, and a collaborative wiki, while the AI Assistant helps with chat-based administration, user management, and actions that use the data already stored in the workspace.

## Features

| Feature | Description |
|---------|-------------|
| **Project management** | Board and table views for structured work |
| **Wiki** | Collaborative editing with real-time sync |
| **MCP** | Model Context Protocol server for AI integration |
| **AI Assistant & Administrator** | Chat-based system administration, user management, and context-aware actions using stored workspace data |

## Quick Start

Requires Docker and Docker Compose (`docker compose`).

```bash
git clone https://github.com/test-perspective/rizm-beta.git
cd rizm-beta
```

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

Access Rizm at `http://localhost:8080`. Log in with **Sign in as Admin** on the demo, or use the default credentials after first run: `admin@example.local` / `change-this-password`.

For domain deployment, manual setup, MCP configuration, and other operational details, see the [Wiki](https://github.com/test-perspective/rizm-beta/wiki). Useful starting points are [Deployment Guide](https://github.com/test-perspective/rizm-beta/wiki/Deployment-Guide) and [MCP Setup](https://github.com/test-perspective/rizm-beta/wiki/MCP-Setup).

## Feedback & Community

- [GitHub Issues](https://github.com/test-perspective/rizm-beta/issues)
- [Forum](https://forum.test-perspective.com/) (Q&A, Announcements, How-to, Feedback)
- [X @kenabe_tp](https://x.com/kenabe_tp)
- support@test-perspective.com

## Technology Stack

| Category | Main Technologies |
|----------|-------------------|
| **Frontend** | React, TypeScript, Tailwind CSS, Vite, MUI Material, BlockNote, Monaco Editor |
| **Backend** | Rust (Axum, Tokio) |
| **Infra / Middleware** | Docker, Nginx, SQLite |

For a detailed dependency list (SBOM), see [THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES). This distribution uses MUI X Data Grid Premium under the MUI X commercial license.

## License

This release is licensed under Apache-2.0. See [LICENSE](LICENSE). For licensing policy and future update notes, see [Licensing and Future Updates](https://github.com/test-perspective/rizm-beta/wiki/Licensing-and-Future-Updates).

## Current Status

Rizm is still evolving, so features and behavior may change, and the documentation is intentionally minimal. It is not recommended for mission-critical use. See the [Roadmap](https://github.com/test-perspective/rizm-beta/wiki/Roadmap) for planned direction.
