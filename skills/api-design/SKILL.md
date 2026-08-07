---
name: api-design
description: API・インターフェース設計 - REST/GraphQL/gRPC・バージョニング・契約テスト
---

# /api-design - API設計支援

## 概要
**安定したAPI・モジュール境界・公開インターフェース**を設計するためのガイドライン・テンプレート・検証ツール。REST/GraphQL/gRPC/TypeScript型等、複数形式に対応。

## 設計原則

| 原則 | 説明 | 適用 |
|------|------|------|
| **契約優先** | 実装前にOpenAPI/Protobuf/GraphQL Schemaで合意 | 全API |
| **後方互換** | 破壊的変更は新バージョン・非推奨期間確保 | v1→v2移行 |
| **最小権限** | 必要最小限のフィールド・操作のみ公開 | レスポンス設計 |
| **冪等性** | GET/PUT/DELETEは冪等、POSTは冪等キー推奨 | REST |
| **ページネーション** | カーソルベース・総件数・次ページ情報標準化 | リストAPI |
| **エラー統一** | RFC 7807 Problem Details / GraphQL Errors / gRPC Status | 全形式 |
| **バージョニング** | URLパス (v1/v2) またはヘッダー・メディアタイプ | 破壊的変更時 |
| **ドキュメント自動生成** | コードからOpenAPI/SDL/Proto生成・CI検証 | 常時 |

## コマンド

### API設計・生成
```
/api-design create --type=rest --name=Users --version=v1
/api-design create --type=graphql --schema=User.graphql
/api-design create --type=grpc --proto=user.proto
/api-design create --type=ts-interface --name=UserService
```

### 設計検証
```
/api-design validate --spec=openapi.yaml --rules=breaking-changes,naming,errors
/api-design validate --diff=v1/openapi.yaml,v2/openapi.yaml --breaking-only
/api-design validate --contract-tests --generate
```

### テンプレート
```
/api-design template rest --resource=Users --operations=crud,search,bulk
/api-design template graphql --type=User --fields=id,name,email,posts
/api-design template grpc --service=UserService --methods=Get,List,Create,Update,Delete
/api-design template errors --format=rfc7807 --codes=400,401,403,404,409,422,500
```

### バージョニング・移行
```
/api-design version bump --from=v1 --to=v2 --breaking
/api-design version migrate --from=v1 --to=v2 --adapter
/api-design version deprecate --version=v1 --sunset=2026-12-31
```

## REST設計テンプレート (CRUD + 検索)

```yaml
# Users API v1
paths:
  /api/v1/users:
    get:
      summary: ユーザー一覧取得
      parameters:
        - $ref: '#/components/parameters/CursorPagination'
        - $ref: '#/components/parameters/UserFilter'
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
    post:
      summary: ユーザー作成
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          $ref: '#/components/responses/CreatedUser'
        '422':
          $ref: '#/components/responses/ValidationError'
  /api/v1/users/{id}:
    get:
      summary: ユーザー詳細
      parameters:
        - $ref: '#/components/parameters/UserId'
      responses:
        '200':
          $ref: '#/components/responses/UserDetail'
        '404':
          $ref: '#/components/responses/NotFound'
    put:
      summary: ユーザー全更新
    patch:
      summary: ユーザー部分更新
    delete:
      summary: ユーザー削除
      responses:
        '204':
          description: 削除成功
        '404':
          $ref: '#/components/responses/NotFound'

components:
  schemas:
    User:
      type: object
      required: [id, email, name, createdAt]
      properties:
        id: {type: string, format: uuid}
        email: {type: string, format: email}
        name: {type: string, maxLength: 100}
        createdAt: {type: string, format: date-time}
        updatedAt: {type: string, format: date-time}
    CreateUserRequest:
      type: object
      required: [email, name]
      properties:
        email: {type: string, format: email}
        name: {type: string, maxLength: 100}
    UserListResponse:
      type: object
      required: [data, pagination]
      properties:
        data: {type: array, items: {$ref: '#/components/schemas/User'}}
        pagination: {$ref: '#/components/schemas/CursorPagination'}
    ErrorResponse:
      type: object
      required: [type, title, status, detail, instance]
      properties:
        type: {type: string, format: uri}
        title: {type: string}
        status: {type: integer}
        detail: {type: string}
        instance: {type: string, format: uri}
```

## GraphQL設計テンプレート

```graphql
type User {
  id: ID!
  email: String!
  name: String!
  createdAt: DateTime!
  updatedAt: DateTime!
  posts(after: String, first: Int): PostConnection!
}

type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type PostEdge {
  node: Post!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

input CreateUserInput {
  email: String!
  name: String!
}

type CreateUserPayload {
  user: User
  clientMutationId: String
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload
  deleteUser(id: ID!): DeleteUserPayload
}
```

## エラーレスポンス統一 (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 422,
  "detail": "The request body contains invalid fields.",
  "instance": "/api/v1/users/req_abc123",
  "errors": [
    {
      "field": "email",
      "code": "INVALID_FORMAT",
      "message": "Must be a valid email address"
    },
    {
      "field": "name",
      "code": "TOO_SHORT",
      "message": "Must be at least 2 characters"
    }
  ]
}
```

## 破壊的変更チェックリスト

| 変更 | 破壊的 | 対応 |
|------|--------|------|
| フィールド削除 | ✅ | 新版で非推奨→削除 |
| フィールド型変更 | ✅ | 新版で追加・旧非推奨 |
| 必須フィールド追加 | ✅ | デフォルト値・新版 |
| エラーコード変更 | ✅ | 旧コード併記・新版 |
| ページネーション形式変更 | ✅ | 新版・旧版併存 |
| 認証方式変更 | ✅ | 移行期間・両対応 |
| エンドポイント削除 | ✅ | 410 Gone・新版 |

## オプション

| オプション | 説明 |
|-----------|------|
| `--type` | rest/graphql/grpc/ts-interface |
| `--format` | yaml/json/proto/ts |
| `--validate` | 破壊的変更・命名規約・エラー統一検証 |
| `--diff` | 2バージョン間差分・破壊的変更検出 |
| `--generate-tests` | 契約テスト雛形生成 (Pact/Schemathesis) |
| `--mock-server` | OpenAPIからモックサーバ生成 |
