---
name: mid-point
description: >
  セッション中盤〜後半の「中継保存」オーケストレーター。調査結果・改善案・詳細プランを
  ファイルへ退避し、コンテキストが圧迫される前に新セッションへ引き継ぐ。
  調査レポート（Obsidian 00-Inbox/）+ プラン（plans/ 正 + Obsidian 00-Inbox/ 閲覧複製）+
  セッション状態（sessions/ + router）を一括で保存し、再開パクト（新セッションの最初の
  1命令）を出力する。表示は概要のみに止め「詳細はファイル参照」でコンテキスト消費を断つ。
  session-kickoff Phase 7 を「任意タイミング」で単体実行できるようにした版。
when_to_use: >
  When the user wants to pause research/planning and continue in a fresh session
  (調査終了・プラン提示後には、"中継して" / "新しいセッションで実装" / "このセッションは調査だけ").
  Also auto-suggested when context is getting heavy (残量約60%) or after presenting long
  research/plan output — explicitly not for routine session end (use /session-end).
triggers:
  - 中継 / ハンドオフ / セッションを分けたい / 引き継いで / このセッションは調査だけ
  - 新しいセッションで実装 / 次セッションで続き / コンテキストが圧迫してきた
---

# mid-point — セッション中継スキル

**目的**: 調査・プラン提示によるコンテキスト圧迫を防ぎ、**調査の品質を保ったまま**新セッションへ引き継ぐ。
本スキル自身も「詳細はファイル、画面は概要のみ」を徹底し、コンテキストを浪費しない。

**関係**: `session-kickoff` Phase 7（引継ぎ保存）を任意タイミングで単体実行する版。
`session-end`（終了儀式）とは役割が異なる。中でも**「調査だけして実装は次セッション」**の日に使う。

**単一の真実**:
- タスクの計画 → `~/.claude/plans/<task>.md`（機械読取の正・生きた文書）
- セッション状態 → Obsidian `20-Areas/Claude-Code/session-router.md` + `sessions/<topic>.md`
- 調査知識・閲覧用プラン → Obsidian `00-Inbox/`（`/inbox-organize` で後からジャンル整理する前提）

---

## 発火タイミング

| 経路 | 内容 |
|------|------|
| **手動（基本）** | {USER} が「中継して」「このセッションは調査だけ」等の合図、または `/mid-point` と発言 |
| **自動提案** | コンテキスト残量が約60%に達したと判断される段階、または長文の調査結果・プランを提示した直後に、「`/mid-point` で中継しませんか？」と**提案**する（実行は{USER}の合図待ち） |

実行（新セッションでの実装）は、**{USER}の明示Goまで開始しない**。

---

## フェーズ 0〜7

```
/mid-point 起動
  ├─ Phase 0 状況把握（トピック特定・未コミット確認）      [Auto-Exec]
  ├─ Phase 1 調査詳細の回収（tmp/research/ から生詳細を統合）
  ├─ Phase 2 調査レポート保存（Obsidian 00-Inbox/ に新規ノート）
  ├─ Phase 3 改善案+詳細プラン（plans/<task>.md に書く）
  ├─ Phase 4 Obsidianプラン複製（00-Inbox/ に閲覧用コピー）
  ├─ Phase 5 ハンドオフ更新（sessions/<topic>.md + session-router.md）
  ├─ Phase 6 再開パクト出力（新セッションの最初の1命令）
  └─ Phase 7 Go待ち ★（実行は明示Goまで保留）
```

---

## Phase 0: 状況把握（Auto-Exec）

```bash
git branch --show-current        # トピック推測の手がかり
git status --porcelain           # 未コミットがあれば報告（混在注意）
```

- **トピック特定**: 優先順 — `/rename` セッション名 → ブランチ名 → {USER}へ確認。
- セッション名 = Obsidianノートキー（1トピック=1ノート、日付散乱させない）。

## Phase 1: 調査詳細の回収

調査エージェント（`research-explorer`）が生詳細を一時ファイルに保存していた場合、それを統合する。

```bash
ls ~/.claude/tmp/research/<topic>/ 2>/dev/null
```

- 一時ファイルがある場合 → 各チャネルの生詳細（根拠URL・引用・判断過程）を Phase 2 のレポートへ反映。
- ない場合 → 会話内の調査結果（要約+URL）をそのまま使う。**「未保存の詳細」を正直に明記**し、後追い調査はしない。
- 統合後、一時ディレクトリは内容をレポートへ移してから削除してよい。

## Phase 2: 調査レポート保存（Obsidian 00-Inbox/）

`00-Inbox/YYYY-MM-DD_<topic>_調査レポート.md` を**新規作成**する（FORMS.md「調査レポート」雛形）。

- frontmatter: `title`/`date`/`tags`（`type/report` `area/...` `status/...`）。
- 中身: 調査目的 / 調査項目 / チャネル別サマリー（根拠URL付き）/ 重要な発見 / 判断過程・トレードオフ / 未解決の疑問 / 未検証マーク。
- **本文改変禁止ルールの例外ではない**: あくまで**新規ノートの作成**。既存ノート（00-Inbox 内の他ノート含む）には触れない。

## Phase 3: 改善案+詳細プラン（plans/ 正）

`~/.claude/plans/<task>.md` を新規作成 or インプレース更新する（FORMS.md「プラン」雛形）。

- **ゴール・合格条件（検証可能）** を冒頭に。
- **改善案**（テーマによってはBest of N比較・採用理由）。
- **WBS**（各タスク cost ラベル）+ セッション分割境界。
- **version + changelog**（改訂のたび追記）+ 新事実・決定ログ。
- 本ファイルが機械読取の**正**。新セッションは必ずこれを読む。

## Phase 4: Obsidianプラン複製（00-Inbox/）

閲覧用コピーを `00-Inbox/YYYY-MM-DD_<topic>_プラン.md` に作る（FORMS.md「プラン複製」雛形）。

- **再同期の注意**: `/inbox-organize` で既存複製が別ディレクトリへ移動済みの場合、固定パスの追記はしない。
  トピック名で検索して、（1）見つかればインプレース更新（本文更新は本スキルの作成物なので許可）、
  （2）無ければ新規作成、（3）発見できなければ「複製は新規作成した。旧複製があれば教えて」と{USER}に報告。
- 複製は「中継時点のスナップショット」。完全ミラーはしない（次の /mid-point で再同期）。

## Phase 5: ハンドオフ更新（Obsidian 20-Areas/Claude-Code/）

1. `20-Areas/Claude-Code/sessions/<topic>.md` をインプレース更新（無ければ `_TEMPLATE.md` から作成）。
   ゴール/進捗/未完了/次アクション/決定/changelog を書く。
2. `20-Areas/Claude-Code/session-router.md` の該当行を更新（status flip / 行追加）。
   「今日の調査は done、実装は新セッション」等の状態が読み取れるように。

- セッション状態は共有メモリ / context.md に書かない（並列混在防止）。
- 知識ノート（00-Inbox 内の既存ノート等）の本文は改変しない。

## Phase 6: 再開パクト出力

次セッションの開始コマンドと最初の1命令を、**画面に簡潔に**出力する（FORMS.md「再開パクト」雛形）。

```
# 再開パクト: <topic>
# 開始: claude -n <topic>
# 最初の命令: 「~/.claude/plans/<task>.md と Obsidian 00-Inbox/<トピック>_調査レポート.md を
#            読んで、実装タスクを開始して」
# 参照: 調査レポート(00-Inbox) / プラン(plans/ + 00-Inbox複製) / ハンドオフ(sessions/)
```

出力は保存先一覧と併せて簡潔に。長い全文は再掲しない。

## Phase 7: Go待ち ★（最重要）

**新セッションでの実装は、{USER}の明示Goまで開始しない。**
「中継完了。新セッション（`claude -n <topic>`）で再開パクトを貼り付ければ即実装に入れます」で待つ。

---

## 表示節約の原則（全体に適用）

- 調査結果・プランをメインで**長々表示しない**。概要（数行）+「詳細は `00-Inbox/<レポート名>`」の参照で済ます。
- 本スキルの実行中も、出力はファイルへ書き、画面へは最小限だけ出す。

---

## DO / DON'T

**DO:**
- 調査詳細・プラン・セッション状態を3系統（00-Inbox / plans / sessions+router）に分けて保存
- 保存先を画面で再掲せず「ファイル名」だけ案内
- `/inbox-organize` による移動後はトピック名で再同期（固定パスに依存しない）
- 新規ノートは 00-Inbox/ に作る（Raw RAM 原則）

**DON'T:**
- 既存ノート（00-Inbox 内の他ノート含む）の本文を改変しない
- 共有メモリ / context.md にセッション状態を書かない
- `session-end` / `oreport` がやること（git commit・mnemon capture・議事録）を重複実行しない
- 新ハンドオフファイルを乱造しない（`sessions/<topic>.md` をインプレース更新）
- 新セッションで勝手に実装を開始しない（明示Go待ち）
- 調査を「やり直さない」— 既存の調査結果・一時ファイルを正とする

---

## 品質基準（完了判定）

- [ ] 調査レポート（00-Inbox/）に根拠URL・未検証マーク・未解決の疑問が含まれた
- [ ] プランの正（plans/<task>.md）に合格条件・WBS・changelog が含まれた
- [ ] Obsidianプラン複製がトピック名で検索され、再同期 or 新規作成された
- [ ] sessions/<topic>.md + session-router.md が更新された
- [ ] 再開パクト（開始コマンド+最初の1命令+参照一覧）が出力された
- [ ] 画面には概要のみ表示され、詳細はファイル参照に委ねられた
- [ ] 既存の既存ノート本文を一切改変していない

---

## 関連スキル

- `session-kickoff` — Phase 7（引継ぎ保存）の任意タイミング版が本スキル。キックオフのオーケストレーター本体。
- `session-end` — 終了儀式（git commit + mnemon capture）。本スキルはセッション**中継**用。
- `inbox-organize` — 00-Inbox から PARA への自動振り分け。本スキルは 00-Inbox に新規ノートを作る前提。
- `research-explorer` — 調査エージェント。生詳細を `~/.claude/tmp/research/<topic>/` に保存する契約を含む。