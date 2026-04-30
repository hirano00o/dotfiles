# Terraform モジュール → AWS サービス展開マッピング

`module "xxx" { source = "../../modules/yyy" }` の `yyy` 部分を、
描画対象の AWS サービス群に展開するためのマッピング表。

本ファイルに記載のないモジュールは **推測せず、ユーザーに確認** すること。
確認後は本ファイルへの追記を提案する。

---

## compute 系

### `modules/ecs-service-bluegreen`

Blue/Green デプロイ対応の ECS Service。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_ecs_service` | 1 | Fargate 起動タイプ |
| `aws_ecs_task_definition` | 1 | サイドカー含む |
| `aws_lb_listener` (prod) | 1 | 本番トラフィック用 |
| `aws_lb_listener` (test) | 1 | カナリア検証用 |
| `aws_lb_target_group` (blue) | 1 | 現行リビジョン |
| `aws_lb_target_group` (green) | 1 | 新リビジョン |
| `aws_codedeploy_app` | 1 | Compute platform = ECS |
| `aws_codedeploy_deployment_group` | 1 | TrafficRoutingConfig 含む |
| `aws_iam_role` (task / execution / codedeploy) | 3 | |
| `aws_cloudwatch_log_group` | 1 | コンテナログ |

描画上の表現:

- ECS Service (Fargate) アイコン中央
- 左に ALB (Listener × 2 で prod/test を分岐表示)
- 下に Target Group blue/green を 2 つ並べ、点線でリンク
- CodeDeploy アイコンを右上、Service への矢印 (label: "Blue/Green deploy")
- Log Group は CloudWatch Logs アイコンとして点線で接続

### `modules/ecs-service-standard`

通常の Rolling デプロイ版 ECS Service。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_ecs_service` | 1 | deployment_controller = ECS |
| `aws_ecs_task_definition` | 1 | |
| `aws_lb_listener` | 1 | |
| `aws_lb_target_group` | 1 | |
| `aws_iam_role` | 2 | task / execution |
| `aws_cloudwatch_log_group` | 1 | |

描画は `bluegreen` 版から CodeDeploy / Listener × 2 / TG × 2 を除いた形。

### `modules/lambda-function`

汎用 Lambda モジュール。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_lambda_function` | 1 | |
| `aws_iam_role` | 1 | execution role |
| `aws_iam_role_policy_attachment` | n | |
| `aws_cloudwatch_log_group` | 1 | `/aws/lambda/{name}` |
| `aws_security_group` | 0 or 1 | VPC 接続時のみ |
| `aws_lambda_permission` | n | trigger ごと |

描画上の表現:

- Lambda アイコン
- VPC 接続有なら VPC 境界内に配置 (private subnet)
- VPC 接続無なら境界外
- Log Group を点線で接続

---

## data 系

### `modules/documentdb-cluster`

MongoDB 互換の DocumentDB クラスタ。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_docdb_cluster` | 1 | |
| `aws_docdb_cluster_instance` | 3 | Multi-AZ 想定 |
| `aws_docdb_subnet_group` | 1 | private subnet |
| `aws_security_group` | 1 | port 27017 |
| `aws_secretsmanager_secret` | 1 | master credentials |
| `aws_secretsmanager_secret_version` | 1 | |

描画上の表現:

- DocumentDB アイコン × 3 (各 AZ に 1 つずつ private subnet 内に配置)
- Secrets Manager アイコンを右に配置、矢印 (label: "credentials")
- SSL/TLS 証明書配布が sidecar 経由なら、ECS Task 側に注記する

### `modules/dynamodb-table`

DynamoDB テーブル + GSI + Streams。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_dynamodb_table` | 1 | |
| `aws_iam_policy` | 1 | テーブル操作用 |

`stream_enabled = true` なら DynamoDB Streams 矢印を Lambda 等に向けて描く。
GSI は属性として注釈に書く (アイコンは複製しない)。

### `modules/s3-bucket-standard`

汎用 S3 バケット。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_s3_bucket` | 1 | |
| `aws_s3_bucket_policy` | 1 | |
| `aws_s3_bucket_versioning` | 1 | |
| `aws_s3_bucket_server_side_encryption_configuration` | 1 | |
| `aws_s3_bucket_lifecycle_configuration` | 0 or 1 | |
| `aws_s3_bucket_notification` | 0 or 1 | event → SQS/SNS/Lambda |

描画上の表現:

- S3 アイコン
- Notification があれば矢印 (label: "ObjectCreated:* → Lambda")
- Lifecycle は注記のみ (アイコン重複させない)

---

## analytics 系

### `modules/athena-workgroup`

Athena ワークグループ + Glue カタログ + 結果バケット。
主に ALB アクセスログ等の分析に使う。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_athena_workgroup` | 1 | |
| `aws_glue_catalog_database` | 1 | |
| `aws_glue_catalog_table` | 1+ | |
| `aws_s3_bucket` (結果) | 1 | |
| `aws_iam_role` | 1 | |

描画上の表現:

- Athena アイコン中央
- Glue アイコンを左に (label: "table catalog")
- S3 (結果バケット) を下に
- 分析対象の S3 (ALB ログ等) からの矢印は破線 (非同期/バッチ)

### `modules/mwaa-env`

Managed Workflows for Apache Airflow 環境。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_mwaa_environment` | 1 | |
| `aws_s3_bucket` (DAGs) | 1 | |
| `aws_security_group` | 1 | |
| `aws_iam_role` | 1 | execution role |
| (VPC は既存を参照) | - | private subnet 必須 |

描画上の表現:

- MWAA アイコンを VPC private subnet 内に配置
- DAGs S3 を境界外、矢印 (label: "DAGs sync")
- **DAG の実行対象** (ECS Task, Lambda, Glue Job 等) を **点線矢印** で結ぶ
  (実体はジョブ実行の関係で、常時通信ではないため点線)

---

## auth 系

### `modules/cognito`

Cognito User Pool 一式。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_cognito_user_pool` | 1 | |
| `aws_cognito_user_pool_client` | 1+ | |
| `aws_cognito_user_pool_domain` | 1 | |
| `aws_cognito_identity_provider` | 0+ | OIDC/SAML フェデレーション |

描画上の表現:

- Cognito アイコン
- 外部 IdP (Okta, Google 等) があれば境界外に配置、矢印 (label: "SAML/OIDC")
- 認証対象アプリ (ALB, AppSync 等) からの矢印 (label: "OIDC via Cognito")

---

## network 系

### `modules/vpc-standard`

標準 VPC。Multi-AZ で 3 種類のサブネットを持つ。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_vpc` | 1 | |
| `aws_subnet` (public) | 3 | Multi-AZ |
| `aws_subnet` (private) | 3 | Multi-AZ |
| `aws_subnet` (isolated) | 3 | DB 等用、NAT 経由不可 |
| `aws_internet_gateway` | 1 | |
| `aws_nat_gateway` | 1 or 3 | コスト/可用性で選択 |
| `aws_route_table` | 数本 | |
| `aws_route_table_association` | n | |
| `aws_flow_log` | 0 or 1 | VPC Flow Logs |

描画上の表現:

- VPC 境界 (`group_vpc`)
- 内部に Public Subnet × 3, Private Subnet × 3, Isolated Subnet × 3
- IGW を Public Subnet 上端、NAT を Public 内
- Flow Log があれば CloudWatch Logs アイコンを点線で接続

### `modules/alb-standard`

汎用 Application Load Balancer。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_lb` (type=application) | 1 | |
| `aws_lb_listener` (HTTPS:443) | 1 | |
| `aws_lb_listener_rule` | n | |
| `aws_acm_certificate` | 1 | |
| `aws_route53_record` (alias) | 1 | |
| `aws_security_group` | 1 | |

描画上の表現:

- ALB アイコンを Public Subnet 内
- ACM アイコンを左 (label: "TLS cert")
- Route 53 を上 (label: "alias record")

### `modules/vpc-endpoint`

VPC Endpoint (Interface / Gateway)。

| AWS リソース | 個数 | 備考 |
| --- | --- | --- |
| `aws_vpc_endpoint` | 1+ | |
| `aws_security_group` | 0 or 1 | Interface 型のみ |
| (Private DNS) | - | 属性で表現 |

描画上の表現:

- PrivateLink アイコン (Interface) または Gateway アイコン (Gateway)
- 利用元 (ECS, Lambda 等) からの矢印 (label: "via PrivateLink")
- 接続先 AWS サービス (S3, DynamoDB 等) を境界外に置く

---

## 外部サービス

VPC / アカウント境界の **外側に点線で配置** する。

| 名称 | 配置位置 | 備考 |
| --- | --- | --- |
| GitHub | 境界外右上 | CodeBuild / CodeDeploy / Actions の連携元 |
| GitHub Actions | GitHub の下 | Actions runner |
| saml2aws | 境界外左下 | 開発者端末からのアクセスパス |
| Okta | 境界外左上 | SAML IdP |
| 開発者端末 | 境界外左下 | saml2aws / kubectl 等の起点 |

外部サービスは:

- 英語名 1 行のラベル (日本語併記しない)
- AWS4 アイコンセットに無いので汎用アイコンまたはラベルのみで表現
- AWS リソースとの間は **破線** で接続

---

## 未登録モジュールへの対処

本マッピング表に無いモジュールが見つかった場合:

1. **モジュールの中身を推測しない**
2. ユーザーに以下を確認する:
   - 「`modules/{name}` の中身を見ますか? それとも展開を教えてもらえますか?」
3. ユーザーが中身を見る指示なら、`terraform/modules/{name}/*.tf` を読んで
   AWS リソース一覧を抽出する
4. 確定したマッピングを **本ファイルに追記する提案** を行う:
   ```markdown
   ### `modules/{name}`

   ...展開内容...
   ```
5. ユーザーが了承したら本ファイルを更新する

未登録モジュールがあった旨は、Step 8 の自己検証時に **必ず報告** すること。
