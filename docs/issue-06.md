## Work Plan Step 4 — Home Screen & Navigation Shell

**Parallel:** Depends on Issue #2 (Bootstrap). Can start before backend issues complete using mock data.

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `HomeView.swift` — main screen with grid/list of account type cards:
  - Each card shows: SF Symbol icon, account type name, brief description
  - Account types: Exchanges, Contributors, Locations, Devices, Links, Users, Multicast Groups, Tenants, Access Passes, Reservations
  - Tapping a card navigates to the account list for that type
- [ ] Implement `ContentView.swift` with NavigationStack and navigation path management
- [ ] Implement gear icon in toolbar that opens SettingsView
- [ ] Implement bottom toolbar/tab area with search functionality
- [ ] Implement `HomeViewModel.swift` — manages the list of account types and their metadata
- [ ] Create `Views/CLAUDE.md` documenting view layer conventions and patterns

## Acceptance Criteria

- Home screen displays all 10 account types in an organized grid/list
- Each account type has an appropriate SF Symbol icon
- Tapping an account type navigates to a placeholder list view
- Gear icon is visible and accessible in the toolbar
- Navigation back button works from list view to home
- App looks presentable on iPhone in both light and dark mode
