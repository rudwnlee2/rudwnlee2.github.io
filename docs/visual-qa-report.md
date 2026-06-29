# Visual QA Report

Date: 2026-06-29

## Scope

This pass checked the MVP direction for a Jekyll-based technical blog:

- Simple top navigation: `전체`, `Backend`, `프로젝트`
- Desktop left category rail with expandable 2-3 depth navigation
- Post detail hierarchy for title, summary, date, views, comments, tags, code block, table of contents, related posts
- Dark mode, search, copy button feedback, and mobile layout behavior
- A/B comparison between the left-rail layout and a denser index-first layout

## Evidence

- Generated project thumbnail: `assets/img/thumbnail/backend-notes.png`
- MVP preview: `visual-preview-post.html`
- A/B variant: `design-sample-ab-variant.html`
- Desktop screenshot: `tmp/screenshots/mvp-desktop-cdp.png`
- Mobile screenshot: `tmp/screenshots/mvp-mobile-cdp.png`
- A/B screenshot: `tmp/screenshots/variant-b.png`

## Build And Browser QA

Jekyll build passed with Ruby 3.2:

```text
Configuration file: E:/project/jekyll-theme-satellite/_config.yml
Source: E:/project/jekyll-theme-satellite
Destination: E:/project/jekyll-theme-satellite/_site
Jekyll Feed: Generating feed for posts
done in 23.319 seconds.
```

The build emits Dart Sass deprecation warnings for existing `@import` and `map-get` usage. They do not block generation.

The local Jekyll server responded at:

```text
http://127.0.0.1:4000/Backend/readable-code.html -> 200
```

Chrome DevTools Protocol checks passed:

```json
{
  "mobileMetrics": {
    "clientWidth": 390,
    "scrollWidth": 390,
    "title": "다시 읽기 쉬운 코드를 남기는 기준",
    "searchInitiallyOpen": false
  },
  "searchOpened": true,
  "darkModeToggled": true,
  "copyFeedbackShown": true,
  "categoryToggleChanged": true,
  "hoverStateChanged": true
}
```

The first mobile preview screenshot showed horizontal overflow. The root cause was grid children with the default `min-width: auto`, which let prose and code blocks push the layout wider than the viewport. The fix adds `min-width: 0` to content grid children and narrows mobile heading behavior.

The first live Jekyll click test did not show copy feedback under synthetic browser execution. The copy logic now includes an `execCommand` fallback, and the CDP test marks the copy click as a user gesture.

## Visual Findings

- Desktop hierarchy is clear: left category rail, article hero, thumbnail, and right-side utility rail each have distinct roles.
- Spacing is calm and readable. The title has strong presence without hiding date, views, comments, or category context.
- The generated thumbnail supports the Backend/project-writing tone without becoming a marketing hero.
- Mobile now avoids horizontal overflow in measured browser layout.
- Hover and active states use background, border, and color changes without causing layout shift.

## A/B Decision

Variant A, the left category rail layout, is the better MVP for this blog because it supports long-term category growth and post-detail orientation.

Variant B, the dense index layout, is useful when the post count is small and discovery matters more than hierarchy, but it weakens 2-3 depth category browsing.

## Runtime Note

Ruby was not initially available on `PATH`. Ruby 3.2 with DevKit was installed through `winget`, and commands were run with `C:\Ruby32-x64\bin` prepended to `PATH`.

`wdm 0.1.1` does not build against Ruby 3.2 in this environment. Since `wdm` is only a Windows file watcher helper, the Gemfile now installs it only on Ruby versions below 3.2.
