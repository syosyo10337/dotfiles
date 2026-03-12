# Phase 2: Insta/Web Renderer実装 - ユーザー画面更新 & 管理画面Preview

## Context
Issue #91: イベント投稿のInstaとの重複作業解消。
Phase 1で管理画面側のEventモデルを拡張済み（openTime, startTime, pricing, performers, hashtags）。
Phase 2では:
1. ユーザー画面のイベント詳細ページを構造化データ対応に更新
2. 管理画面にWeb Preview / Insta Preview / Insta投稿文タブを追加

---

## Step 1: Instagram投稿文生成ユーティリティ作成

**新規作成**: `src/utils/instagramCaption.ts`

- `generateInstagramCaption(event: EventEntity): string` 関数
- フォーマット: タイトル(EventType絵文字付き) → 日時 → 場所 → 料金 → 出演者 → 説明 → ハッシュタグ
- `formatDateJP` (既存) を再利用

---

## Step 2: ユーザー画面イベント詳細ページのリファクタリング

### 新規コンポーネント作成 (`src/app/(user)/events/[id]/_components/`)

| ファイル | 内容 | Server/Client |
|---------|------|---------------|
| `EventTimeInfo.tsx` | 「OPEN 19:00 / START 20:00」表示 | Server |
| `EventPricing.tsx` | 料金リスト (PricingTier[]) | Server |
| `EventPerformers.tsx` | 出演者リスト + Instagram @リンク | Server |
| `EventHashtags.tsx` | ハッシュタグ表示 | Server |
| `EventOverview.tsx` | description自由テキスト表示 (「概要」見出し + LinkifiedText) | Client |

### 修正ファイル

**`src/app/(user)/events/[id]/page.tsx`**
- order-4エリアのEventDescriptionを以下に置換:
  - EventTimeInfo → EventPricing → EventPerformers → EventOverview → EventHashtags
- event全体のデータを各コンポーネントに渡す

**`src/app/(user)/events/[id]/_components/index.ts`**
- EventDescription → EventOverview に差し替え、新コンポーネント追加

**`src/app/(user)/events/[id]/loading.tsx`**
- order-4のスケルトンを時間・料金・出演者用に更新

### 削除ファイル
- `src/app/(user)/events/[id]/_components/EventDescription.tsx` (EventOverviewで置換)
- `src/utils/parseEventDescription.ts` (他に使用箇所なし、不要に)

---

## Step 3: EventListItemの価格表示修正

**修正**: `src/app/(user)/events/_components/EventList/EventListItem.tsx`

- L22-29のdescriptionベース価格抽出ハックを削除
- `event.pricing` から表示:
  - 1件: `¥{amount}`
  - 複数: `¥{min} ~ ¥{max}`
  - なし: 非表示

---

## Step 4: shadcn/ui Tabsコンポーネント追加

**新規作成**: `src/components/shadcn/tabs.tsx`
- `./bin/pnpm dlx shadcn@latest add tabs` で追加

---

## Step 5: 管理画面イベント詳細ページにタブ追加

### 修正: `src/app/admin/(authenticated)/events/[id]/_components/EventDetailContent.tsx`

Tabsで4つのタブを追加:
- 「詳細」: 既存EventDetailCard
- 「Web Preview」: EventWebPreview
- 「Insta Preview」: EventInstaPreview
- 「Insta投稿文」: EventInstaCaption

### 新規コンポーネント (`src/app/admin/(authenticated)/events/[id]/_components/`)

**`EventWebPreview.tsx`**
- ユーザー画面と同じレイアウトでイベントを表示
- Step 2で作成したコンポーネント群を `@/app/(user)/events/[id]/_components/` からインポートして再利用
- プレビューコンテナ（ボーダー付き）で囲む

**`EventInstaPreview.tsx`**
- Instagram投稿風のビジュアルモックアップ
- サムネイル画像(4:5) + キャプション表示
- Instagram風のUIで表示（白カード、丸角、プロフィールヘッダー）

**`EventInstaCaption.tsx`**
- `generateInstagramCaption()` でテキスト生成
- 読み取り専用のテキストエリアで表示
- 「コピー」ボタン (`navigator.clipboard.writeText`)
- Sonner (既存) でコピー成功トースト表示
- 文字数カウント表示 (Instagram上限: 2,200文字)

---

## 実装順序

1. Step 1 (instagramCaption.ts) - 依存なし
2. Step 2 (ユーザー画面リファクタ) - 最も影響大
3. Step 3 (EventListItem修正) - 独立
4. Step 4 (shadcn Tabs追加) - Step 5の前提
5. Step 5 (管理画面タブ) - Step 1,2,4に依存

---

## 検証方法

1. `./bin/pnpm tsc` - 型チェック
2. `./bin/check` - lint + format
3. `./bin/dev` で開発サーバー起動
4. ユーザー画面 `/events/{id}` で構造化データ表示を確認
5. ユーザー画面 `/events` でリスト価格表示を確認
6. 管理画面 `/admin/events/{id}` で4タブ全て確認
7. Insta投稿文タブのコピーボタン動作確認
