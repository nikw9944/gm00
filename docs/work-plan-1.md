# Work Plan: gm00 — DoubleZero Serviceability Browser for iOS

## Summary

Build `gm00`, a native iOS app (SwiftUI) that serves as a read-only browser for the DoubleZero ledger's serviceability program on Solana. The app will display all on-chain account types (Exchanges, Contributors, Locations, Devices, Links, Users, Multicast Groups, Tenants, Access Passes, Reservations), allow drilling into details, support cross-account navigation via linked public keys, provide full-text search across all account fields, and let users switch between Solana clusters (devnet, testnet, mainnet-beta, custom URL). The app's end users are anyone who wants to browse the DZ ledger. The project is built by a Roadbike operator — a senior developer on macOS with minimal iOS experience — so it will include comprehensive CLAUDE.md files, Claude skills, and detailed README documentation to enable AI-assisted development of the codebase.

## Approach

### Architecture Decision: Pure Swift JSON-RPC (No Rust FFI)

**Question from the issue:** *"What's the right way to talk to a Solana program from an iOS app? Can we build Rust code into a shared library that a Swift program can load?"*

**Answer:** Yes, you *can* compile Rust code into a static library/XCFramework that Swift can load via FFI (using tools like Mozilla's UniFFI). However, for this **read-only** app, this approach is unnecessarily complex:

- **Rust FFI adds:** cross-compilation for 3 iOS targets (arm64 device, arm64 sim, x86_64 sim), XCFramework bundling, Tokio runtime management across FFI, large binary size from solana-client's dependency tree (~300 crates), and difficult cross-language debugging.
- **Pure Swift provides:** zero external dependencies, native async/await with URLSession, small binary, straightforward debugging, and the Solana JSON-RPC API is just HTTP POST.

**Recommendation:** Use pure Swift with a thin JSON-RPC client (~200 lines) and a custom Borsh decoder (~200 lines). This is the simplest correct approach for a read-only Solana browser. If transaction signing is ever needed in the future, the `p2p-org/solana-swift` SPM package can be added at that point.

**Note:** The DoubleZero serviceability program is a **native Solana program** (not Anchor-based). There is no IDL file. The account discriminator is a single byte (the `AccountType` enum value at offset 0), not Anchor's 8-byte hash. This simplifies filtering with `getProgramAccounts` using `memcmp` at offset 0.

### Key Technical Decisions

1. **SwiftUI + MVVM** — Modern declarative UI with view models for testability.
2. **No external dependencies** — Pure Swift using URLSession, Foundation, CryptoKit.
3. **Borsh deserialization in Swift** — Hand-written decoder matching the Rust struct layouts exactly. All types are little-endian.
4. **`getProgramAccounts` with `memcmp` filters** — Filter by account type discriminator byte at offset 0 to fetch accounts by type efficiently.
5. **Client-side search** — Fetch all accounts of each type, deserialize, and search in-memory across string/text fields.
6. **NavigationStack** — SwiftUI navigation with programmatic push/pop for cross-account linking and back button.
7. **Minimum iOS 17** — Enables modern SwiftUI features (NavigationStack, Observable macro).

### Program IDs (per cluster)

| Cluster | Program ID |
|---------|-----------|
| Mainnet | `ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv` |
| Devnet | `GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah` |
| Testnet | `DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb` |

### Account Types to Browse

The app will display 10 browsable account types (excluding system singletons GlobalState, GlobalConfig, ProgramConfig, and the internal ResourceExtension type):

| # | Account Type | Discriminator | Code Field | Key Display Fields |
|---|-------------|---------------|------------|-------------------|
| 1 | Exchange | 4 | `code` | code, name, status, lat/lng, bgp_community, device1_pk, device2_pk |
| 2 | Contributor | 10 | `code` | code, status, reference_count, ops_manager_pk |
| 3 | Location | 3 | `code` | code, name, country, status, lat/lng, reference_count |
| 4 | Device | 5 | `code` | code, device_type, status, device_health, public_ip, location_pk, exchange_pk, contributor_pk, users_count/max_users |
| 5 | Link | 6 | `code` | code, link_type, status, link_health, bandwidth, side_a_pk, side_z_pk, contributor_pk |
| 6 | User | 7 | *(composite: `exchange.code:device.code:tunnel_id`, e.g. `fra:allnodes-fra1:507`)* | composite code, user_type, status, dz_ip, client_ip, tenant_pk, device_pk, validator_pubkey |
| 7 | Multicast Group | 8 | `code` | code, status, multicast_ip, max_bandwidth, tenant_pk, publisher_count, subscriber_count |
| 8 | Tenant | 13 | `code` | code, payment_status, vrf_id, reference_count, metro_routing |
| 9 | Access Pass | 11 | *(client_ip)* | client_ip, status, accesspass_type, last_access_epoch, connection_count |
| 10 | Reservation | 14 | *(client_ip)* | client_ip, device_pk |

**User composite code resolution:** The User account stores `device_pk` and `tunnel_id` on-chain, but does not directly store the exchange or device codes. To produce the human-readable composite code (`exchange.code:device.code:tunnel_id`), the app must:
1. Read the User's `device_pk` and `tunnel_id` from the User account data.
2. Fetch the Device account at `device_pk` → read `device.code` and `exchange_pk`.
3. Fetch the Exchange account at `exchange_pk` → read `exchange.code`.
4. Compose: `{exchange.code}:{device.code}:{tunnel_id}`.

For the User list view, this means batch-resolving all referenced Devices and Exchanges (see Step 5 for the strategy).

### Cross-Account Navigation Map

When a detail view shows a Pubkey field that references another account type, it will be rendered as a tappable link:

```
Exchange.device1_pk ──→ Device detail
Exchange.device2_pk ──→ Device detail
Device.location_pk ──→ Location detail
Device.exchange_pk ──→ Exchange detail
Device.contributor_pk ──→ Contributor detail
Link.side_a_pk ──→ Device detail
Link.side_z_pk ──→ Device detail
Link.contributor_pk ──→ Contributor detail
User.tenant_pk ──→ Tenant detail
User.device_pk ──→ Device detail
MulticastGroup.tenant_pk ──→ Tenant detail
Reservation.device_pk ──→ Device detail
AccessPass.mgroup_pub_allowlist ──→ [MulticastGroup details]
AccessPass.mgroup_sub_allowlist ──→ [MulticastGroup details]
AccessPass.tenant_allowlist ──→ [Tenant details]
```

For navigation: fetch the target account by pubkey using `getAccountInfo`, read the first byte to determine its type, deserialize accordingly, and push the appropriate detail view onto the NavigationStack.

### Project Structure

```
gm00/
├── README.md                          # Project overview, setup guide, architecture
├── CLAUDE.md                          # Top-level Claude instructions
├── docs/
│   ├── work-plan-1.md                 # This document
│   └── account-types.md              # Reference doc for all account types
├── gm00/                             # Xcode project root
│   ├── gm00.xcodeproj/
│   ├── gm00/                         # Main app target
│   │   ├── App/
│   │   │   ├── gm00App.swift         # App entry point
│   │   │   └── ContentView.swift     # Root view with NavigationStack
│   │   ├── Models/
│   │   │   ├── CLAUDE.md             # Model layer conventions
│   │   │   ├── AccountType.swift     # AccountType enum matching Rust
│   │   │   ├── Location.swift
│   │   │   ├── Exchange.swift
│   │   │   ├── Device.swift
│   │   │   ├── Link.swift
│   │   │   ├── DZUser.swift          # "DZ" prefix to avoid collision with Swift's User
│   │   │   ├── MulticastGroup.swift
│   │   │   ├── Contributor.swift
│   │   │   ├── Tenant.swift
│   │   │   ├── AccessPass.swift
│   │   │   ├── Reservation.swift
│   │   │   └── Enums.swift           # Status enums, DeviceType, LinkType, etc.
│   │   ├── Services/
│   │   │   ├── CLAUDE.md             # Service layer conventions
│   │   │   ├── SolanaRPCClient.swift # JSON-RPC client
│   │   │   ├── BorshDecoder.swift    # Borsh binary decoder
│   │   │   ├── Base58.swift          # Base58 encoding/decoding
│   │   │   └── AccountResolver.swift # Resolves pubkey → account type + detail
│   │   ├── ViewModels/
│   │   │   ├── HomeViewModel.swift
│   │   │   ├── AccountListViewModel.swift
│   │   │   ├── AccountDetailViewModel.swift
│   │   │   ├── SearchViewModel.swift
│   │   │   └── SettingsViewModel.swift
│   │   ├── Views/
│   │   │   ├── CLAUDE.md             # View layer conventions
│   │   │   ├── HomeView.swift        # Main screen: grid of account types
│   │   │   ├── AccountListView.swift # List of accounts of one type
│   │   │   ├── Detail/
│   │   │   │   ├── AccountDetailView.swift    # Router/dispatcher
│   │   │   │   ├── ExchangeDetailView.swift
│   │   │   │   ├── DeviceDetailView.swift
│   │   │   │   ├── LocationDetailView.swift
│   │   │   │   ├── LinkDetailView.swift
│   │   │   │   ├── UserDetailView.swift
│   │   │   │   ├── MulticastGroupDetailView.swift
│   │   │   │   ├── ContributorDetailView.swift
│   │   │   │   ├── TenantDetailView.swift
│   │   │   │   ├── AccessPassDetailView.swift
│   │   │   │   └── ReservationDetailView.swift
│   │   │   ├── SearchView.swift       # Bottom search bar + results
│   │   │   ├── SettingsView.swift     # Environment selector
│   │   │   └── Components/
│   │   │       ├── PubkeyLinkView.swift       # Tappable pubkey → navigate
│   │   │       ├── StatusBadgeView.swift      # Colored status indicator
│   │   │       ├── AccountRowView.swift       # List row template
│   │   │       └── IPAddressView.swift        # Formatted IP display
│   │   └── Utilities/
│   │       ├── NetworkTypes.swift     # IPv4, NetworkV4 types
│   │       └── Extensions.swift       # Data, String extensions
│   └── gm00Tests/                     # Unit test target
│       ├── BorshDecoderTests.swift
│       ├── SolanaRPCClientTests.swift
│       ├── ModelDeserializationTests.swift
│       ├── AccountResolverTests.swift
│       └── SearchTests.swift
├── .claude/
│   ├── settings.json                  # Claude Code settings
│   └── commands/
│       ├── build.md                   # /build skill
│       ├── test.md                    # /test skill
│       ├── add-account-type.md        # /add-account-type skill
│       └── run-on-simulator.md        # /run-on-simulator skill
└── scripts/
    └── setup.sh                       # One-time dev environment setup
```

## Step-by-Step Plan

### Step 0: Project Bootstrap & Documentation Foundation
**Parallel: No (must be first)**

- Initialize Xcode project with SwiftUI lifecycle, iOS 17+ target
- Set up git with `.gitignore` for Xcode/Swift
- Create top-level `README.md` with project overview, prerequisites (Xcode 16+, macOS), setup instructions
- Create top-level `CLAUDE.md` with:
  - Project overview and architecture
  - Build/test commands (`xcodebuild`, Xcode CLI)
  - Coding conventions (SwiftUI, MVVM, naming)
  - Links to subdirectory CLAUDE.md files
- Create `scripts/setup.sh` for one-time environment setup
- Create `docs/account-types.md` reference document

### Step 1: Solana RPC Client
**Parallel: Can run with Step 2**

- Implement `SolanaRPCClient` with:
  - Configurable RPC URL (devnet/testnet/mainnet-beta/custom)
  - `getAccountInfo(pubkey:)` → raw Data
  - `getProgramAccounts(programId:filters:)` → [(pubkey, Data)]
  - `getMultipleAccounts(pubkeys:)` → [Data?]
  - Error handling: network errors, RPC errors, rate limiting
  - Base64 decoding of account data
- Implement `Base58` encoder/decoder (needed for pubkey display)
- Write unit tests with mock responses
- Create `Services/CLAUDE.md`

### Step 2: Borsh Decoder
**Parallel: Can run with Step 1**

- Implement `BorshDecoder` supporting:
  - Primitives: `u8`, `u16`, `u32`, `u64`, `u128`, `i64`, `f64`, `bool`
  - `String` (4-byte LE length prefix + UTF-8)
  - `Pubkey` (32 bytes → Base58 string)
  - `Vec<T>` (4-byte LE count + elements)
  - `Option<T>` (1-byte tag + value)
  - `Ipv4Addr` (4 bytes)
  - `NetworkV4` (4 bytes IP + 1 byte prefix length)
  - Enum variants (1-byte discriminator)
- Implement `NetworkTypes.swift` for IP address and network types
- Write comprehensive unit tests with known byte sequences
- Test round-trip correctness against Rust Borsh output

### Step 3: Account Type Models
**Parallel: Depends on Step 2**

- Define Swift structs for all 10 browsable account types matching Rust layouts exactly
- Define all status/type enums: `LocationStatus`, `ExchangeStatus`, `DeviceStatus`, `DeviceType`, `DeviceHealth`, `DeviceDesiredStatus`, `LinkLinkType`, `LinkStatus`, `LinkHealth`, `LinkDesiredStatus`, `UserType`, `UserCYOA`, `UserStatus`, `MulticastGroupStatus`, `ContributorStatus`, `AccessPassType`, `AccessPassStatus`, `TenantPaymentStatus`, `InterfaceStatus`, `InterfaceType`, `InterfaceCYOA`, `InterfaceDIA`, `LoopbackType`, `RoutingMode`
- Define `Interface` versioned enum (V1, V2) embedded in Device
- Define `AccountType` enum with discriminator values
- Implement `BorshDecodable` protocol conformance for each type
- Implement `Searchable` protocol: each model returns its searchable text fields
  - **DZUser's `Searchable` implementation** must include the composite code (`exchange.code:device.code:tunnel_id`) once resolved. The model will store an optional `displayCode: String?` property that is populated post-deserialization during list/detail loading (see Step 5).
- Implement `Identifiable`, `Hashable` for SwiftUI list usage
- **DZUser model**: include a mutable `displayCode: String?` property (not part of Borsh layout, set after deserialization) to hold the resolved composite code
- Create `Models/CLAUDE.md`
- Write deserialization tests using real on-chain data snapshots (fetch sample accounts from devnet and store as test fixtures)

### Step 4: Home Screen & Navigation Shell
**Parallel: Can start after Step 0; UI can use mock data initially**

- Implement `HomeView`: grid/list of account type cards showing:
  - Icon (SF Symbol), name, brief description
  - Account types: Exchanges, Contributors, Locations, Devices, Links, Users, Multicast Groups, Tenants, Access Passes, Reservations
- Implement `ContentView` with `NavigationStack` and navigation path management
- Implement gear icon in toolbar → `SettingsView`
- Implement tab bar or bottom toolbar with search
- Create `Views/CLAUDE.md`

### Step 5: Account List Screen
**Parallel: Depends on Steps 1, 2, 3**

- Implement `AccountListView` — generic list view parameterized by account type
- Implement `AccountListViewModel`:
  - Fetches accounts using `getProgramAccounts` with `memcmp` filter on discriminator byte
  - Deserializes all accounts using appropriate model
  - Sorts by `code` field (alphabetically) where available; by composite code for Users; by IP for AccessPasses/Reservations
  - Loading state, error state, empty state, pull-to-refresh
- **User composite code resolution strategy:**
  1. Fetch all User accounts via `getProgramAccounts`.
  2. Collect all unique `device_pk` values from the User accounts.
  3. Batch-fetch all referenced Device accounts using `getMultipleAccounts` (batches of up to 100 pubkeys per RPC call).
  4. From the fetched Devices, collect all unique `exchange_pk` values.
  5. Batch-fetch all referenced Exchange accounts using `getMultipleAccounts`.
  6. Build a lookup map: `device_pk → (device.code, exchange.code)`.
  7. For each User, compose `displayCode = "{exchange.code}:{device.code}:{tunnel_id}"` and set the `displayCode` property.
  8. Sort the User list alphabetically by `displayCode`.
  9. **Caching:** Cache the Device→code and Exchange→code mappings in the view model so that subsequent searches, refreshes, and detail views can reuse them without re-fetching.
  10. **Fallback:** If a Device or Exchange account cannot be fetched (deleted, wrong program), display `"???:{tunnel_id}"` as the fallback code.
- Implement `AccountRowView` — shows code (primary), plus 2-3 key fields per type
- Implement list row formatting per account type:
  - Exchange: code, name, status badge
  - Device: code, device_type, status, health badge
  - Location: code, name, country flag
  - Link: code, side_a → side_z, status, bandwidth
  - User: composite code (`exchange.code:device.code:tunnel_id`), user_type, status
  - MulticastGroup: code, multicast_ip, status
  - Contributor: code, status
  - Tenant: code, payment_status
  - AccessPass: client_ip, type, status
  - Reservation: client_ip, device link

### Step 6: Account Detail Screens
**Parallel: Can split across developers/issues; depends on Steps 1-3**

- Implement `AccountDetailView` — router that reads account type and dispatches to specific detail view
- Implement `AccountDetailViewModel` — fetches single account by pubkey, determines type, deserializes
- Implement 10 detail views, one per account type, showing all fields:
  - Field labels and formatted values
  - Pubkey fields rendered as `PubkeyLinkView` (tappable, navigates to target account)
  - Status fields rendered as `StatusBadgeView` (colored)
  - IP addresses rendered as `IPAddressView`
  - Lat/lng shown on a small MapKit view or as text
  - Vec fields shown as expandable lists
  - Interfaces (Device) shown as nested expandable sections
- **UserDetailView** — shows the composite code (`exchange.code:device.code:tunnel_id`) as the primary identifier at the top of the detail view. The view model resolves this by fetching the User's referenced Device and then the Device's referenced Exchange. All other User fields are displayed below.
- Implement `AccountResolver` — given a pubkey, fetches account data, reads discriminator byte, returns the typed account

### Step 7: Cross-Account Navigation
**Parallel: Depends on Steps 5, 6**

- Implement `PubkeyLinkView` — displays truncated pubkey, tappable
- On tap: use `AccountResolver` to fetch target account → push detail view onto NavigationStack
- Handle loading state (spinner while fetching linked account)
- Handle error state (account not found, wrong program, network error)
- Back button provided automatically by NavigationStack
- Deep navigation: Exchange → Device → Location → back → back → back

### Step 8: Search
**Parallel: Depends on Steps 1-3, 5**

- Implement `SearchView` — search bar at bottom of screen (or as a tab)
- Implement `SearchViewModel`:
  - On search: fetch all accounts across all types (or use cached data)
  - Filter by matching search text against all string/text fields (code, name, country, IPs, pubkeys)
  - **For Users:** search matches against the composite code (`exchange.code:device.code:tunnel_id`) — requires that User accounts have their `displayCode` resolved (use cached Device/Exchange data from the list view model or resolve on demand)
  - Results grouped by account type
  - Each result tappable → navigates to detail view
- Optimize: cache fetched account data to avoid re-fetching on each search
- Consider debouncing search input (300ms delay)

### Step 9: Settings / Environment Selector
**Parallel: Can run with Steps 4-8**

- Implement `SettingsView`:
  - Picker for: Devnet, Testnet, Mainnet-Beta
  - Text field for custom RPC URL
  - Current environment shown in main screen header
  - Stored in `@AppStorage` (UserDefaults)
- Implement `SettingsViewModel` with validation (test RPC connection on URL change)
- Update `SolanaRPCClient` to use the correct program ID per cluster
- On environment change, clear cached data (including Device/Exchange code caches) and refresh

### Step 10: Claude Integration (CLAUDE.md, Skills, Subagents)
**Parallel: Can run throughout, should be updated incrementally**

**Top-level `CLAUDE.md`:**
- Project overview: gm00 is an iOS SwiftUI app browsing DoubleZero Solana accounts
- Build command: `xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' build`
- Test command: `xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' test`
- Architecture: SwiftUI + MVVM, pure Swift, no external dependencies
- Directory structure overview
- Links to subdirectory CLAUDE.md files
- Coding conventions: Swift naming, SwiftUI patterns, error handling

**Subdirectory CLAUDE.md files:**
- `gm00/gm00/Models/CLAUDE.md` — How account models map to Rust structs, Borsh layout rules, how to add a new account type. **Must document that DZUser has a `displayCode` property that is not part of the Borsh layout and must be resolved post-deserialization by fetching the parent Device and Exchange accounts.**
- `gm00/gm00/Services/CLAUDE.md` — RPC client design, Borsh decoder API, error handling patterns
- `gm00/gm00/Views/CLAUDE.md` — View hierarchy, navigation patterns, component reuse, how to add a new detail view

**Claude Skills (`.claude/commands/`):**
- `/build` — Build the project for simulator
- `/test` — Run all unit tests
- `/add-account-type` — Step-by-step guide for adding a new DoubleZero account type (model + detail view + list row + tests)
- `/run-on-simulator` — Build and launch on iOS Simulator

### Step 11: Testing
**Parallel: Tests written alongside each step**

**Unit Tests:**
- `BorshDecoderTests` — Decode all primitive types, strings, vecs, options, enums from known byte sequences
- `ModelDeserializationTests` — Deserialize each account type from real on-chain data snapshots (fetched from devnet and stored as test fixture `.bin` files in the test bundle)
- `SolanaRPCClientTests` — Mock URLSession, verify request formation, response parsing, error handling
- `AccountResolverTests` — Given raw account data, correctly identify type and deserialize
- `SearchTests` — Verify search matches across different field types, **including User composite code search** (e.g. searching "fra:allnodes" matches the User with that composite code)

**Integration Tests:**
- Manual testing against devnet (documented test plan in README)
- Test navigation flows: Home → List → Detail → Linked Account → Back → Back
- Test environment switching
- Test search across all account types
- **Test User list loading**: verify composite codes are displayed correctly, sorted alphabetically, and that fallback display works when Device/Exchange accounts are missing

**Test Fixtures:**
- Store sample account data (base64-encoded) from each devnet account type
- Include edge cases: empty vecs, zero-length strings, deprecated fields
- **Include User + associated Device + Exchange fixtures** to test composite code resolution end-to-end

### Step 12: README & Final Documentation
**Parallel: Updated incrementally throughout**

`README.md` contents:
- Project description and screenshots
- Prerequisites: macOS 14+, Xcode 16+, iOS 17+ target
- Getting started: clone, open .xcodeproj, build & run
- Architecture overview with diagram
- Account types reference (link to docs/account-types.md)
- How to add a new account type
- Testing instructions
- Environment configuration
- Contributing guidelines
- Claude Code usage instructions

## Files to Change

### New Files (Created)

| File | Description |
|------|------------|
| `README.md` | Project overview, setup, architecture |
| `CLAUDE.md` | Top-level Claude Code instructions |
| `docs/work-plan-1.md` | This work plan |
| `docs/account-types.md` | DoubleZero account type reference |
| `.gitignore` | Xcode/Swift ignores |
| `scripts/setup.sh` | Dev environment setup script |
| `.claude/commands/build.md` | /build skill |
| `.claude/commands/test.md` | /test skill |
| `.claude/commands/add-account-type.md` | /add-account-type skill |
| `.claude/commands/run-on-simulator.md` | /run-on-simulator skill |
| `gm00/gm00.xcodeproj/` | Xcode project (generated) |
| `gm00/gm00/App/gm00App.swift` | App entry point |
| `gm00/gm00/App/ContentView.swift` | Root navigation view |
| `gm00/gm00/Models/CLAUDE.md` | Model layer conventions |
| `gm00/gm00/Models/AccountType.swift` | AccountType enum |
| `gm00/gm00/Models/Location.swift` | Location model |
| `gm00/gm00/Models/Exchange.swift` | Exchange model |
| `gm00/gm00/Models/Device.swift` | Device model |
| `gm00/gm00/Models/Link.swift` | Link model |
| `gm00/gm00/Models/DZUser.swift` | User model (with `displayCode` for composite code) |
| `gm00/gm00/Models/MulticastGroup.swift` | MulticastGroup model |
| `gm00/gm00/Models/Contributor.swift` | Contributor model |
| `gm00/gm00/Models/Tenant.swift` | Tenant model |
| `gm00/gm00/Models/AccessPass.swift` | AccessPass model |
| `gm00/gm00/Models/Reservation.swift` | Reservation model |
| `gm00/gm00/Models/Enums.swift` | All status/type enums |
| `gm00/gm00/Services/CLAUDE.md` | Service layer conventions |
| `gm00/gm00/Services/SolanaRPCClient.swift` | JSON-RPC client |
| `gm00/gm00/Services/BorshDecoder.swift` | Borsh binary decoder |
| `gm00/gm00/Services/Base58.swift` | Base58 encoding |
| `gm00/gm00/Services/AccountResolver.swift` | Pubkey → typed account resolver |
| `gm00/gm00/ViewModels/HomeViewModel.swift` | Home screen VM |
| `gm00/gm00/ViewModels/AccountListViewModel.swift` | Account list VM (includes User composite code resolution) |
| `gm00/gm00/ViewModels/AccountDetailViewModel.swift` | Account detail VM |
| `gm00/gm00/ViewModels/SearchViewModel.swift` | Search VM |
| `gm00/gm00/ViewModels/SettingsViewModel.swift` | Settings VM |
| `gm00/gm00/Views/CLAUDE.md` | View layer conventions |
| `gm00/gm00/Views/HomeView.swift` | Main screen |
| `gm00/gm00/Views/AccountListView.swift` | Account list |
| `gm00/gm00/Views/Detail/AccountDetailView.swift` | Detail router |
| `gm00/gm00/Views/Detail/ExchangeDetailView.swift` | Exchange detail |
| `gm00/gm00/Views/Detail/DeviceDetailView.swift` | Device detail |
| `gm00/gm00/Views/Detail/LocationDetailView.swift` | Location detail |
| `gm00/gm00/Views/Detail/LinkDetailView.swift` | Link detail |
| `gm00/gm00/Views/Detail/UserDetailView.swift` | User detail (shows composite code as primary ID) |
| `gm00/gm00/Views/Detail/MulticastGroupDetailView.swift` | MulticastGroup detail |
| `gm00/gm00/Views/Detail/ContributorDetailView.swift` | Contributor detail |
| `gm00/gm00/Views/Detail/TenantDetailView.swift` | Tenant detail |
| `gm00/gm00/Views/Detail/AccessPassDetailView.swift` | AccessPass detail |
| `gm00/gm00/Views/Detail/ReservationDetailView.swift` | Reservation detail |
| `gm00/gm00/Views/SearchView.swift` | Search UI |
| `gm00/gm00/Views/SettingsView.swift` | Settings/environment |
| `gm00/gm00/Views/Components/PubkeyLinkView.swift` | Tappable pubkey |
| `gm00/gm00/Views/Components/StatusBadgeView.swift` | Status indicator |
| `gm00/gm00/Views/Components/AccountRowView.swift` | List row |
| `gm00/gm00/Views/Components/IPAddressView.swift` | IP display |
| `gm00/gm00/Utilities/NetworkTypes.swift` | IPv4, NetworkV4 |
| `gm00/gm00/Utilities/Extensions.swift` | Data/String extensions |
| `gm00/gm00Tests/BorshDecoderTests.swift` | Borsh decoder tests |
| `gm00/gm00Tests/SolanaRPCClientTests.swift` | RPC client tests |
| `gm00/gm00Tests/ModelDeserializationTests.swift` | Model tests |
| `gm00/gm00Tests/AccountResolverTests.swift` | Resolver tests |
| `gm00/gm00Tests/SearchTests.swift` | Search tests |

### Modified Files

| File | Description |
|------|------------|
| `README.md` | Updated incrementally as features are added |
| `CLAUDE.md` | Updated incrementally as patterns emerge |

## Risks & Considerations

### Technical Risks

1. **Borsh deserialization correctness** — The account structs must match the Rust layouts *exactly* (field order, sizes, enum variant indices). A single byte offset error will corrupt all subsequent fields. **Mitigation:** Test against real on-chain data from devnet; store test fixtures.

2. **`getProgramAccounts` rate limiting** — This is an expensive RPC call. Public RPC endpoints may rate-limit or return partial results. **Mitigation:** Cache results aggressively; add pagination if needed; document that users may want to use a private RPC provider for mainnet.

3. **Large account sets** — Some account types (Users, AccessPasses) may have thousands of entries. **Mitigation:** Use `memcmp` filters to reduce server-side; implement client-side pagination in the list view; consider lazy loading.

4. **User composite code resolution adds extra RPC calls** — Loading the User list requires fetching all Users, then batch-fetching their Devices, then batch-fetching the Exchanges. This is 3 sequential RPC round-trips (Users → Devices → Exchanges) plus potential batching for large sets. **Mitigation:** Use `getMultipleAccounts` to batch up to 100 pubkeys per call; cache Device and Exchange code mappings across views; show the User list immediately with a loading indicator for composite codes, then populate them as they resolve. If this proves too slow, consider pre-fetching all Devices and Exchanges on app launch.

5. **Account schema changes** — The DoubleZero program may update account layouts. **Mitigation:** Pin to a known program version; document how to update models; the `/add-account-type` Claude skill helps with this.

6. **No Xcode CLI on the build server** — The Roadbike CI environment may not have Xcode. **Mitigation:** Build/test verification is done locally by the operator. CI can validate Swift syntax and run `swift build` for non-UI code if a Package.swift is provided alongside the Xcode project.

### Backward Compatibility

- N/A — greenfield project, no existing users or APIs.

### Edge Cases

- Accounts with empty `code` fields — display pubkey (truncated) as fallback
- Accounts with deprecated/zeroed fields — display "N/A" or hide
- Network offline — show cached data or clear error message
- Invalid custom RPC URL — validate before saving, show error
- Account not found when following a link — show "Account not found" error view
- User accounts with legacy PDA seeds vs. new PDA seeds — both are valid, handle gracefully
- **User with missing/deleted Device or Exchange** — display fallback composite code `"???:{tunnel_id}"` or `"{device.code}:???:{tunnel_id}"` when parent accounts cannot be resolved

## Testing Strategy

### Unit Tests (~80% coverage target)

| Test Suite | What It Tests |
|-----------|---------------|
| `BorshDecoderTests` | All primitive types, strings, vecs, options, enums, nested structs. Known byte sequences → expected values. |
| `ModelDeserializationTests` | Each account type deserialized from real on-chain data snapshots (stored as `.bin` fixtures). Verifies all fields decoded correctly. |
| `SolanaRPCClientTests` | Request formation (correct JSON-RPC format, filters). Response parsing. Error handling (network errors, RPC errors, malformed responses). Uses `URLProtocol` mock. |
| `AccountResolverTests` | Given raw account data with different discriminator bytes, resolves to correct type. Handles unknown discriminators gracefully. |
| `SearchTests` | Search matches partial strings, case-insensitive. Matches across code, name, IP, pubkey fields. **Verifies User composite code search** (e.g., searching "allnodes-fra1" matches Users on that device). Empty search returns nothing. |

### Manual Test Plan (documented in README)

1. Launch on Simulator → Home screen shows all 10 account types
2. Tap "Exchanges" → List loads, sorted by code
3. Tap an exchange → Detail shows all fields
4. Tap device1_pk link → Navigates to Device detail
5. Tap back → Returns to Exchange detail
6. Tap back → Returns to Exchange list
7. **Tap "Users" → List loads with composite codes (e.g., `fra:allnodes-fra1:507`), sorted alphabetically**
8. **Tap a user → Detail shows composite code as primary identifier, plus all other fields**
9. Search "ATL" → Results show matching accounts across types
10. **Search "allnodes" → Results include matching Users by composite code**
11. Open Settings → Switch to testnet → Data refreshes
12. Enter custom URL → Validates and connects

## Estimated Scope

**Large (2000+ lines)** — This is a full iOS app with 10 account types, each requiring a model, detail view, and list row. Estimated breakdown:

| Component | Lines |
|-----------|-------|
| Services (RPC, Borsh, Base58, Resolver) | ~600 |
| Models (10 types + enums) | ~800 |
| Views (home, list, 10 details, search, settings, components) | ~1200 |
| ViewModels (includes User composite code resolution logic) | ~500 |
| Tests | ~650 |
| Documentation (README, CLAUDE.md files, account-types.md) | ~400 |
| Xcode project config, scripts, skills | ~100 |
| **Total** | **~4250** |

## GitHub Issues Breakdown

The following issues should be created, each referencing this work plan:

### Issue #2: Project Bootstrap & Documentation Foundation (Step 0)
**Parallel: None (must be first)**
- Initialize Xcode project, .gitignore, README.md, CLAUDE.md, scripts/setup.sh
- Labels: `setup`, `documentation`

### Issue #3: Solana RPC Client (Step 1)
**Parallel: Can run with Issue #4**
- Implement SolanaRPCClient, Base58, unit tests
- Labels: `feature`, `backend`

### Issue #4: Borsh Decoder (Step 2)
**Parallel: Can run with Issue #3**
- Implement BorshDecoder, NetworkTypes, unit tests
- Labels: `feature`, `backend`

### Issue #5: Account Type Models (Step 3)
**Parallel: Depends on Issue #4**
- Define all Swift structs, enums, BorshDecodable conformance, tests
- **DZUser model includes `displayCode: String?` property for composite code resolution**
- Labels: `feature`, `backend`

### Issue #6: Home Screen & Navigation Shell (Step 4)
**Parallel: Depends on Issue #2; can start before backend issues complete using mock data**
- Implement HomeView, ContentView, NavigationStack setup
- Labels: `feature`, `ui`

### Issue #7: Account List Screen (Step 5)
**Parallel: Depends on Issues #3, #4, #5**
- Implement AccountListView, AccountListViewModel, AccountRowView, list formatting
- **Implement User composite code resolution: batch-fetch Devices and Exchanges, build `exchange.code:device.code:tunnel_id` display codes**
- Labels: `feature`, `ui`

### Issue #8: Account Detail Screens (Step 6)
**Parallel: Depends on Issues #3, #4, #5; the 10 detail views can be split further if needed**
- Implement all 10 detail views, AccountDetailView router, AccountResolver
- **UserDetailView shows composite code as primary identifier**
- Labels: `feature`, `ui`

### Issue #9: Cross-Account Navigation (Step 7)
**Parallel: Depends on Issues #7, #8**
- Implement PubkeyLinkView, navigation from detail views to linked accounts
- Labels: `feature`, `ui`

### Issue #10: Search (Step 8)
**Parallel: Depends on Issues #3, #4, #5**
- Implement SearchView, SearchViewModel, search across all account types
- **User search matches against composite code**
- Labels: `feature`, `ui`

### Issue #11: Settings / Environment Selector (Step 9)
**Parallel: Can run with Issues #6-#10**
- Implement SettingsView, environment picker, custom URL input, persistence
- Labels: `feature`, `ui`

### Issue #12: Claude Integration — CLAUDE.md, Skills, Subagents (Step 10)
**Parallel: Can run throughout**
- Create/update all CLAUDE.md files, Claude skills, documentation
- Labels: `documentation`, `dx`

### Issue #13: Test Suite & Fixtures (Step 11)
**Parallel: Run alongside each feature issue**
- Collect devnet test fixtures, write integration-level tests, document manual test plan
- **Include User + Device + Exchange fixture set for composite code testing**
- Labels: `testing`

### Issue #14: Final README & Documentation Polish (Step 12)
**Parallel: After all features complete**
- Final README with screenshots, architecture diagram, complete setup guide
- Labels: `documentation`

### Dependency Graph

```
Issue #2 (Bootstrap)
  ├──→ Issue #3 (RPC Client) ──┐
  ├──→ Issue #4 (Borsh) ───────┤
  │                             ├──→ Issue #5 (Models) ──┬──→ Issue #7 (List + User code resolution)
  │                             │                        ├──→ Issue #8 (Details)──→ Issue #9 (Cross-Nav)
  │                             │                        └──→ Issue #10 (Search)
  ├──→ Issue #6 (Home/Nav) ─────┘
  ├──→ Issue #11 (Settings) — independent, can run anytime after #2
  ├──→ Issue #12 (Claude) — ongoing throughout
  └──→ Issue #13 (Tests) — ongoing throughout
                                                          └──→ Issue #14 (Final Docs)
```

## Open Questions

1. **Xcode availability in CI** — The Roadbike build environment likely doesn't have Xcode. Should we provide a `Package.swift` for the non-UI code (Services, Models) so `swift build` / `swift test` can run in CI? Or is all testing manual on the developer's Mac?

2. **Account data size limits** — How many accounts of each type exist on devnet/mainnet? If there are 10,000+ Users, `getProgramAccounts` may time out on public RPCs. Should we implement server-side pagination or recommend a private RPC provider?

3. **Program version compatibility** — The DoubleZero program is actively developed. Should the app check `ProgramConfig.version` and warn if the account schema may have changed?

4. **Offline mode** — Should the app cache data for offline browsing, or is it always online?

5. **iPad support** — Should the app support iPad layouts (split view), or is iPhone-only sufficient for v1?

6. **User composite code pre-fetching** — Should the app eagerly pre-fetch all Device and Exchange accounts on launch (to make User composite code resolution instant), or lazily resolve them only when the User list is opened? Eager pre-fetching adds startup latency but makes subsequent navigation snappier.
