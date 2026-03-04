# DoubleZero Account Types Reference

This document describes all account types in the DoubleZero serviceability program that gm00 browses.

## Account Type Discriminators

| # | Type | Discriminator Byte |
|---|------|-------------------|
| 0 | None | 0 |
| 1 | GlobalState | 1 |
| 2 | GlobalConfig | 2 |
| 3 | Location | 3 |
| 4 | Exchange | 4 |
| 5 | Device | 5 |
| 6 | Link | 6 |
| 7 | User | 7 |
| 8 | MulticastGroup | 8 |
| 9 | ProgramConfig | 9 |
| 10 | Contributor | 10 |
| 11 | AccessPass | 11 |
| 12 | ResourceExtension | 12 |
| 13 | Tenant | 13 |
| 14 | Reservation | 14 |

The app browses types 3-8, 10-11, 13-14 (10 browsable types).

## Location (Discriminator: 3)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 3 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| lat | f64 | Latitude |
| lng | f64 | Longitude |
| loc_id | u32 | Location ID |
| status | LocationStatus | Pending/Activated/Suspended |
| code | String | Short code (e.g., "ATL") |
| name | String | Full name |
| country | String | 2-char country code |
| reference_count | u32 | Number of references |

## Exchange (Discriminator: 4)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 4 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| lat | f64 | Latitude |
| lng | f64 | Longitude |
| bgp_community | u16 | BGP community (10000-10999) |
| unused | u16 | Padding |
| status | ExchangeStatus | Pending/Activated/Suspended |
| code | String | Short code |
| name | String | Full name |
| reference_count | u32 | Number of references |
| device1_pk | Pubkey | First device |
| device2_pk | Pubkey | Second device |

## Device (Discriminator: 5)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 5 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| location_pk | Pubkey | Location reference |
| exchange_pk | Pubkey | Exchange reference |
| device_type | DeviceType | Hybrid/Transit/Edge |
| public_ip | Ipv4Addr | Public IP address |
| status | DeviceStatus | See DeviceStatus enum |
| code | String | Device code |
| dz_prefixes | Vec<NetworkV4> | DZ network prefixes |
| metrics_publisher_pk | Pubkey | Metrics publisher |
| contributor_pk | Pubkey | Contributor reference |
| mgmt_vrf | String | Management VRF |
| interfaces | Vec<Interface> | Network interfaces (V1/V2) |
| reference_count | u32 | Number of references |
| users_count | u16 | Current users |
| max_users | u16 | Maximum users |
| device_health | DeviceHealth | Health status |
| desired_status | DeviceDesiredStatus | Desired status |
| unicast_users_count | u16 | Unicast users |
| multicast_users_count | u16 | Multicast users |
| max_unicast_users | u16 | Max unicast |
| max_multicast_users | u16 | Max multicast |
| reserved_seats | u16 | Reserved seats |

## Link (Discriminator: 6)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 6 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| side_a_pk | Pubkey | Side A device |
| side_z_pk | Pubkey | Side Z device |
| link_type | LinkLinkType | WAN/DZX |
| bandwidth | u64 | Bandwidth in bps |
| mtu | u32 | MTU bytes |
| delay_ns | u64 | Delay in nanoseconds |
| jitter_ns | u64 | Jitter in nanoseconds |
| tunnel_id | u16 | Tunnel ID |
| tunnel_net | NetworkV4 | Tunnel network |
| status | LinkStatus | See LinkStatus enum |
| code | String | Link code |
| contributor_pk | Pubkey | Contributor |
| side_a_iface_name | String | Side A interface name |
| side_z_iface_name | String | Side Z interface name |
| delay_override_ns | u64 | Delay override |
| link_health | LinkHealth | Health status |
| desired_status | LinkDesiredStatus | Desired status |

## User (Discriminator: 7)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 7 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| user_type | UserType | IBRL/EdgeFiltering/Multicast |
| tenant_pk | Pubkey | Tenant reference |
| device_pk | Pubkey | Device reference |
| cyoa_type | UserCYOA | Connection type |
| client_ip | Ipv4Addr | Client IP |
| dz_ip | Ipv4Addr | DZ IP |
| tunnel_id | u16 | Tunnel ID |
| tunnel_net | NetworkV4 | Tunnel network |
| status | UserStatus | See UserStatus enum |
| publishers | Vec<Pubkey> | Publisher pubkeys |
| subscribers | Vec<Pubkey> | Subscriber pubkeys |
| validator_pubkey | Pubkey | Validator key |
| tunnel_endpoint | Ipv4Addr | Tunnel endpoint IP |

**Display Code**: Users are displayed as `exchange.code:device.code:tunnel_id` by resolving `device_pk` → Device → `exchange_pk` → Exchange.

## MulticastGroup (Discriminator: 8)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 8 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| tenant_pk | Pubkey | Tenant reference |
| multicast_ip | Ipv4Addr | Multicast IP |
| max_bandwidth | u64 | Max bandwidth bps |
| status | MulticastGroupStatus | See enum |
| code | String | Group code |
| publisher_count | u32 | Publisher count |
| subscriber_count | u32 | Subscriber count |

## Contributor (Discriminator: 10)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 10 |
| owner | Pubkey | Account owner |
| index | u128 | Unique index |
| bump_seed | u8 | PDA bump |
| status | ContributorStatus | See enum |
| code | String | Contributor code |
| reference_count | u32 | Number of references |
| ops_manager_pk | Pubkey | Ops manager |

## AccessPass (Discriminator: 11)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 11 |
| owner | Pubkey | Account owner |
| bump_seed | u8 | PDA bump |
| accesspass_type | AccessPassType | Variable-size enum |
| client_ip | Ipv4Addr | Client IP |
| user_payer | Pubkey | Payer account |
| last_access_epoch | u64 | Last access epoch |
| connection_count | u16 | Connection count |
| status | AccessPassStatus | See enum |
| mgroup_pub_allowlist | Vec<Pubkey> | Pub allowlist |
| mgroup_sub_allowlist | Vec<Pubkey> | Sub allowlist |
| flags | u8 | Bit flags |
| tenant_allowlist | Vec<Pubkey> | Tenant allowlist |

## Tenant (Discriminator: 13)

Note: Tenant does NOT have an index field.

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 13 |
| owner | Pubkey | Account owner |
| bump_seed | u8 | PDA bump |
| code | String | Tenant code |
| vrf_id | u16 | VRF ID |
| reference_count | u32 | Number of references |
| administrators | Vec<Pubkey> | Admin pubkeys |
| payment_status | TenantPaymentStatus | Delinquent/Paid |
| token_account | Pubkey | Token account |
| metro_routing | bool | Metro routing enabled |
| route_liveness | bool | Route liveness enabled |
| billing | TenantBillingConfig | Billing config |

## Reservation (Discriminator: 14)

| Field | Type | Description |
|-------|------|-------------|
| account_type | u8 | Always 14 |
| owner | Pubkey | Account owner |
| bump_seed | u8 | PDA bump |
| device_pk | Pubkey | Device reference |
| client_ip | Ipv4Addr | Client IP |
