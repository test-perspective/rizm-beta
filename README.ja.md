# Rizm（ベータ）

**Language / 言語**: [English](README.md) | [日本語](README.ja.md)

---

Rizm は、**あなたの環境内で完結して動作する**セルフホスト型ワークスペースです。

このリポジトリでは、**早期評価向けのベータ版**と、**最小限のセットアップ手順**のみを公開しています。

**デモサイト**: [https://demo.test-perspective.com/](https://demo.test-perspective.com/)

デモサイトでログインする場合は、ログイン画面の **「Sign in as Admin」** からログインしてください。

## 概要

Rizm は、設定可能なワークスペース上で、構造化された情報を扱うためのシステムです。

- 自社/自組織の環境で動作（セルフホスト）
- ワークスペースの構造は設定で定義
- チーム内・社内用途を想定

提供される機能は、設定やバージョンによって変わります。


<img width="1476" height="831" alt="board" src="https://github.com/user-attachments/assets/b9502fde-fe7d-49c2-b041-c58a8d4f32b5" />

<p></p>

<img width="1482" height="824" alt="wiki" src="https://github.com/user-attachments/assets/d87fe41b-f7d3-4938-8975-448164f043e6" />

<p></p>

**スタートガイド**: 詳細は [Rizm スタートガイド](https://kenputer-documents.scrollhelp.site/rizm/rizm-start-guide) を参照してください。

## ベータ版について

これは早期ベータ版です。

- 仕様や挙動は予告なく変更される可能性があります
- ドキュメントは意図的に最小限にしています
- 重要業務・ミッションクリティカル用途での利用は推奨しません

ロードマップ: https://github.com/test-perspective/rizm-beta/wiki/Roadmap

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

#### 1) ローカルで試す（HTTP）

**Windows**

```powershell
.\scripts\setup-win.cmd local
```

**Linux**

```bash
bash ./scripts/setup-linux.sh local
```

**macOS**

```bash
bash ./scripts/setup-macos.sh local
```

アクセス: `http://localhost:8080`

終了（停止）:

```bash
docker compose -f compose/docker-compose.local.yml down
```

Ubuntu 24 などで権限エラーになる場合:

```bash
sudo docker compose -f compose/docker-compose.local.yml down
```

#### 2) ドメインで運用する（HTTPS / Let's Encrypt）

**Windows**

```powershell
.\scripts\setup-win.cmd domain your-domain.com your-email@example.com
```

**Linux**

```bash
bash ./scripts/setup-linux.sh domain your-domain.com your-email@example.com
```

**macOS**

```bash
bash ./scripts/setup-macos.sh domain your-domain.com your-email@example.com
```

**ドメイン運用の要件**

- DNS がサーバーの IP を指していること
- ファイアウォールで `80/tcp` と `443/tcp` が開いていること
- Let's Encrypt 用の通知メールアドレス

アクセス: `https://your-domain.com`

ブラウザで `ERR_SSL_UNRECOGNIZED_NAME_ALERT` が出る場合、サーバー側で以下を確認してください:

```bash
# 1) .env にドメインが入っているか
cat .env | egrep '^(APP_DOMAIN|LETSENCRYPT_EMAIL)='

# 2) コンテナが起動しているか
sudo docker compose -f compose/docker-compose.domain.yml ps

# 3) proxy / ACME のログ（vhost生成・証明書発行）
sudo docker logs nginx-proxy --tail 200
sudo docker logs acme-companion --tail 200
```

※ Let's Encrypt は HTTP-01 検証のため、外部から `80/tcp` で到達できる必要があります。

#### 添付ファイルのアップロード上限（デフォルトと変更方法）

ドメイン運用では、nginx-proxy に `client_max_body_size 512m;` をデフォルト適用しています。  
新規ユーザーは追加の手作業なしで、比較的大きい添付ファイルを扱えます。

- 設定ファイル: `nginx-proxy/vhost.d/default`
- 既定値: `512m`

上限を変更したい場合（例: 1GB）:

```bash
# 1) 値を編集
# client_max_body_size 1g;

# 2) proxy関連コンテナを再作成
docker compose -f compose/docker-compose.domain.yml up -d --force-recreate nginx-proxy web acme-companion

# 3) 反映確認
docker compose -f compose/docker-compose.domain.yml exec nginx-proxy sh -lc "nginx -T 2>/dev/null | grep -n client_max_body_size"
```

#### MCP（HTTP）

My Profile 画面で API キーを作成し、以下の `your-generated-api-key-here` に記載してください。

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

### アップデート

新しいバージョンに更新する場合:

```bash
git pull
docker compose -f compose/docker-compose.local.yml pull
docker compose -f compose/docker-compose.local.yml up -d
```

ドメイン運用の場合は `compose/docker-compose.domain.yml` に読み替えてください。

## フィードバック

フィードバック歓迎です。

- **お問い合わせ**: support@test-perspective.com
- **会社名**: Test Perspective Inc.
- [GitHub Issues](https://github.com/test-perspective/rizm-beta/issues)
- [フォーラム（Q&A,アナウンス,ノウハウ、フィードバック）](https://forum.test-perspective.com/)

## ライセンスと今後の運用について

### 現行バージョンのライセンス
本リポジトリで提供している Docker イメージ（Beta版）は、**Apache License 2.0** を適用しています。

- **商用・個人利用:** 自由にご利用いただけます。
- **継続利用:** このバージョンに利用期限はありません。

### 将来のアップデートについて
本プロジェクトは現在開発中であり、将来のリリースにおいては、提供形態やライセンス、サポート体制を柔軟に見直す可能性があります。

- 今後追加される新機能や特定のリリースについては、現在のライセンスとは異なる条件が適用される場合があります。
- 変更がある場合は、事前またはリリース時に本リポジトリにてお知らせいたします。
- 現在公開している Apache 2.0 のイメージが、後から遡って利用不可になることはありません。

## 主要スタック

Rizm の技術スタック概要です。詳細な依存関係一覧（SBOM）は [THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES) を参照してください。

| カテゴリ | 主要技術 |
|----------|----------|
| **Frontend** | React, TypeScript, Tailwind CSS, Vite, MUI Material, BlockNote, Monaco Editor |
| **Backend** | Rust (Axum, Tokio) |
| **Infra / Middleware** | Docker, Nginx, SQLite |

※ 本配布物は MUI X 商用ライセンスに基づいて MUI X Data Grid Premium を使用しています。

## ライセンス

Apache-2.0（[`LICENSE`](LICENSE) を参照）

## 備考

このベータ版は、使い勝手や運用面のフィードバック収集を目的としています。  
プロジェクトの進展にあわせて、順次情報を追加していきます。

