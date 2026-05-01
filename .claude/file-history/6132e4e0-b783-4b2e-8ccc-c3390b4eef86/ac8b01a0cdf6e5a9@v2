---
tags:
  - react
  - component
  - server
  - rsc
created_at: 2026-01-03
updated_at: 2026-03-22
status: active
---

# RSC(React Server Component)

RSCでは、Server ComponentsはHTMLとRSC Payload(特殊なJSONフォーマット)を生成します。Client Componentsはプレースホルダーとして含まれ、後でクライアント側でHydrationされます。 [Getting Started: Server and Client Components | Next.js](https://nextjs.org/docs/app/getting-started/server-and-client-components)

## 生成されるもの

1. **HTML**: 完全なページ構造とコンテンツ
2. **RSC Payload**: Server Componentsの実行結果(JSON形式)
3. **JavaScript**: Client Componentsのコード

```TypeScript
// Server Component
async function ServerComponent() {
  const data = await db.query(); // サーバーでのみ実行
  return <div>{data}</div>;       // HTMLに変換
}

// Client Component
'use client'
function ClientComponent() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>
    {count}
  </button>;
}
```

**生成される出力:**

```HTML
<!-- Server Component → 完全なHTML -->
<div>Database result here</div>

<!-- Client Component → プレースホルダー + JavaScript -->
<button>0</button>  <!-- 後でHydration -->
<script>/* Client Component JS */</script>
```

## RSC Payloadとは？

> The RSC Payload is a compact binary representation of the rendered React Server Components tree. It's used by React on the client to update the browser's DOM. The RSC Payload contains:
>
> - The rendered result of Server Components
> - Placeholders for where Client Components should be rendered and references to their JavaScript files
> - Any props passed from a Server Component to a Client Component

renderedされたRSC treeのコンパクトなbinary表現です。

ReactによってClientで使われて、DOMを更新するそうな。

```TypeScript
# 実際のRSC Payloadの例（Next.js）
HL:0:{"hints":["link","font"]}  ← Hint（CSS/フォント）
I:1:{"module":"./Counter.js"}    ← Module（Client Component）
$:2:["div",null,{"children":"Hello"}]  ← DOM定義
```

ref. [RSC Payload](https://www.smashingmagazine.com/2024/05/forensics-react-server-components/#rsc-payload)

## Server Componentの「静的さ」

ブラウザ上での Server Component は:

- **JS なし、イベントハンドラなし、state なし、hydration なし** → 操作不能という意味で静的
- ただし**固定された HTML ではない** → サーバーから新しい RSC Payload を受け取れば更新可能

RSC Payload という中間形式が**コンポーネントツリーの構造を保持**しているため、ページ全体をリロードせずに Server Component 部分だけを差し替えられる。これが従来の SSR（ページ単位のリロードが必要）との大きな違い。

## RSCの革新

コンポーネントツリーの中に**ネットワーク境界（server/client boundary）** を引けるようになったこと。

従来はページ単位で「サーバーで描画するか、クライアントで描画するか」を決めていたが、RSC では**コンポーネント単位**で「JS をクライアントに送るか否か」を制御できる。

## 参考

[Getting Started: Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)

[The Forensics Of React Server Components (RSCs) — Smashing Magazine](https://www.smashingmagazine.com/2024/05/forensics-react-server-components/#the-early-days-react-client-side-rendering)

## 関連ノート

- [renderingってなんだ？](renderingってなんだ？.md) - React におけるレンダリングの正体
- [hydrationとは？？](hydrationとは？？.md) - SSR後のクライアント側プロセス
- [SC/CC vs CSR/SSR - 2つの分類軸を理解する](SC%20CC%20vs%20CSR%20SSR%20-%202つの分類軸を理解する.md) - 直交する2つの概念の統合的理解
- [Static and Dynamic Rendering](Static%20and%20Dynamic%20Rendering.md) - App RouterにおけるSSR/SSGの再定義
