## Work Plan Step 7 — Cross-Account Navigation

**Parallel:** Depends on Issues #7 (List) and #8 (Details).

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `PubkeyLinkView.swift`:
  - Displays truncated pubkey (first 4...last 4 characters)
  - Styled as a tappable link (blue, underlined or with chevron)
  - Shows the target account type label if known
- [ ] Implement navigation on tap:
  - Use AccountResolver to fetch target account by pubkey
  - Read discriminator byte to determine account type
  - Deserialize into the appropriate model
  - Push the correct detail view onto NavigationStack
- [ ] Handle loading state (spinner while fetching linked account)
- [ ] Handle error states:
  - Account not found (closed/deleted account)
  - Wrong program owner (pubkey belongs to a different program)
  - Network error
  - Unknown account type
- [ ] Back button provided automatically by NavigationStack
- [ ] Test deep navigation chains: Exchange -> Device -> Location -> back -> back -> back

## Navigation Map

These are all the cross-account links that should be tappable:

- Exchange.device1_pk -> Device detail
- Exchange.device2_pk -> Device detail
- Device.location_pk -> Location detail
- Device.exchange_pk -> Exchange detail
- Device.contributor_pk -> Contributor detail
- Link.side_a_pk -> Device detail
- Link.side_z_pk -> Device detail
- Link.contributor_pk -> Contributor detail
- User.tenant_pk -> Tenant detail
- User.device_pk -> Device detail
- MulticastGroup.tenant_pk -> Tenant detail
- Reservation.device_pk -> Device detail
- AccessPass.mgroup_pub_allowlist -> MulticastGroup details (list of links)
- AccessPass.mgroup_sub_allowlist -> MulticastGroup details (list of links)
- AccessPass.tenant_allowlist -> Tenant details (list of links)

## Acceptance Criteria

- All pubkey fields that reference known account types are tappable
- Tapping navigates to the correct detail view for the linked account
- Loading state is shown while fetching the target account
- Error cases show appropriate messages
- Back button works correctly through multi-level navigation
- NavigationStack maintains correct history for deep chains
