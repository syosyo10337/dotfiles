---
tags:
  - react
  - component
  - server
  - hydration
created_at: 2026-01-03
updated_at: 2026-03-22
status: active
---

# hydrationとは？？

> Hydration is the process that happens when React reconstructs its Virtual Document Object Model (DOM) on the client side based on what was in the DOM of the initial HTML.

ハイドレーションとは、Reactが初期HTMLのDOM内容に基づいて、
クライアントサイドでVirtual DOMを再構築する際に発生するプロセスです。

<https://www.smashingmagazine.com/2024/05/forensics-react-server-components/#hydration>

## Hydrationの具体的なプロセス

サーバーが生成した静的な HTML（イベントハンドラなし）に対して、クライアント側の React が以下を行う:

1. **同じコンポーネントツリーから Virtual DOM を構築**
2. **既存の HTML DOM と照合**（一致しないと hydration mismatch エラー）
3. **DOM を作り直すのではなく**、以下を付与・実行する:
   - イベントハンドラの付与
   - state の初期化
   - `useEffect` の実行

重要なのは、既存の DOM ノードを**再利用**する点。SSR が生成した HTML をそのまま活かしつつ、インタラクティビティだけを追加する。

## Dan Abramovの比喩

> 「乾いた HTML に、インタラクティビティの水を注ぐ」

Hydration（水分補給）という名前の由来。静的な HTML という「乾いた」状態に、JavaScript による動的な振る舞いという「水」を与える。

## SSR + Hydrationの課題

- Hydration 完了までは**「見えるが触れない」**状態（HTML は表示されているがイベントが効かない）
- 従来の SSR では**全コンポーネントの JS** がクライアントに送信され、すべてを hydrate する必要があった
- RSC はこの問題を解決: Server Component は hydration 不要 → JS バンドルが削減される

## 関連ノート

- [renderingってなんだ？](renderingってなんだ？.md) - React におけるレンダリングの正体
- [RSC(React Server Component)](RSC(React%20Server%20Component).md) - Hydration不要なServer Componentの仕組み
- [SC/CC vs CSR/SSR - 2つの分類軸を理解する](SC%20CC%20vs%20CSR%20SSR%20-%202つの分類軸を理解する.md) - Hydrationが発生するタイミングの整理
