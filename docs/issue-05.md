## Work Plan Step 3 — Account Type Models

**Parallel:** Depends on Issue #4 (Borsh Decoder).

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Define AccountType enum matching Rust discriminators:
  None=0, GlobalState=1, GlobalConfig=2, Location=3, Exchange=4, Device=5, Link=6, User=7, MulticastGroup=8, ProgramConfig=9, Contributor=10, AccessPass=11, ResourceExtension=12, Tenant=13, Reservation=14
- [ ] Define all status/type enums in Enums.swift:
  - LocationStatus, ExchangeStatus, DeviceStatus, DeviceType, DeviceHealth, DeviceDesiredStatus
  - LinkLinkType, LinkStatus, LinkHealth, LinkDesiredStatus
  - UserType, UserCYOA, UserStatus
  - MulticastGroupStatus, ContributorStatus
  - AccessPassType, AccessPassStatus
  - TenantPaymentStatus, TenantBillingConfig
  - InterfaceStatus, InterfaceType, InterfaceCYOA, InterfaceDIA, LoopbackType, RoutingMode
- [ ] Implement Swift structs for all 10 browsable account types:
  - Location.swift — code, name, country, lat/lng, status, reference_count
  - Exchange.swift — code, name, status, lat/lng, bgp_community, device1_pk, device2_pk
  - Device.swift — code, device_type, status, health, public_ip, location/exchange/contributor_pk, interfaces
  - Link.swift — code, link_type, status, health, bandwidth, side_a/z_pk, contributor_pk
  - DZUser.swift — user_type, status, tenant/device_pk, IPs, validator_pubkey
  - MulticastGroup.swift — code, status, tenant_pk, multicast_ip, bandwidth, pub/sub counts
  - Contributor.swift — code, status, reference_count, ops_manager_pk
  - Tenant.swift — code, payment_status, vrf_id, reference_count, administrators, billing
  - AccessPass.swift — client_ip, status, accesspass_type, last_access_epoch, connection_count
  - Reservation.swift — device_pk, client_ip
- [ ] Implement Interface versioned enum (V1, V2) embedded in Device
- [ ] Implement BorshDecodable conformance for each model (exact field order matching Rust)
- [ ] Implement Searchable protocol — each model returns searchable text fields
- [ ] Implement Identifiable, Hashable conformance for SwiftUI usage
- [ ] Create Models/CLAUDE.md documenting model layer conventions
- [ ] Write ModelDeserializationTests.swift with real on-chain data snapshots from devnet

## Cross-Account References

These pubkey fields link to other account types and must be annotated for navigation:
- Exchange: device1_pk -> Device, device2_pk -> Device
- Device: location_pk -> Location, exchange_pk -> Exchange, contributor_pk -> Contributor
- Link: side_a_pk -> Device, side_z_pk -> Device, contributor_pk -> Contributor
- User: tenant_pk -> Tenant, device_pk -> Device
- MulticastGroup: tenant_pk -> Tenant
- Reservation: device_pk -> Device
- AccessPass: mgroup_pub/sub_allowlist -> MulticastGroup list, tenant_allowlist -> Tenant list

## Acceptance Criteria

- All 10 account types deserialize correctly from real devnet data
- All enums handle known and unknown variant values gracefully
- Models conform to Identifiable, Hashable, Searchable
- Unit tests pass with real on-chain data fixtures
