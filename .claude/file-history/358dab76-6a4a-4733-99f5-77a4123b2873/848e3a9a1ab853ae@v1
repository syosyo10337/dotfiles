# Vault Conventions (Single Source of Truth)

このファイルは Obsidian vault 全体のフロントマター規約・リンク規約を定義する。
各 AI エージェント（Claude Code, GitHub Copilot, Cursor など）はこのファイルを参照すること。

---

## フロントマター

### 正規フォーマット

```yaml
---
tags:
  - tag-name
created: YYYY-MM-DD
updated_at: YYYY-MM-DD
status: draft | active | archived
---
```

| フィールド   | 必須 | 説明                                       |
| ------------ | ---- | ------------------------------------------ |
| `tags`       | Yes  | kebab-case。リスト形式で記述               |
| `created`    | Yes  | ファイル作成日。Linter が自動挿入          |
| `updated_at` | No   | 最終更新日。エージェントが編集時に更新する |
| `status`     | Yes  | `draft` / `active` / `archived`            |

### Web Clipping 用の追加フィールド

```yaml
title: "記事タイトル"
source: "URL"
author:
  - "著者名"
published: YYYY-MM-DD
```

### マイグレーションルール

以下の旧フィールド名が残っているファイルは、見つけ次第リネームする。

| 旧フィールド | 正規フィールド | 対象ファイル数（概算） |
| ------------ | -------------- | ---------------------- |
| `create_at`  | `created`      | 5                      |
| `updated`    | `updated_at`   | 20                     |

---

## リンク規約

**Wikilink 記法 (`[[...]]`) は使用禁止。** Obsidian 固有の記法であり、他のツールとの互換性がないため。

すべてのリンクは標準 Markdown 記法を使用すること:

| 種類             | 記法                          | 例                                            |
| ---------------- | ----------------------------- | --------------------------------------------- |
| 外部リンク       | `[表示テキスト](URL)`         | `[Google](https://google.com)`                |
| 画像（外部）     | `![alt](URL)`                 | `![diagram](https://example.com/img.png)`     |
| 画像（ローカル） | `![alt](相対パス)`            | `![diagram](Attachments/diagram.png)`         |
| 内部リンク       | `[表示テキスト](相対パス.md)` | `[設計メモ](Tech/Clean%20Code/コード設計.md)` |

---

## タグ規約

- kebab-case を使用する（例: `clean-code`, `design-pattern`）
- 大文字始まりのハッシュタグ（`#UpperCase`）は Linter の対象外

---

## テンプレート

- 新規ノートのテンプレートは `Meta/Templates/Default.md` を使用する
- `updated_at` フィールドは Linter が自動追加するため、テンプレートには含めない

## line length規約

- ファイルの最大行数は 300行までにする。それを超える場合
  - ファイル内のトピックが独立している場合は別ファイルへ分割
  - 曖昧な場合は、ユーザの指示を仰ぐ
