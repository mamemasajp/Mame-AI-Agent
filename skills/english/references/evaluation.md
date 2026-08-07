# /english — 評価出力の全文例（Understanding Gap Report）

> 深読み5文への返答はこの形式で行う。逐文 + 語彙DB更新 + 文法横断参照。

## 例（架空の5文への返答）

```
✅ 今日の5文（L1〜L5）の評価

## L1: "Now is not the time to maximize revenue from products."
   あなたの訳: 「いまは製品から収益を最大化する時ではない」 —— 正しい ✅
   ズレの核心: なし
   文法: "to maximize"（不定詞・目的を表す副詞的用法）。"the time to do" = 〜する時

## L2: "When you stand at a high level of technology, it's a dimensionality reduction strike."
   あなたの訳: 「（空欄）」 —— わからないポイントを押さえました
   訂正: 「高い技術レベルに立てば、それは次元を減らした攻撃になる」
   ズレの核心: "dimensionality reduction"は機械学習用語「次元削減」。ここは比喩で「より低い次元（単純な土俵）から叩く＝降格特攻」の意味
   新語: dimensionality reduction (n) → words.tsv へ登録
   文法: When S V, S V。無生物主語 it + 補語 strike（名詞）
   ☞ 前例: "reduction" はL05で学習済み。意味の核「減らす」が共通

## L3: "Open source is the sweet point for a company of our size."
   あなたの訳: 「我々の規模の会社にとって、オープンソースは甘い点だ」 —— ⚠️ 部分的
   訂正: 「当社規模の会社にとって、公開はまさに最適解だ」
   ズレの核心: "sweet point"は「甘い点」ではない。「最適点・狙い目（sweet spot）」。"sweet"に「心地よい・理想的な」の意
   新語: sweet spot (phrase) → words.tsv（sentence付きで）
   文法: "of our size" = 「当社規模の」。of + 名詞で属性を限定

…

## 📌 今日のまとめ
- 新規語: 4語（dimensionality reduction / sweet spot / maximize / revenue）→ words.tsv に登録済み
- 新規パターン: 1件（無生物主語）→ patterns.tsv P00x に記録。前例 L02 にも出現
- 今日のconfidence: 0.7（L1正解・L2空欄・L3部分）

次の文へ進む準備ができました。翌日は L6 からです。
```

## 判定の目安

| 学習者訳 | 扱い |
|---------|------|
| 意味が通る自然な訳 | ✅ 正しい。ズレなし |
| 意味は近いが単語の字面訳 | ⚠️ 部分。ズレの核心を「語の意味のずれ」として指摘 |
| 文構造を取り違える | ❌ 誤り。文法パターンとして patterns.tsv に記録 |
| 空欄・予測 | 押さえとして扱い、正解＋なぜ分からなかったかを説明 |

## 重要

- **ただ正解を渡すだけにしない**。必ず「学習者訳 ↔ 正解」の間に何があり、どこでズレたかを言語化する（これが学び）。
- 語彙は1日3〜5語に抑える。6語以上出そうなら、重要度順に選ぶ。
- **誤訳・未知マークされた語は、新規語でなくても必ず拾う**: DB に登録済みでも `status=learning` へプロモートし `occurrences` を加算、`note` に「誤訳」を記録する（例: revenue を venue=通り から誤推測。DB 在庫の有無は関係ない）。
- 既知語（known/mastery）は説明の土台に使い、新語(i+1)だけを導入する。
