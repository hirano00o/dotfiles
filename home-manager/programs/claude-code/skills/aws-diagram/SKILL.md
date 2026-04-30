---
name: aws-diagram
description: TerraformコードからAWS構成図(.drawio)を生成する。「構成図を書いて」「アーキテクチャ図を作成」「AWS構成をdraw.ioで可視化」等の指示で発動。terraform/配下のHCLコードとterraform showのJSON出力を解析し、draw.io XMLを生成する。awslabs/aws-architecture-diagram skill(awslabs/agent-plugins の deploy-on-aws)が利用可能な場合は描画エンジンとして委譲し、無い場合は同梱の references/aws4-shapes.md を参照して自律生成する。ハルシネーション防止のための自己検証ステップを含む。
---

# AWS Architecture Diagram Generator

Terraform コードから AWS 構成図 (`.drawio`) を生成する skill。
描画エンジンを二段構えにし、awslabs 公式 skill があればそちらに委譲、無ければ
同梱の references を参照して自律生成する。

---

## 絶対ルール (最優先)

### ハルシネーション防止

1. **Terraform コードに実在するリソースのみ図示する。推測補完は禁止**
   - NG例: 「CloudFront があるから Lambda@Edge もあるはず」 → コードに無ければ描かない
   - NG例: 「ALB があるから WAF もあるだろう」 → `aws_wafv2_*` が無ければ描かない
   - NG例: 「ECS があるから ECR もあるはず」 → `aws_ecr_*` が無ければ描かない
2. **shape 名が `references/aws4-shapes.md` に無い → ユーザーに確認**
   - 推測した名前で `resIcon=mxgraph.aws4.xxx` を書いてはいけない
3. **モジュール名が `references/modules-map.md` に無い → ユーザーに確認**
   - 中身を読まずに「たぶんこういう構成だろう」と推測しない

### スタイル

- AWS4 公式アイコン (`mxgraph.aws4` namespace) のみ使用する
- VPC / Subnet (public/private/isolated) / AZ 境界を必ず明示する
- 接続線には必ずラベルを付ける (プロトコル/ポート/認証方式)
- ラベルは「日本語の役割名」+「英語のリソース名」の 2 行構成
- 1 図につきカテゴリ色は 3 色まで

### 出力先

- 構成図: `docs/architecture/{env}-{scope}.drawio`
- 解説書: `docs/architecture/{env}-{scope}.md` (両者は **必ずセットで** 生成)
- 既存ファイルは上書きしてよい (git で履歴は残る)

---

## Workflow

### Step 1: 入力の決定

ユーザー指示から以下 2 つを抽出する:

| 変数 | デフォルト | 推定キーワード |
| --- | --- | --- |
| `env` | `prod` | `prod`, `stg`, `dev`, `production`, `staging`, `development` |
| `scope` | `overview` | 下表 |

`scope` の推定:

| キーワード (日本語/英語) | scope |
| --- | --- |
| ネットワーク / VPC / サブネット / network | `network` |
| コンピュート / ECS / Lambda / アプリ / app / compute | `compute` |
| データ / DB / DocumentDB / DynamoDB / ストレージ / S3 / data | `data` |
| パイプライン / CI / CD / デプロイ / MWAA / pipeline | `pipeline` |
| 全体 / 概観 / overview / 指定なし | `overview` |

複数キーワードが当てはまる場合は **ユーザーに確認**。勝手に分割を始めない。

### Step 2: 入力パスの特定

| 種類 | パス |
| --- | --- |
| ルートモジュール | `terraform/envs/{env}/` |
| 共通モジュール | `terraform/modules/**/*.tf` |
| 除外 | `terraform/legacy/`, `terraform/sandbox/`, `*.tfstate*`, `.terraform/` |

パスが見つからない場合 (リポジトリ構成が異なる場合) は、ユーザーに正しいパスを
確認する。推測で `src/infra/` 等を探さない。

### Step 3: Terraform 解析

#### 3.1 リソースとモジュールの抽出

```bash
grep -rE '^(resource|module|data) "' terraform/envs/{env}/ terraform/modules/ \
  --include='*.tf'
```

#### 3.2 module 呼び出しの展開

抽出した `module "xxx" { source = "../../modules/yyy" }` について、
`references/modules-map.md` でサービス展開を確認する。

- 登録済み → そのとおりに展開
- 未登録 → **ユーザーに確認** し、確認後は `modules-map.md` に追記を提案

#### 3.3 plan.json の活用

`count` / `for_each` / 変数依存が多い場合、ユーザーに以下を提案する:

```bash
cd terraform/envs/{env}
terraform plan -out=plan.binary
terraform show -json plan.binary > plan.json
```

`plan.json` が **存在すればそちらを正として優先する** (実際にデプロイされる
リソースが確定するため)。

### Step 4: 描画エンジンの選択

以下のパスを順に確認する:

```bash
ls ~/.claude/plugins/awslabs/agent-plugins/deploy-on-aws/skills/aws-architecture-diagram/SKILL.md 2>/dev/null
ls .claude/plugins/awslabs/agent-plugins/deploy-on-aws/skills/aws-architecture-diagram/SKILL.md 2>/dev/null
```

| 結果 | アクション |
| --- | --- |
| 存在する | `awslabs/aws-architecture-diagram` skill に描画を委譲 |
| 存在しない | `references/aws4-shapes.md` を参照して自律生成 |

**どちらを選んでも Step 5 以降の規約は必ず適用する**。委譲先が出力した XML が
規約 (AWS4 アイコン使用、VPC 境界明示、接続線ラベル等) に違反していたら、
こちらで補正する。

### Step 5: 観点の確定と分割判断

**描画対象が 12 サービス超** なら以下の 4 分割を提案する:

| scope | 含むサービス例 |
| --- | --- |
| `network` | VPC, Subnet, ALB, NAT, IGW, VPC Endpoint, Route53, WAF |
| `compute` | ECS Fargate, Lambda, ALB 経路, 認証 (Cognito, Okta) |
| `data` | DocumentDB, DynamoDB, S3, Athena, Glue, Backup |
| `pipeline` | MWAA, CodeBuild, CodeDeploy, ECR, GitHub Actions |

12 サービス未満なら 1 枚の `overview` で OK。境界判定はサービス種別 (resource type)
の **ユニーク数** で行う (同種リソースが複数あっても 1 とカウント)。

ユーザーが分割を了承したら、scope ごとに Step 6 を繰り返す。

### Step 6: 描画の実行

#### 6.1 shape 名の確定

- `references/aws4-shapes.md` の resIcon 表で確定する
- 表に **無い** 場合 → 推測せずユーザーに確認
- カテゴリをまたいだ色混在は禁止 (例: Lambda を Database 紫で描かない)

#### 6.2 グループ境界

`references/aws4-shapes.md` の grIcon 表に従い以下を必ず描く:

- AWS Account (12 桁 ID 表示)
- Region (`ap-northeast-1` 等)
- VPC (CIDR 表示)
- Subnet (Public/Private/Isolated, AZ 表示)
- Security Group (主要なもの)

#### 6.3 ラベルと接続線

- ラベル: `references/label-rules.md` の規約
- 接続線: 必ずプロトコル/ポート/認証方式を表示

#### 6.4 トレーサビリティ

各 `mxCell` の `description` 属性に **対応 tf ファイルのパス:行番号** を記録する:

```xml
<mxCell id="alb_main" value="..." style="..."
        description="terraform/envs/prod/network.tf:42">
```

これにより、図 → コード への逆引きが可能になる。

### Step 7: 出力

2 ファイルを **必ずセットで** 生成する:

#### 7.1 `docs/architecture/{env}-{scope}.drawio`

draw.io XML 本体。

#### 7.2 `docs/architecture/{env}-{scope}.md`

解説書。最低限以下を含める:

```markdown
# {env} {scope} 構成図

- 生成日時: 2026-04-26 17:45 JST
- 対象コミット: <git rev-parse --short HEAD>
- 入力: terraform/envs/{env}/, terraform/modules/

## コンポーネント

| 役割 | リソース名 | tf ファイル | 備考 |
| --- | --- | --- | --- |
| 認証基盤 | cognito-user-pool-prod | [terraform/envs/prod/auth.tf:10](../../terraform/envs/prod/auth.tf#L10) | OIDC プロバイダ |
| ... | ... | ... | ... |

## 接続凡例

| 線種 | 意味 |
| --- | --- |
| 実線 | 通常通信 |
| 破線 | 非同期/イベント |
| 点線 | 管理/監視 |

## 注意事項

- 本図は terraform plan 時点のスナップショット
- 自動生成のため、変更時は再生成すること
```

### Step 8: 自己検証

```bash
TF_COUNT=$(grep -rE '^resource "aws_' terraform/envs/{env}/ terraform/modules/ \
  --include='*.tf' | wc -l)
DIAGRAM_COUNT=$(grep -oE 'resIcon=mxgraph\.aws4\.[a-z_]+' \
  docs/architecture/{env}-{scope}.drawio | wc -l)
echo "tf=$TF_COUNT diagram=$DIAGRAM_COUNT"
```

以下を **必ずユーザーに報告する**:

| 検出項目 | 報告内容 |
| --- | --- |
| `TF_COUNT` と `DIAGRAM_COUNT` の乖離が ±30% 超 | 乖離率と原因の仮説 |
| `count = 0` で消えるリソース | リソース名と該当 tf パス |
| `references/modules-map.md` 未登録モジュール | モジュール名と source パス |
| shape 名が確定できなかったリソース | リソース type と該当 tf パス |

報告後、ユーザーが了承するまで「完了」と言わない。

---

## 参照ファイル

| ファイル | 用途 | 読むタイミング |
| --- | --- | --- |
| `references/aws4-shapes.md` | AWS4 shape 名 (resIcon / grIcon) リファレンス | Step 6 |
| `references/modules-map.md` | Terraform モジュール → AWS サービス展開マッピング | Step 3.2 |
| `references/label-rules.md` | ラベル・線種・色の規約 | Step 6.3 |

これらは **on-demand で読む**。SKILL.md を毎回全文読むのは context の無駄なので、
本ファイルは workflow 全体図のみ覚え、詳細はその都度 references を参照すること。

---

## 想定外への対処

| 状況 | 対処 |
| --- | --- |
| Terraform コードが見つからない | パスをユーザーに確認 |
| `plan.json` の生成権限が無い | コードベースの静的解析のみで進め、不確実性を解説書に明記 |
| 12 サービス超だがユーザーが 1 枚を希望 | 警告を出した上で従う。レイアウトが破綻したら再分割を提案 |
| 描画エンジン委譲先が AWS4 以外を出力 | 補正する (mxgraph.aws4 名前空間に置換) |
| 図と tf の乖離 ±30% 超 | 完了報告せず、原因調査をユーザーに依頼 |
