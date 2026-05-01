---
tags:
  - react
  - component
  - server
created: 2026-01-03
status: active
---

# **Static and Dynamic Rendering**

[

Static RenderingとFull Route Cache

![](React/Attachments/icon%201.png)<https://zenn.dev/akfm/books/nextjs-basic-principle/viewer/part_3_static_rendering_full_route_cache>

![](React/Attachments/og-base-book_yz4z02%201.jpeg)](<https://zenn.dev/akfm/books/nextjs-basic-principle/viewer/part_3_static_rendering_full_route_cache>)

[

Dynamic RenderingとData Cache｜Next.jsの考え方

![](React/Attachments/icon%201.png)<https://zenn.dev/akfm/books/nextjs-basic-principle/viewer/part_3_dynamic_rendering_data_cache>

![](React/Attachments/og-base-book_yz4z02%201.jpeg)](<https://zenn.dev/akfm/books/nextjs-basic-principle/viewer/part_3_dynamic_rendering_data_cache>)

Next.jsは、従来Pages Routerで[SSR↗︎](https://nextjs.org/docs/pages/building-your-application/rendering/server-side-rendering)・[SSG↗︎](https://nextjs.org/docs/pages/building-your-application/rendering/static-site-generation)・[ISR↗︎](https://nextjs.org/docs/pages/building-your-application/data-fetching/incremental-static-regeneration)という3つのレンダリングモデル[[1]](https://zenn.dev/akfm/books/nextjs-basic-principle/viewer/part_3_static_rendering_full_route_cache#fn-1587-1)をサポートしてきました。App Routerでは上記相当のレンダリングをサポートしつつ、revalidateがより整理され、SSGとISRを大きく区別せずまとめて**Static Rendering**、従来のSSR相当を**Dynamic Rendering**と呼称する形で[サーバー側レンダリングが再定義↗︎](https://nextjs.org/docs/app/getting-started/linking-and-navigating#server-rendering)されました。

