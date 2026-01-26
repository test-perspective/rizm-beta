# Rizm（ベータ）

**Language / 言語**: [English](README.md) | [日本語](README.ja.md)

---

Rizm は、**あなたの環境内で完結して動作する**セルフホスト型ワークスペースです。

このリポジトリでは、**早期評価向けのベータ版**と、**最小限のセットアップ手順**のみを公開しています。

**デモサイト**: [https://demo.test-perspective.com/](https://demo.test-perspective.com/)

## 概要

Rizm は、設定可能なワークスペース上で、構造化された情報を扱うためのシステムです。

- 自社/自組織の環境で動作（セルフホスト）
- ワークスペースの構造は設定で定義
- チーム内・社内用途を想定

提供される機能は、設定やバージョンによって変わります。

## ベータ版について

これは早期ベータ版です。

- 仕様や挙動は予告なく変更される可能性があります
- ドキュメントは意図的に最小限にしています
- 重要業務・ミッションクリティカル用途での利用は推奨しません

## 提供形態

- セルフホスト（オンプレ/自前クラウド）で動作します
- 動作に必須の外部サービスはありません

## はじめに

### 前提（Docker / Docker Compose）

Rizm の起動には **Docker** と **Docker Compose**（`docker compose`）が必要です。

- **Windows / macOS**: `setup-*` スクリプトが Docker Desktop を未導入ならインストールします（導入済みならそのまま起動します）
- **Linux**: `setup-linux.sh` が Docker Engine / Docker Compose plugin を未導入ならインストールします（Ubuntu/Debian想定、`sudo` が必要です）  
  ※対応外ディストリビューションの場合はエラーで止まり、手動インストール案内を表示します（公式手順: [Docker Engine install](https://docs.docker.com/engine/install/)）

### リポジトリの取得

まず、このリポジトリをローカルマシンにクローンします：

```bash
git clone https://github.com/test-perspective/rizm-beta.git
cd rizm-beta
```

Gitがインストールされていない場合は、[GitHub](https://github.com/test-perspective/rizm-beta)からZIPファイルとしてダウンロードして展開することもできます。

### クイックスタート

**スタートガイド**: 詳細は [Rizm スタートガイド](https://kenputer-documents.scrollhelp.site/rizm/rizm-start-guide) を参照してください。

#### 1) ローカルで試す（HTTP）

**Windows**

```powershell
.\scripts\setup-win.ps1 --mode local
```

**Linux**

```bash
./scripts/setup-linux.sh local
```

**macOS**

```bash
./scripts/setup-macos.sh local
```

アクセス: `http://localhost:8080`

#### 2) ドメインで運用する（HTTPS / Let’s Encrypt）

**Windows**

```powershell
.\scripts\setup-win.ps1 --mode domain --domain your-domain.com --email your-email@example.com
```

**Linux**

```bash
./scripts/setup-linux.sh domain your-domain.com your-email@example.com
```

**macOS**

```bash
./scripts/setup-macos.sh domain your-domain.com your-email@example.com
```

**ドメイン運用の要件**

- DNS がサーバーの IP を指していること
- ファイアウォールで `80/tcp` と `443/tcp` が開いていること
- Let’s Encrypt 用の通知メールアドレス

アクセス: `https://your-domain.com`

### 手動で起動する

セットアップスクリプトを使わずに手動でセットアップする場合：

1. **リポジトリをクローン**（まだの場合）:
   ```bash
   git clone https://github.com/test-perspective/rizm-beta.git
   cd rizm-beta
   ```

2. **環境ファイルをコピー**:
   ```bash
   cp .env.example .env
   ```
   `.env` を編集して、必要に応じて設定を調整してください。

3. **起動用の compose ファイルを選ぶ**:
   - `compose/docker-compose.local.yml`（ローカル用）
   - `compose/docker-compose.domain.yml`（ドメイン運用用）

4. **Docker Compose で起動**:
   ```bash
   docker compose -f compose/docker-compose.local.yml up -d
   # またはドメイン運用の場合:
   docker compose -f compose/docker-compose.domain.yml up -d
   ```

### デフォルトログイン

初回起動後、以下でログインできます。

- **メールアドレス**: `admin@example.local`
- **パスワード**: `change-this-password`

本番運用では、必ずパスワードを変更してください。

### 起動状態の確認 / ログ / 停止

※ `compose/docker-compose.local.yml` は必要に応じて読み替えてください。

**ステータス**

```bash
docker compose -f compose/docker-compose.local.yml ps
```

**ログ**

```bash
docker compose -f compose/docker-compose.local.yml logs -f
```

**停止**

```bash
docker compose -f compose/docker-compose.local.yml down
```

## フィードバック

フィードバック歓迎です。

- [GitHub Issues](https://github.com/test-perspective/rizm-beta/issues)

## ライセンス

Apache-2.0（[`LICENSE`](LICENSE) を参照）

## 備考

このベータ版は、使い勝手や運用面のフィードバック収集を目的としています。  
プロジェクトの進展にあわせて、順次情報を追加していきます。
