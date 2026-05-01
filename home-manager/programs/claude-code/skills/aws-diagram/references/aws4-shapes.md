# AWS4 Shape 名リファレンス

draw.io の AWS4 アイコンセット (`mxgraph.aws4` namespace) における
shape 名 (resIcon, grIcon) と公式カテゴリカラーのリファレンス。

本ファイルに記載のないサービスは **推測せず、ユーザーに確認** すること。

---

## カテゴリ別カラー (fillColor)

各 ResourceIcon の `fillColor` は AWS 公式カテゴリ色に従う。
**カテゴリをまたいだ色混在は禁止する** (例: Lambda を Database 紫で描かない)。

| カテゴリ | カラーコード | 主なサービス |
| --- | --- | --- |
| Compute | `#ED7100` | EC2, ECS, Lambda, Fargate, EKS |
| Containers | `#ED7100` | ECR, Service Connect, Cloud Map |
| Storage | `#7AA116` | S3, EBS, EFS, FSx, Backup |
| Database | `#C925D1` | RDS, DynamoDB, DocumentDB, Aurora, ElastiCache |
| Networking & Content Delivery | `#8C4FFF` | VPC, Route53, CloudFront, ALB, API Gateway |
| Security, Identity & Compliance | `#DD344C` | IAM, Cognito, KMS, Secrets Manager, ACM, WAF |
| Analytics | `#8C4FFF` | Athena, Glue, EMR, Kinesis, MSK |
| Management & Governance | `#E7157B` | CloudWatch, CloudTrail, Config, SSM, Organizations |
| Developer Tools | `#C925D1` | CodeBuild, CodeDeploy, CodePipeline, CodeCommit |
| App Integration | `#E7157B` | SNS, SQS, EventBridge, Step Functions, MWAA, AppSync, Amplify |
| Front-End Web & Mobile | `#DD344C` | Amplify, AppSync (※ App Integration と被る場合あり) |

**注意**: Networking と Analytics は同じ紫 `#8C4FFF` を共有する。同一図内で
両方が出る場合は、グループ境界 (VPC vs Glue Database 等) で区別する。

---

## ResourceIcon (resIcon) 表

`resIcon=mxgraph.aws4.{name}` の `{name}` 部分。

### Compute / Containers (`#ED7100`)

| サービス | resIcon |
| --- | --- |
| EC2 | `ec2` |
| Lambda | `lambda` |
| Fargate | `fargate` |
| Elastic Container Service | `elastic_container_service` |
| Elastic Container Service - Service | `elastic_container_service_service` |
| Elastic Container Service - Task | `elastic_container_service_task` |
| Elastic Kubernetes Service | `elastic_kubernetes_service` |
| Elastic Container Registry | `elastic_container_registry` |
| App Runner | `app_runner` |
| Batch | `batch` |
| Service Connect | `service_connect` |
| Cloud Map | `cloud_map` |
| Auto Scaling | `auto_scaling` |

### Storage (`#7AA116`)

| サービス | resIcon |
| --- | --- |
| Simple Storage Service (S3) | `simple_storage_service` |
| S3 Glacier | `simple_storage_service_glacier` |
| Elastic Block Store | `elastic_block_store` |
| Elastic File System | `elastic_file_system` |
| FSx | `fsx` |
| Backup | `backup` |
| Storage Gateway | `storage_gateway` |
| DataSync | `datasync` |

### Database (`#C925D1`)

| サービス | resIcon |
| --- | --- |
| RDS | `rds` |
| Aurora | `aurora` |
| DynamoDB | `dynamodb` |
| DocumentDB (with MongoDB compatibility) | `documentdb_with_mongodb_compatibility` |
| ElastiCache | `elasticache` |
| MemoryDB for Redis | `memorydb_for_redis` |
| Neptune | `neptune` |
| Redshift | `redshift` |
| Database Migration Service | `database_migration_service` |
| Timestream | `timestream` |

### Networking & Content Delivery (`#8C4FFF`)

| サービス | resIcon |
| --- | --- |
| VPC | `vpc` |
| Route 53 | `route_53` |
| CloudFront | `cloudfront` |
| Application Load Balancer | `application_load_balancer` |
| Network Load Balancer | `network_load_balancer` |
| Gateway Load Balancer | `gateway_load_balancer` |
| API Gateway | `api_gateway` |
| Transit Gateway | `transit_gateway` |
| Direct Connect | `direct_connect` |
| Site-to-Site VPN | `site_to_site_vpn` |
| Client VPN | `client_vpn` |
| Global Accelerator | `global_accelerator` |
| PrivateLink | `privatelink` |
| Cloud Map | `cloud_map` |

### Security, Identity & Compliance (`#DD344C`)

| サービス | resIcon |
| --- | --- |
| IAM | `identity_and_access_management` |
| IAM Identity Center | `iam_identity_center` |
| Cognito | `cognito` |
| Key Management Service | `key_management_service` |
| Secrets Manager | `secrets_manager` |
| Certificate Manager | `certificate_manager` |
| WAF | `waf` |
| Shield | `shield` |
| GuardDuty | `guardduty` |
| Inspector | `inspector` |
| Security Hub | `security_hub` |
| Macie | `macie` |
| Detective | `detective` |
| Resource Access Manager | `resource_access_manager` |

### Analytics (`#8C4FFF`)

| サービス | resIcon |
| --- | --- |
| Athena | `athena` |
| Glue | `glue` |
| Glue DataBrew | `glue_databrew` |
| EMR | `emr` |
| Kinesis Data Streams | `kinesis_data_streams` |
| Kinesis Data Firehose | `kinesis_data_firehose` |
| Kinesis Data Analytics | `kinesis_data_analytics` |
| Managed Streaming for Apache Kafka (MSK) | `managed_streaming_for_apache_kafka` |
| OpenSearch Service | `opensearch_service` |
| Lake Formation | `lake_formation` |
| QuickSight | `quicksight` |
| Data Pipeline | `data_pipeline` |

### Management & Governance (`#E7157B`)

| サービス | resIcon |
| --- | --- |
| CloudWatch | `cloudwatch` |
| CloudWatch Logs | `cloudwatch_logs` |
| CloudWatch Alarm | `cloudwatch_alarm` |
| CloudTrail | `cloudtrail` |
| Config | `config` |
| Systems Manager | `systems_manager` |
| Systems Manager Parameter Store | `systems_manager_parameter_store` |
| Organizations | `organizations` |
| Control Tower | `control_tower` |
| Trusted Advisor | `trusted_advisor` |
| Service Catalog | `service_catalog` |
| AWS Health Dashboard | `aws_health_dashboard` |
| Resource Groups | `resource_groups` |

### Developer Tools (`#C925D1`)

| サービス | resIcon |
| --- | --- |
| CodeBuild | `codebuild` |
| CodeDeploy | `codedeploy` |
| CodePipeline | `codepipeline` |
| CodeCommit | `codecommit` |
| CodeArtifact | `codeartifact` |
| CodeStar | `codestar` |
| Cloud9 | `cloud9` |
| X-Ray | `x_ray` |

### App Integration (`#E7157B`)

| サービス | resIcon |
| --- | --- |
| Simple Notification Service (SNS) | `simple_notification_service` |
| Simple Queue Service (SQS) | `simple_queue_service` |
| EventBridge | `eventbridge` |
| Step Functions | `step_functions` |
| Managed Workflows for Apache Airflow (MWAA) | `managed_workflows_for_apache_airflow` |
| AppSync | `appsync` |
| Amplify | `amplify` |
| MQ | `mq` |
| API Gateway | `api_gateway` |

---

## グループ shape (grIcon) 表

`grIcon=mxgraph.aws4.{name}` の `{name}` 部分。グループ境界の描画に使う。

| 種類 | grIcon | strokeColor | 線種 | 用途 |
| --- | --- | --- | --- | --- |
| AWS Account | `group_account` | `#CD2264` | 実線 | アカウント境界 |
| Region | `group_region` | `#00A4A6` | 破線 (`dashed=1`) | リージョン境界 |
| VPC | `group_vpc` | `#8C4FFF` | 実線 | VPC 境界 |
| Public Subnet | `group_public_subnet` | `#7AA116` | 実線 | パブリックサブネット |
| Private Subnet | `group_private_subnet` | `#00A4A6` | 実線 | プライベートサブネット |
| Security Group | `group_security_group` | `#DD344C` | 破線 (`dashed=1`) | セキュリティグループ |
| Auto Scaling Group | `group_auto_scaling_group` | `#ED7100` | 破線 (`dashed=1`) | ASG 境界 |
| Corporate Data Center | `group_corporate_data_center` | `#7D8998` | 実線 | オンプレ環境 |
| Generic Group (枠のみ) | `group` | 任意 | 任意 | その他の論理境界 |

`grIcon` の指定がない `mxgraph.aws4.group` は、シンプルな枠だけのグループになる。

---

## サンプル XML

### ResourceIcon の例

```xml
<mxCell id="lambda_main"
        value="認証Lambda&#xa;cognito-trigger-prod"
        style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;gradientColor=none;fillColor=#ED7100;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.lambda;"
        vertex="1" parent="1">
  <mxGeometry x="200" y="200" width="78" height="78" as="geometry"/>
  <Object description="terraform/envs/prod/lambda.tf:15"/>
</mxCell>
```

ポイント:

- `value` の改行は `&#xa;` (HTML タグ禁止)
- `fillColor` はカテゴリカラー (Compute なので `#ED7100`)
- `resIcon=mxgraph.aws4.lambda` で Lambda アイコン
- `description` 属性に対応 tf パスを記録

### Group (VPC) の例

```xml
<mxCell id="vpc_prod"
        value="VPC (10.0.0.0/16)&#xa;vpc-prod-main"
        style="points=[[0,0],[0.25,0],[0.5,0],[0.75,0],[1,0],[1,0.25],[1,0.5],[1,0.75],[1,1],[0.75,1],[0.5,1],[0.25,1],[0,1],[0,0.75],[0,0.5],[0,0.25]];outlineConnect=0;gradientColor=none;html=1;whiteSpace=wrap;fontSize=12;fontStyle=0;container=1;pointerEvents=0;collapsible=0;recursiveResize=0;shape=mxgraph.aws4.group;grIcon=mxgraph.aws4.group_vpc;strokeColor=#8C4FFF;fillColor=none;verticalAlign=top;align=left;spacingLeft=30;fontColor=#AAB7B8;dashed=0;"
        vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="800" height="600" as="geometry"/>
</mxCell>
```

### Edge (接続線) の例

```xml
<mxCell id="edge_alb_to_ecs"
        value="HTTPS/443"
        style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;strokeColor=#545B64;fontSize=10;"
        edge="1" parent="1" source="alb_main" target="ecs_service_app">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

ポイント:

- `value` にプロトコル/ポートを必ず記載
- `strokeColor=#545B64` が通常通信のデフォルト色
- 認証/データフロー方向で色を変える場合は `references/label-rules.md` 参照

---

## 未確認 shape の扱い

本リファレンスに記載のないサービスが Terraform コードに登場した場合:

1. **推測で `resIcon=mxgraph.aws4.xxx` を書かない**
2. ユーザーに以下を質問する:
   - 「`aws_xxx_yyy` リソースに対応する draw.io の shape 名は何ですか?」
3. ユーザーが draw.io UI で shape 名を確認する手順:
   - draw.io でアイコンをキャンバスに配置
   - 右クリック → **Edit Style** (または `Ctrl+E`)
   - 開いたダイアログ内の `resIcon=mxgraph.aws4.xxx` の `xxx` を読む
4. 確認後、本ファイルへの追記を提案する

---

## カテゴリ色の早見表 (1 行版)

```
Compute      #ED7100  オレンジ
Storage      #7AA116  緑
Database     #C925D1  紫(濃)
Networking   #8C4FFF  紫(薄)
Security     #DD344C  赤
Analytics    #8C4FFF  紫(薄) ※Networking と同色
Management   #E7157B  ピンク
DevTools     #C925D1  紫(濃) ※Database と同色
Integration  #E7157B  ピンク ※Management と同色
```
