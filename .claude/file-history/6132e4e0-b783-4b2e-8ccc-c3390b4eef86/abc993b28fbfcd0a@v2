---
tags:
  - react
  - component
  - server
  - rendering
created_at: 2026-01-03
updated_at: 2026-03-22
status: active
---

# renderingってなんだ？

レンダリングとは、日本語にすると描画する。とか訳される。これはbrowser rendering(paintと表現したりする。)

ただし、browserがHTMLをcssやJSと一緒に表示する。ときに言われる描画する。とは異なります。

`rendering engine`でいわれる内容とも少し異なるらしい。

## React語としてのrender

**「レンダー」とは、React がコンポーネントを呼び出すことです。**
もっというと、VirtualDOMが成果物
[レンダーとコミット – React](https://ja.react.dev/learn/render-and-commit)

ただし！SSRで登場で、Hydrationという概念とともに、serverでstatic HTMLが生成されるようになりました。

## renderingの正体 - 共通プロセスと分岐点

CSR でも SSR でも、共通プロセスは **React コンポーネントの実行 → React Element ツリーの生成** まで。
分岐するのはその後:

- **SSR**: React Element ツリーを**トラバースしながら直接 HTML 文字列を出力**する
  - `renderToString` 等がこの処理を担う
  - Virtual DOM を完全に構築してから変換する2段階プロセス**ではない**（ストリーミング的に処理される）
- **CSR**: React Element ツリーから diff（reconciliation）→ DOM API で実 DOM ノードを操作

「Virtual DOM がそのまま成果物」なのではなく、あくまで**中間表現**。最終的な成果物は SSR なら HTML 文字列、CSR なら実 DOM ノードへの操作。

## 業界標準の理解

Next.js公式ドキュメント(最新)やReact公式ドキュメントでは:

- **Client Components** = "クライアント側でインタラクティブ性が必要なコンポーネント"
- サーバーとクライアントの両方でレンダリングされる
- SSR + Hydrationのハイブリッドアプローチ

dynamic renderingとは？SSGについて

![RSC rendering lifecycle](Attachments/4-wire-diagram-rsc-rendering-lifecycle.jpg)

## 関連ノート

- [hydrationとは？？](hydrationとは？？.md) - SSR後のクライアント側プロセス
- [RSC(React Server Component)](RSC(React%20Server%20Component).md) - Server/Client Componentの仕組み
- [SC/CC vs CSR/SSR - 2つの分類軸を理解する](SC%20CC%20vs%20CSR%20SSR%20-%202つの分類軸を理解する.md) - 直交する2つの概念の統合的理解
- [Static and Dynamic Rendering](Static%20and%20Dynamic%20Rendering.md) - App RouterにおけるSSR/SSGの再定義
