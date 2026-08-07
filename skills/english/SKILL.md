---
name: english
description: 言語学習（文脈型・LLM共育 /english） — 主軸テキストの文を1日5文ずつ深読みし、学習者の訳を評価して「理解のズレ」を言語化、未知語を単語DBへ蓄積し、過去の文法出現と横断参照して先生のように教える。データ駆動で自己成長（SKILL.md自体は固定）。
---

# /english — 言語学習ループ（文脈型・LLM共育）

## 概要

主軸テキストを **1日5文ずつ深読み** する言語学習ループ。
学習者が返してきた自然言語の訳をエージェントが評価し、正誤・理解のズレを**言語化**。未知語は単語DB(words.tsv)へ蓄積し、文法ポイントはパターンDB(patterns.tsv)へ記録して、**過去の出現行と横断参照**しながら進める。

**設計原則: 「指示(SKILL.md)は固定・知識(データ)が成長」。** 成長はデータファイルの蓄積で実現する。SKILL.md自体は書き換えない。

## データ配置（単一情報源）

- **データホーム = `{DATA_HOME}/Language/`**（例: `~/Language/`。環境に合わせ `{DATA_HOME}` を設定）
- `{SOURCE}` に学習したい主軸テキスト（例: スピーチ全文・論文・小説）を入れる。
- スキルコード（本ファイル・_schema.md）はリポジトリの `skills/english/`（git管理）

```
{DATA_HOME}/Language/
├─ source/main.md           # 主軸テキスト（1文=1行・行番号）
├─ words.tsv                # 単語DB（既知語条件付けセット + 累積）
├─ patterns.tsv             # 文法パターン索引（出現行・weak_spots・last_seen・status）
├─ progress.json            # 進捗（next_line・完了履歴・指標）
└─ sessions/                # 振り返り（各ルーチン時の記録。任意）
{DATA_HOME}/inbox/language-YYYY-MM-DD.md  # その日の5文 + 学習者の訳（生データ）
```

> データホーム抽出: スキル冒頭で `{DATA_HOME}` を確認する。未設定なら環境変数 or 明示指定を求める（デフォルト案 `~/Language/` を推奨）。

## 起動トリガー

- `/english` → 今日の日課を開始（初回は「準備モード」で開始）
- `/english now` → 今日の進行中チャンクの続き
- `/english review` → 弱点パターン・未定着語の復習
- `/english export` → words.tsv からAnki/Quizlet用CSV生成

## データ形式

形式の詳細は **`_schema.md`**（本ファイルと同ディレクトリ）を参照。TSVヘッダ・列定義・JSON構造はそちらに集約。

## 毎日のフロー（決め打ち）

1. **状態を読む** — `progress.json` の `next_line`、`words.tsv`/`patterns.tsv` の既知語・弱点
2. **次チャンク選択** — `source/main.md` の行 `[next_line, next_line+5)` を取得
   - 弱点パターン(status=learning)が控えていれば、その文を含むよう5文を前後調整
3. **今日の5文を配置** — `{DATA_HOME}/inbox/language-YYYY-MM-DD.md` に各行を書き出し、学習者へ提示
4. **学習者の訳を受ける** — わかる文は自然な訳、わからない所は予測or空欄で書いてもらう
5. **評価（Understanding Gap Report）** — 逐文で「学習者訳 / 正解訳 / ズレの核心」を出し、言語化
   - 評価結果は日次ファイル末尾に「## 解説（評価）」セクションとして追記する（学習者の訳本文は上書きしない）
   - 文法ポイントが出たら `patterns.tsv` を検索 → 過去の該当行があれば「前 Lxx でも出てきた」と参照
   - **誤答・未知語の記録ルール**: 誤訳された語・「わからない」マークされた語は、`words.tsv` に既にあっても **status=learning へ更新し occurrences を加算、note に「誤訳」を記録**する。無ければ新規追加。de-dupe は「行の重複」を防ぐだけで、記録を逃さない
   - 新規語は1日3〜5語に抑えて `words.tsv` に追記（wordで重複チェック）
   - 文法は指示に応じて説明
6. **進捗更新** — `progress.json` の `next_line += n`（完了した文数）を更新

## 評価時の出力（Understanding Gap Report）

逐文フォーマット（`references/evaluation.md` に全文例）:

```
L12: "When you stand at a high level of technology, it's a dimensionality reduction strike."
  あなたの訳: 「ハイレベルな技術に立つとき、それは次元削減攻撃だ」（ほぼ正しい）
  訂正: 「高い技術レベルに立てば、それは次元を下げた降り打ちになる」
  ズレの核心: 「dimensionality reductionは機械学習用語『次元削減』。比喩として『低い次元から叩く優位』」
  新語: dimensionality reduction (n) → words.tsv へ
  文法: 接続詞 When(〜するとき) + 無生物主語 strike
  ☞ 前例: 「reduction」は L05 で学習済み。ここでまた出現 → 再掲
  ☞ 誤訳語: revenue は DB に在ったが今回誤訳 → status=learning 維持・occurrence+1・note「venue=通り と誤推測」
```

## 成長の仕組み（データ駆動）

- **words.tsv が増える** → 既知語条件付け(i+1)が精緻化 → 説明の語彙レベルが合う
- **patterns.tsv が増える** → 横断参照（「前 Lxx で出たよ」）が賢くなる
- **progress.json が進む** → 次チャンクが動的に選択される
- 弱点(status=learning)の**間隔反復再提示は v2**（まず毎日ループを回す）

## DO / DON'T

**DO:**
- 毎日5文を基準に、範囲を読み取って提示する（強制・お仕着せしない）
- 「学習者訳 vs 正解 vs ズレの核心」を必ず言語化して返す（単に正解を出すだけにしない）
- 未知語は `words.tsv` に**1語1行・wordで重複排除**して追記する
- 誤訳・未知マークされた語は、DBの存在有無に関わらず **learning化・occurrences加算・note「誤訳」記録**で必ず拾う
- 文法は `patterns.tsv` に記録し、過去出現があれば横断参照する
- 既知語(words.tsvのknown/mastery)を使った説明で i+1 を保つ

**DON'T:**
- SKILL.md 自体を書き換えて「自己改善」しない（成長はデータで）
- 日次ファイルの**学習者の訳本文を改変しない**（評価解説の末尾追記は許可。学習者が書いた訳は上書きしない）
- 1日あたり新規語を6語以上追加しない（低習熟度の付随的学習は1日3〜5語が上限）
- 音読をエージェントが判定すると誤魔化さない（音読は学習者の自己実施工程）
- `_schema.md` にない形式でDBを勝手に拡張しない

## 関連

- `_schema.md` — データ形式仕様（words/patterns/progressの列定義）
- `references/evaluation.md` — 評価出力の全文例
- `{DATA_HOME}/Language/` — データ本体
- `{DATA_HOME}/inbox/` — 日次5文ファイル
