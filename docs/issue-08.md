## Work Plan Step 6 — Account Detail Screens

**Parallel:** Depends on Issues #3, #4, #5. The 10 detail views can be split further if needed.

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `AccountDetailView.swift` — router that reads account type and dispatches to specific detail view
- [ ] Implement `AccountDetailViewModel.swift` — fetches single account by pubkey, determines type, deserializes
- [ ] Implement `AccountResolver.swift` — given a pubkey, fetches account data, reads discriminator byte, returns typed account
- [ ] Implement 10 detail views showing all fields:
  - ExchangeDetailView.swift
  - DeviceDetailView.swift (including nested Interface sections)
  - LocationDetailView.swift
  - LinkDetailView.swift
  - UserDetailView.swift
  - MulticastGroupDetailView.swift
  - ContributorDetailView.swift
  - TenantDetailView.swift
  - AccessPassDetailView.swift
  - ReservationDetailView.swift
- [ ] Implement shared UI components:
  - StatusBadgeView.swift — colored status indicator (green=active, yellow=pending, red=suspended, etc.)
  - IPAddressView.swift — formatted IP display
- [ ] Format fields appropriately:
  - Pubkey fields rendered as tappable links (placeholder for Step 7)
  - Status fields as colored badges
  - IP addresses formatted as "x.x.x.x" or "x.x.x.x/y"
  - Lat/lng as decimal coordinates (or small MapKit view)
  - Vec fields as expandable lists
  - Interfaces (Device) as nested expandable sections
  - Timestamps/epochs with human-readable format
  - Bandwidth in human-readable units (Mbps, Gbps)
- [ ] Write `AccountResolverTests.swift`

## Acceptance Criteria

- Each account type has a dedicated detail view showing all fields
- Fields are formatted appropriately for their data type
- Pubkey fields are visually distinct (ready for navigation in Step 7)
- Status badges use intuitive colors
- Device interfaces are shown in expandable nested sections
- AccountResolver correctly identifies account type from raw data
