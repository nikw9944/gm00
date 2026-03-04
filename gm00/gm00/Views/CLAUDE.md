# Views Layer — Claude Code Instructions

## View Hierarchy

```
ContentView (NavigationStack root)
├── HomeView — Grid of account type cards
├── AccountListView — List of accounts for one type
├── AccountDetailView — Router to specific detail view
│   ├── LocationDetailView
│   ├── ExchangeDetailView
│   ├── DeviceDetailView
│   ├── LinkDetailView
│   ├── UserDetailView
│   ├── MulticastGroupDetailView
│   ├── ContributorDetailView
│   ├── TenantDetailView
│   ├── AccessPassDetailView
│   └── ReservationDetailView
├── SearchView — Cross-type search
└── SettingsView — Environment selector (sheet)
```

## Navigation Pattern

- `NavigationStack` with `NavigationPath` for programmatic navigation
- `NavigationDestination` enum: `.accountList`, `.accountDetail`, `.searchResults`
- Cross-account links push new detail views onto the stack
- Back button provided automatically by NavigationStack

## Reusable Components

- `PubkeyLinkView` — Tappable pubkey that navigates to account detail
- `StatusBadgeView` — Colored badge for status enums
- `AccountRowView` — Polymorphic list row for all account types
- `IPAddressView` — Monospaced IP display
- `DetailSection` — Grouped section with title and background
- `DetailRow` — Label-value pair for detail views

## Adding a New Detail View

1. Create `{Type}DetailView.swift` in `Views/Detail/`
2. Accept `pubkey: String`, the typed account, and `navigationPath` binding
3. Use `DetailSection` and `DetailRow` for layout
4. Use `PubkeyLinkView` for linked pubkey fields
5. Use `StatusBadgeView` for status fields
6. Add the case to `AccountDetailView.detailContent(for:)`
