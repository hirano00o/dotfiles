# ラベル・線種・色の規約

draw.io 上のラベル、接続線、グループ境界の表記規約。
本ファイルは描画時 (Step 6.3) に必ず参照する。

---

## ノードラベル

### 基本形 (AWS リソース)

2 行構成:

```
1行目: 日本語の役割名
2行目: AWS リソース名 (英語、kebab-case)
```

| 例 | 1 行目 | 2 行目 |
| --- | --- | --- |
| 認証基盤 | 認証基盤 | cognito-user-pool-prod |
| アプリケーション | アプリケーション | app-ecs-service-prod |
| 商品マスタ DB | 商品マスタDB | products-docdb-cluster-prod |
| 注文 API | 注文API | order-api-alb-prod |

XML 上の表記:

```xml
value="認証基盤&#xa;cognito-user-pool-prod"
```

- **改行は `&#xa;` のみ** (HTML タグの `<br/>` は禁止)
- 半角空白での詰めや全角空白での装飾は禁止
- 1 行目に絵文字を入れない

### 外部サービス

英語のみ 1 行。日本語併記しない:

```
GitHub
GitHub Actions
Okta
saml2aws
Developer
```

### 略号と命名

- AWS の正式略号は使ってよい (ALB, NLB, IAM, KMS, ACM, WAF, MWAA, MSK, ECR, EKS)
- 独自略号は **避ける** (例: "DDB" よりも "DynamoDB")
- リソース名は terraform の `name` 属性をそのまま (整形しない)

---

## エッジ (接続線) ラベル

形式: `プロトコル/ポート (認証方式)` の順。

### プロトコル/ポート 標準形

| プロトコル | 標準ラベル |
| --- | --- |
| HTTP | `HTTP/80` |
| HTTPS | `HTTPS/443` |
| gRPC | `gRPC/{port}` (例: `gRPC/50051`) |
| MongoDB | `MongoDB/27017` |
| PostgreSQL | `PostgreSQL/5432` |
| MySQL | `MySQL/3306` |
| Redis | `Redis/6379` |
| SSH | `SSH/22` |
| SMTP | `SMTP/25` または `SMTPS/465` |
| DNS | `DNS/53` |
| TCP (汎用) | `TCP/{port}` |
| UDP (汎用) | `UDP/{port}` |
| AWS API | `AWS API` (港番号は省略) |
| イベント | `Event` (SNS/SQS/EventBridge 等の非同期) |

### 認証方式 標準形

カッコ内に追記する。

| 認証方式 | 標準ラベル |
| --- | --- |
| OIDC (Cognito 経由) | `(OIDC via Cognito)` |
| SAML (Okta 等) | `(SAML via Okta)` |
| IAM 認証 | `(IAM auth)` |
| mTLS | `(mTLS)` |
| mTLS (Service Connect) | `(mTLS via Service Connect)` |
| Basic 認証 | `(Basic Auth)` |
| API Key | `(API Key)` |
| Pre-shared Key | `(PSK)` |
| 認証なし/省略 | (カッコ自体を省略) |

### 例

```
HTTPS/443 (OIDC via Cognito)
TCP/27017 (SSL/TLS)
gRPC/50051 (mTLS via Service Connect)
PostgreSQL/5432 (IAM auth)
HTTPS/443
Event
```

XML 上の表記 (Edge の `value`):

```xml
<mxCell ... value="HTTPS/443 (OIDC via Cognito)" edge="1" ...>
```

---

## グループラベル

### VPC

```
1行目: VPC (CIDR)
2行目: VPC リソース名
```

例:

```
VPC (10.0.0.0/16)
vpc-prod-main
```

### Subnet

```
1行目: Public Subnet | Private Subnet | Isolated Subnet
2行目: CIDR, AZ
```

例:

```
Public Subnet
10.0.1.0/24, ap-northeast-1a
```

### AZ (Availability Zone)

AZ 名のみ 1 行:

```
ap-northeast-1a
```

### Security Group

```
1行目: SG: {役割}
2行目: sg-名 (terraform 上の name)
```

例:

```
SG: ALB ingress
alb-sg-prod
```

### Account

```
1行目: アカウント名
2行目: 12桁ID
```

例:

```
prod account
123456789012
```

### Region

```
ap-northeast-1
```
1 行のみ。

### 外部

```
External Services
```

---

## 線種と色

### 線種

| 用途 | 線種 (XML 表記) | 用例 |
| --- | --- | --- |
| 通常通信 (同期) | 実線 (default) | API 呼び出し、HTTPS リクエスト |
| 認証/認可委譲 | 実線 + 矢印装飾 (`endArrow=open`) | Cognito 経由の token 検証 |
| 非同期/イベント | 破線 (`dashed=1`) | SNS, SQS, EventBridge |
| 外部サービス接続 | 破線 (`dashed=1`) | GitHub, Okta 等 |
| 管理/監視 | 点線 (`dashed=1;dashPattern=1 1`) | CloudWatch Logs, Metrics |

### 色 (strokeColor)

| 用途 | カラーコード | 補足 |
| --- | --- | --- |
| 通常通信 (default) | `#545B64` | グレー、判別しやすい中間色 |
| セキュリティ関連 | `#DD344C` | 認証/認可の流れに使う |
| データフロー (書き込み) | `#7AA116` | S3 PUT, DB INSERT 等 |
| データフロー (読み取り) | `#1F5B9E` | S3 GET, DB SELECT 等 |

### 色数の上限

- **1 図につき 3 色まで**。それ以上は視覚ノイズになる
- 通常通信の `#545B64` は色数にカウントしないが、それ以外を 3 色以内に抑える
- 例: ある図で「通常 + セキュリティ赤 + 非同期破線グレー + 書き込み緑」
  → セキュリティ赤・非同期破線・書き込み緑で 3 色 → OK
- 4 色以上が必要なら、図を分割する (Step 5 の判断材料にする)

---

## 凡例 (Legend)

各図の左下に **必ず凡例** を配置する。1 つの mxCell グループにまとめる:

```
凡例
─── 通常通信
─── セキュリティ
- - - 非同期/イベント
··· 管理/監視
```

凡例には **その図で実際に使われている線種のみ** を記載する。

---

## アンチパターン

以下は **絶対に行わない**。

| アンチパターン | 理由 | 正しい方法 |
| --- | --- | --- |
| ラベルなしの接続線 | 何の通信か読み手が判らない | 必ず `value` を設定 (最低限プロトコルを書く) |
| HTML タグの使用 (`<br/>`, `<b>`) | draw.io で正しく描画されない場合がある | 改行は `&#xa;`、装飾は `fontStyle` で |
| アイコンより大きいフォント | アイコンが見えなくなる | `fontSize=12` を上限に |
| 5 行以上の長大ラベル | 読みにくく、レイアウト崩れの原因 | 解説書 (.md) 側に分離 |
| 絵文字 (🔒, ⚠️, 🚀 等) | 描画環境差で文字化けし得る | テキストで表記 |
| カラーコードを直接書き換え | カテゴリ色規約に反する | `references/aws4-shapes.md` の表に従う |
| 同種リソースを縦並びに無限増殖 | 図がスクロールできなくなる | 「× 3」等の注記で 1 アイコンに集約 |

---

## 描画チェックリスト

描画完了時に以下を確認する:

- [ ] すべての接続線にラベル (プロトコル/ポート) が付いている
- [ ] ノードラベルが日本語+英語の 2 行
- [ ] HTML タグを使っていない (`grep '<br' *.drawio` で 0 件)
- [ ] 絵文字を使っていない
- [ ] VPC/Subnet/AZ 境界が描かれている
- [ ] 凡例が左下にある
- [ ] 色は 3 色以内
- [ ] 各 ResourceIcon に `description` 属性で tf パスが記録されている
