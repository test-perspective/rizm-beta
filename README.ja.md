<p align="center">
  <img src="https://github.com/user-attachments/assets/b9502fde-fe7d-49c2-b041-c58a8d4f32b5" alt="ボードビュー" width="49%" />
  <img src="https://github.com/user-attachments/assets/d87fe41b-f7d3-4938-8975-448164f043e6" alt="Wikiビュー" width="49%" />
</p>

# AIネイティブなチームのためのセルフホスト型ワークスペース

**Language / 言語**: [English](README.md) | [日本語](README.ja.md)

[![GitHub Stars](https://img.shields.io/github/stars/test-perspective/rizm-beta?style=social)](https://github.com/test-perspective/rizm-beta/stargazers)
[![Latest Release](https://img.shields.io/github/v/release/test-perspective/rizm-beta)](https://github.com/test-perspective/rizm-beta/releases/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/license/apache-2-0)
[![X](https://img.shields.io/badge/X-@kenabe__tp-1DA1F2?logo=x)](https://x.com/kenabe_tp)
[![Forum](https://img.shields.io/badge/Forum-Community-blue)](https://forum.test-perspective.com/)

Rizm はあなたの環境内で完結して動作します。データ × マニフェスト = UI。AI管理者がワークフローに最適化されたUIを生成します。

[**ドキュメント**](https://kenputer-documents.scrollhelp.site/rizm/rizm-japanese) |
[**Changelog**](https://github.com/test-perspective/rizm-beta/releases) |
[**デモ**](https://demo.test-perspective.com/) |
[**フォーラム**](https://forum.test-perspective.com/)

## Why Rizm?

Rizm は、計画と実行を一つの流れの中で進められるセルフホスト型ワークスペースです。ボード、テーブル、共同編集できる Wiki で仕事を整理しながら、AI アシスタントがチャット経由でシステム設定やユーザー管理、保持データを使った処理を支援します。

## Features

| Feature | Description |
|---------|-------------|
| **プロジェクト管理** | ボード・テーブルビューで構造化された作業を管理 |
| **Wiki** | リアルタイム同期の共同編集 |
| **MCP** | AI連携のための Model Context Protocol サーバー |
| **AIアシスタント・管理者** | チャットでシステム設定やユーザー管理を行い、保持データを使った処理を支援 |

## Quick Start

Docker と Docker Compose（`docker compose`）が必要です。

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

`http://localhost:8080` でアクセス。デモではログイン画面の **「Sign in as Admin」** をクリック。初回起動後は `admin@example.local` / `change-this-password` でログインできます。

ドメイン運用、手動セットアップ、MCP 設定などの詳しい手順は [Wiki](https://github.com/test-perspective/rizm-beta/wiki) にまとめています。[Deployment-Guide](https://github.com/test-perspective/rizm-beta/wiki/Deployment-Guide)、[Deployment-Guide.ja](https://github.com/test-perspective/rizm-beta/wiki/Deployment-Guide.ja)、[MCP-Setup](https://github.com/test-perspective/rizm-beta/wiki/MCP-Setup)、[Licensing-and-Future-Updates](https://github.com/test-perspective/rizm-beta/wiki/Licensing-and-Future-Updates) を参照してください。

## Feedback & Community

- [GitHub Issues](https://github.com/test-perspective/rizm-beta/issues)
- [フォーラム](https://forum.test-perspective.com/)（Q&A、アナウンス、ノウハウ、フィードバック）
- [X @kenabe_tp](https://x.com/kenabe_tp)
- support@test-perspective.com

## Technology Stack

| カテゴリ | 主要技術 |
|----------|----------|
| **Frontend** | React, TypeScript, Tailwind CSS, Vite, MUI Material, BlockNote, Monaco Editor |
| **Backend** | Rust (Axum, Tokio) |
| **Infra / Middleware** | Docker, Nginx, SQLite |

依存関係一覧（SBOM）は [THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES) を参照。本配布物は MUI X 商用ライセンスに基づき MUI X Data Grid Premium を使用しています。

## License

このリリースは Apache-2.0 で提供されています。詳しくは [LICENSE](LICENSE) を参照してください。ライセンス方針や今後の更新に関する案内は [Licensing-and-Future-Updates](https://github.com/test-perspective/rizm-beta/wiki/Licensing-and-Future-Updates) にまとめています。

## Current Status

Rizm は現在も継続的に改善中のため、仕様や挙動は変更される可能性があり、ドキュメントも意図的に最小限にしています。重要業務での利用は推奨していません。今後の方向性については [Roadmap](https://github.com/test-perspective/rizm-beta/wiki/Roadmap) を参照してください。
