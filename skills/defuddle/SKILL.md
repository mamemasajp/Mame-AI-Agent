---
name: defuddle
description: Webページ→Markdown抽出 - ナビゲーション除去・本文特化・トークン節約
---

# /defuddle - Webページ本文抽出

## 概要
Webページから **本文コンテンツのみを抽出し、クリーンなMarkdownで出力**。ナビゲーション・広告・サイドバー・フッター等のノイズを除去し、トークン消費を大幅削減。

## 使い方

```
/defuddle <URL>                    # 抽出・標準出力
/defuddle <URL> --output=file.md   # ファイル保存
/defuddle <URL> --format=json      # 構造化出力
/defuddle <URL> --selector=article # CSSセレクタ指定
/defuddle --batch=urls.txt         # 一括処理
```

## 抽出ロジック

### 1. 本文候補検出 (優先度順)
| セレクタ | 信頼度 | 対象 |
|----------|--------|------|
| `<article>` | ★★★ | HTML5標準 |
| `[role="main"]` | ★★★ | ARIA準拠 |
| `.post-content`, `.entry-content`, `.article-body` | ★★ | 一般的クラス |
| `#content`, `#main`, `#primary` | ★★ | 一般的ID |
| `<main>` | ★★ | HTML5 |
| `<div class="content">` | ★ | 汎用 |

### 2. ノイズ除去 (自動)
```css
/* 除去対象 */
nav, header, footer, aside, .sidebar, .navigation,
.menu, .ads, .advertisement, .social-share,
.related-posts, .comments, .newsletter-signup,
.popup, .modal, .cookie-banner, .paywall,
script, style, noscript, iframe, svg,
[aria-hidden="true"], .hidden, .visually-hidden
```

### 3. 構造整形
- 見出し階層正規化 (h1→h3等調整)
- リスト・テーブル・コードブロック保持
- 画像: alt・caption・src抽出 (base64除外)
- リンク: 内部/外部分類・相対→絶対URL変換
- メタデータ: title/author/date/description抽出

## 出力形式

### Markdown (標準)
```markdown
# 記事タイトル
**著者**: 著者名 | **公開日**: 2026-07-27 | **出典**: https://example.com/article

## 見出し1
本文段落...

### 見出し2
- リスト項目1
- リスト項目2

```python
# コードブロック保持
def hello():
    print("world")
```

> 引用ブロック保持

[参考リンク](https://example.com/ref)
```

### JSON (--format=json)
```json
{
  "url": "https://example.com/article",
  "title": "記事タイトル",
  "author": "著者名",
  "datePublished": "2026-07-27T10:00:00Z",
  "dateModified": "2026-07-27T12:00:00Z",
  "description": "メタdescription",
  "content": "# 記事タイトル\n\n本文Markdown...",
  "wordCount": 1234,
  "readingTimeMinutes": 6,
  "links": [
    {"text": "参考リンク", "url": "https://example.com/ref", "internal": false}
  ],
  "images": [
    {"src": "https://example.com/img.jpg", "alt": "説明", "caption": "キャプション"}
  ],
  "extractedAt": "2026-07-27T15:30:00Z"
}
```

## オプション

| オプション | 説明 | デフォルト |
|-----------|------|-----------|
| `--selector` | 本文コンテナCSSセレクタ | 自動検出 |
| `--remove-selector` | 追加除去セレクタ (カンマ区切り) | - |
| `--keep-selector` | 強制保持セレクタ | - |
| `--format` | markdown/json/text | markdown |
| `--output` | 出力ファイルパス | stdout |
| `--max-length` | 最大文字数 (超過時切り詰め) | 無制限 |
| `--images` | 画像処理 (keep/remove/placeholder) | keep |
| `--links` | リンク処理 (absolute/relative/remove) | absolute |
| `--metadata` | メタデータ抽出有無 | true |
| `--batch` | URLリストファイル一括処理 | - |
| `--concurrency` | 並列数 (batch時) | 3 |
| `--timeout` | 取得タイムアウト(秒) | 30 |
| `--user-agent` | カスタムUA | Defuddle/1.0 |
| `--no-js` | JS実行なし (高速) | false |
| `--wait-for` | 待機セレクタ (SPA対応) | - |

## 使用例

```
/defuddle "https://blog.example.com/technical-post" --output=post.md
/defuddle "https://docs.example.com/api" --selector="main.docs-content" --format=json
/defuddle --batch=urls.txt --output-dir=./extracted --concurrency=5
/defuddle "https://spa.example.com/page" --wait-for=".content-loaded" --no-js=false
```

## 品質指標

| 指標 | 目標 | 測定 |
|------|------|------|
| **本文抽出率** | ≥ 95% | 手動確認サンプル |
| **ノイズ混入率** | ≤ 1% | ナビ・広告残存チェック |
| **構造保持率** | ≥ 90% | 見出し・リスト・コード |
| **トークン削減率** | ≥ 70% | 元HTML vs 抽出MD |
| **処理時間** | ≤ 5秒/ページ | 平均・P95 |

