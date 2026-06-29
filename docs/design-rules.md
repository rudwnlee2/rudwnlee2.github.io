# Technical Blog Design Rules

## Information Architecture

- Keep the top navigation to the primary entry points: `전체`, `Backend`, `프로젝트`.
- Use the left category rail for location and deeper browsing, not for every possible tag.
- Default to two category levels. Add a third level only when a topic has enough posts to justify it.

## Post Detail

- The first screen must make the title, description, category path, date, views, comments, and thumbnail clear.
- Keep table of contents and related posts in the right rail on desktop.
- Collapse to a single reading column on mobile and let utility controls move below the article flow.
- Code blocks need a visible copy button with an immediate copied state.

## Visual System

- Use quiet surfaces, thin dividers, and restrained accent color so code and writing remain the focus.
- Do not let decorative imagery compete with the article title.
- Use `min-width: 0` on grid children that contain prose, code, or sidebars to prevent mobile overflow.
- On narrow screens, allow Korean headings to break more aggressively than body text when needed.

## Interaction Rules

- Search, dark mode, category expansion, tag search, table of contents, and copy buttons must be reachable by pointer on desktop and mobile.
- Hover states should change border or text color, not layout size.
- The active category and active table-of-contents item should be visible without relying on color alone.
