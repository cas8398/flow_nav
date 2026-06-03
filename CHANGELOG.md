# Changelog

## 1.0.0

Initial release of `flow_nav`.

### Features

- **`FlowScaffold`** — adaptive scaffold that automatically switches between single-column (phone), split (tablet), and three-column (desktop) layouts
- **`FlowAppBar`** — adaptive AppBar that renders as a standard AppBar on phone and as a custom toolbar widget on tablet/desktop
- **`FlowNavController`** — handles navigation automatically: full-screen push on phone, detail panel swap on larger screens
- **`FlowNavBreakpoint`** — `InheritedWidget`-based breakpoint resolver; use `FlowNavBreakpoint.of(context)` anywhere in the tree
- **`FlowNavConfig`** — global config for breakpoints, body padding/margin, max width, and custom router hooks
- Router-agnostic: works with default `Navigator`, GoRouter, GetX, AutoRoute, or any custom router
- No forced UI — pure layout and navigation orchestration
