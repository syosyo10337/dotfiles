---
tags:
  - react
  - component
  - server
  - rendering
  - rsc
created_at: 2026-03-22
updated_at: 2026-03-22
status: active
---

# SC/CC vs CSR/SSR - 2つの分類軸を理解する

## 2つの分類軸は直交する概念

| 分類軸    | 粒度                             | 問い                                 |
| --------- | -------------------------------- | ------------------------------------ |
| CSR / SSR | レンダリング戦略（ページ単位）   | 「HTML をどこで生成するか」          |
| SC / CC   | コンポーネントの実行環境（コンポーネント単位） | 「この JS をクライアントに送るか否か」 |

この2つは独立した軸であり、組み合わせで考える必要がある。

## CSR / SSR / RSC の違い

### CSR（Client-Side Rendering）

- サーバーは空の HTML + JS バンドルを返す
- ブラウザが JS を実行し、Virtual DOM → 実 DOM ノードを生成
- JS のダウンロード完了まで白い画面

### SSR（Server-Side Rendering）

- サーバーが React を実行し、`renderToString` 等で HTML 文字列を生成して送信
- ブラウザは即座に HTML を表示できる（速い初期表示）
- ただし**全コンポーネントの JS** もクライアントに送信され、[hydration](hydrationとは？？.md) が必要
- hydration 完了までは「見えるが触れない」状態

### RSC（React Server Components）

- Server Component: サーバーでのみ実行、JS はクライアントに送らない、hydration 不要
- Client Component: `'use client'` で宣言、JS がクライアントに送られ hydration される
- **コンポーネント単位**で「JS を送るか否か」を制御できる

## Client Component はいつ CSR されるのか？

Client Component の[レンダリング](renderingってなんだ？.md)は**タイミングによって異なる**:

### 初回ページロード時

| 種類             | 処理                                              |
| ---------------- | ------------------------------------------------- |
| Server Component | サーバーで実行 → RSC Payload + HTML               |
| Client Component | **サーバーでプリレンダリング** → HTML + hydration  |

初回ロードでは Client Component も**サーバー側で HTML が生成される**（SSR的）。その後クライアントで hydration が行われ、インタラクティブになる。

### クライアントサイドナビゲーション時

| 種類             | 処理                                    |
| ---------------- | --------------------------------------- |
| Server Component | サーバーで再実行 → RSC Payload のみ     |
| Client Component | **ブラウザで JS から直接描画**（CSR的） |

ナビゲーション時は Client Component が CSR 的に処理される。つまり **Client Component が CSR されるのはクライアントサイドナビゲーション時**。

### まとめ

従来の「空 HTML から全部ブラウザで描画」という意味での CSR はなくなったが、ナビゲーション時の Client Component レンダリングとして **CSR 的な処理は残っている**。

## Server Component の「静的さ」の正確な理解

ブラウザ上での Server Component は:

- JS なし、イベントハンドラなし、state なし、hydration なし → **操作不能という意味で静的**
- ただし固定された HTML ではない → サーバーから新しい [RSC Payload](RSC(React%20Server%20Component).md) を受け取れば**更新可能**

RSC Payload がコンポーネントツリーの構造を保持しているため、ページ全体をリロードせずに Server Component 部分だけを差し替えられる。

## Fact Check: SSR での HTML 生成

「SSR では Virtual DOM を生成した上で HTML を成果物としている」と言われることがあるが、より正確には:

> React Element ツリーを**トラバースしながら直接 HTML 文字列を出力する**

Virtual DOM を完全に構築してから変換する2段階プロセスではない。詳細は [renderingってなんだ？](renderingってなんだ？.md) を参照。

## 関連ノート

- [renderingってなんだ？](renderingってなんだ？.md) - React における rendering の正体と SSR/CSR の分岐
- [hydrationとは？？](hydrationとは？？.md) - SSR後のクライアント側プロセス
- [RSC(React Server Component)](RSC(React%20Server%20Component).md) - RSC Payload、Server/Client Componentの生成物
- [Static and Dynamic Rendering](Static%20and%20Dynamic%20Rendering.md) - App RouterにおけるSSR/SSGの再定義
