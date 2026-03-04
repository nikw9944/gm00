## Work Plan Step 5 — Account List Screen

**Parallel:** Depends on Issues #3 (RPC Client), #4 (Borsh Decoder), #5 (Models).

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `AccountListView.swift` — generic list view parameterized by account type
- [ ] Implement `AccountListViewModel.swift`:
  - Fetches accounts using getProgramAccounts with memcmp filter on discriminator byte
  - Deserializes all accounts using appropriate model
  - Sorts by code field (alphabetically) where available; by index or IP otherwise
  - Loading state, error state, empty state
  - Pull-to-refresh support
- [ ] Implement `AccountRowView.swift` — shows code (primary), plus 2-3 key fields per type
- [ ] Implement list row formatting per account type:
  - Exchange: code, name, status badge
  - Device: code, device_type, status, health badge
  - Location: code, name, country flag emoji
  - Link: code, side_a to side_z, status, bandwidth
  - User: dz_ip or index, user_type, status
  - MulticastGroup: code, multicast_ip, status
  - Contributor: code, status
  - Tenant: code, payment_status
  - AccessPass: client_ip, type, status
  - Reservation: client_ip, device link

## Technical Notes

- Use memcmp filter at offset 0 with the single-byte discriminator to fetch only accounts of the selected type
- For account types without a code field (User, AccessPass, Reservation), use the most identifiable field as primary display
- Consider large result sets — Users and AccessPasses may have thousands of entries on mainnet
- Show account count in the list header

## Acceptance Criteria

- Tapping an account type on home screen shows all accounts of that type
- Accounts are sorted by code field (or equivalent)
- Each list row shows the most important info at a glance
- Loading, error, and empty states are handled gracefully
- Pull-to-refresh works
- Tapping a row navigates to the detail view
