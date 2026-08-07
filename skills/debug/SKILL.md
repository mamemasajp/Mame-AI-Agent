---
name: debug
description: 統合デバッグコマンド - バグ診断から修正・検証まで一貫して実行
---

# /debug - 統合デバッグワークフロー

## 概要
バグ・テスト失敗・予期せぬ動作に遭遇した際、**診断→原因特定→修正→検証** を一連のフローで実行します。複数のデバッグ手法を統合し、単一エントリーポイントから適切な戦略を選択・実行します。

## 使い方

```
/debug                    # 対話式でデバッグ開始
/debug <エラー内容>        # エラー直接指定で開始
/debug --strategy=<戦略>   # 戦略指定 (systematic|diagnosis|strategies|detective)
/debug --auto             # 自動戦略選択で実行
```

## ワークフロー

### Phase 1: 状況把握・分類
```
入力: エラーメッセージ、スタックトレース、再現手順、期待動作 vs 実際動作
出力: エラータイプ分類 (syntax|runtime|logic|test|integration|performance)
```

### Phase 2: 戦略選択・実行

| 戦略 | 適用場面 | 実行内容 |
|------|----------|----------|
| `systematic` | 原因不明の複雑バグ | 4フェーズ: 情報収集→仮説生成→検証→修正 |
| `diagnosis` | テスト失敗・コンパイルエラー | 5ステップ: パターン分類→根本原因→修正→検証→文書化 |
| `strategies` | 既知パターンに当てはまる | 実証済み戦略カタログから最適解選択 |
| `detective` | ログ横断・類似エラー検索 | ログ/コードベースからパターン検索・相関分析 |

### Phase 3: 修正・検証
- 修正案の提示（最小変更・Surgical Changes原則）
- 修正適用前の確認（Ask→Code二段階）
- 修正後の回帰テスト・動作確認

### Phase 4: 文書化・学習
- デバッグ記録をセッションログに保存
- パターンをメモリに蓄積
- 類似エラー防止策の提案

## オプション

| オプション | 説明 |
|-----------|------|
| `--strategy` | 戦略明示指定 (systematic/diagnosis/strategies/detective) |
| `--auto` | エラー内容から自動戦略選択 |
| `--files` | 対象ファイル指定 (glob pattern) |
| `--depth` | 探索深度 (shallow/normal/deep) |
| `--no-fix` | 診断のみ実行、修正は提示のみ |
| `--learn` | 完了後にパターンをメモリ学習 |

## 使用例

```
/debug "TypeError: Cannot read property 'map' of undefined"
/debug --strategy=systematic --files="src/**/*.ts"
/debug --auto --learn
/debug "テストが冪等性で落ちる" --strategy=diagnosis
```

## 品質基準
- **Think Before Coding**: 原因特定前に仮説を明示
- **Simplicity First**: 最小修正で根本解決
- **Surgical Changes**: 関係ないコードに触らない
- **Goal-Driven**: 再現テスト通過を成功基準に
