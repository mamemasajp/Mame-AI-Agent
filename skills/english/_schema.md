# /english — データ形式仕様（_schema）

> このファイルは `/english` が読み書きするデータの**唯一の定義**。
> 形式を変えるときは必ず整合させ、words/patterns/progress の構造を崩さない。

## ホーム（データホーム）

```
{DATA_HOME}/Language/
├─ source/main.md           # 主軸テキスト（1文=1行）
├─ words.tsv                # 単語DB
├─ patterns.tsv             # 文法パターン索引
├─ progress.json            # 進捗
└─ sessions/                # 振り返り（任意）
```

## words.tsv（単語DB・TSV・タブ区切り・ヘッダ行つき）

| 列 | 型 | 内容 |
|----|----|------|
| word | str | 語（原型・正規形）。**重複排除キー** |
| pos | str | 品詞（n/v/adj/adv/phrase/…） |
| meaning_native | str | 意味（学習者の母語で自然に） |
| sentence_source | str | 出現した文そのもの |
| sentence_translation | str | その文の訳 |
| source | str | 出典（main::L12 等） |
| first_seen | date | 初出日 YYYY-MM-DD |
| last_seen | date | 最近見た日 YYYY-MM-DD |
| status | enum | new / learning / known / mastery |
| occurrences | int | 出現回数 |
| note | str | 文法・語法メモ（任意。空欄可） |

**status 遷移（正準）:**
- `new` … 初回追加
- `learning` … 学習中（復習必要）
- `known` … 文脈で意味を答えられる（= 既知語条件付けセットに含む）
- `mastery` … 定着

**条件付けセット**: `status ∈ {known, mastery}` の語を既知語として扱い、新しい説明は「既知語+新語(i+1)」で構成する。

**注意（seed は既知を保証しない）**: words.tsv の初期投入（既知語条件付けセット / seed）は「今後出現しそうな語」の予告であり、ユーザーがその語を既知であるとは限らない。評価時、**誤訳・「わからない」マークが判明した語は、status ∈ {known, mastery} でも学習対象として扱う** — `status=learning` へ戻し、`occurrences` を加算し、`note` に「誤訳」を記録する（de-dupe は行の重複だけを防ぎ、記録を逃さない）。

## patterns.tsv（文法パターン索引・TSV）

| 列 | 型 | 内容 |
|----|----|------|
| id | str | P001…（一意） |
| pattern | str | パターン名（例: 無生物主語, 過去分詞の後置修飾） |
| description_native | str | 説明（学習者の母語） |
| example_source | str | 例文 |
| example_translation | str | 例文訳 |
| first_seen | date | 初出日 |
| last_seen | date | 最近見た日 |
| occurrences | json | 出現行の履歴配列 ["L12","L45",…] |
| weak_spots | str | 粒度の細かい弱点（学習者が間違えやすい点） |
| status | enum | new / learning / known / mastery |
| note | str | メモ（任意） |

**横断参照**: ギャップ報告で文法ポイントが出たら、`pattern` か内容で patterns.tsv を検索し、`occurrences` に前例があれば「前 Lxx でも出てきた」と参照。新規なら id を採番して追記。

## progress.json（進捗）

```json
{
  "source": "source/main.md",
  "total_lines": 153,
  "next_line": 1,
  "last_date": "2026-08-04",
  "history": [
    {"date": "2026-08-04", "lines": [1,2,3,4,5], "new_words": 4, "new_patterns": 1, "confidence": 0.6}
  ],
  "metrics": {
    "full_passes": 0,
    "total_new_words": 0,
    "word_mastery": 0,
    "review_accuracy_avg": null
  }
}
```

- `next_line`: 次に読む開始行（1始まり）。5文/日で +5。
- `history[].confidence`: 学習者の訳の正答度合い 0.0〜1.0（弱いとしても記録）
- `metrics` は週次測定で更新（`/english review` や週振り返り時に）。

## 日次ファイル（{DATA_HOME}/inbox/language-YYYY-MM-DD.md）

```
# Language: 2026-08-04 の5文

## L1 「<文1>」
あなたの訳：（学習者がここに書く）

## L2 「<文2>」
あなたの訳：（…）

...（5文分。訳が空・予測でも可）
```
→ エージェントが評価時に「評価」セクションを追記する（新規ファイルは学習者が自由に書く＝本文改変ではなく日次の生データとしての追記。但し学習者の「あなたの訳」本文は上書きせず追記のみ）。

## 注意

- TSVはタブ区切り。語にタブを含めない。
- `status` 遷移は `/english` がルールどおり更新する。
- 既知語条件付けは words.tsv の known/mastery を読み込んで行う。ただし誤訳・未知判明時は learning へ戻す（上記「注意」参照）。
