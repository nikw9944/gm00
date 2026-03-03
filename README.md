# gm00 — DoubleZero Serviceability Browser

A native iOS app for browsing the DoubleZero ledger's serviceability program on Solana. View all on-chain account types, drill into details, navigate between linked accounts, and search across the entire ledger.

## Features

- **Browse 10 account types**: Exchanges, Contributors, Locations, Devices, Links, Users, Multicast Groups, Tenants, Access Passes, Reservations
- **Detailed views**: See all on-chain data for each account with formatted displays
- **Cross-account navigation**: Tap linked pubkeys to jump to related accounts
- **Full-text search**: Search across all account types by code, name, IP, or pubkey
- **Multi-environment**: Switch between Devnet, Testnet, Mainnet-Beta, or custom RPC URL
- **User composite codes**: Users display as `exchange.code:device.code:tunnel_id` (e.g., `fra:allnodes-fra1:507`)

## Prerequisites

- macOS 14+ (Sonoma or later)
- Xcode 16+
- iOS 17+ deployment target
- No external dependencies required

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/nikw9944/gm00.git
   cd gm00
   ```

2. Run the setup script:
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

3. Open the Xcode project:
   ```bash
   open gm00/gm00.xcodeproj
   ```

4. Select an iOS Simulator target and press Cmd+R to build and run.

## Build & Test (CLI)

```bash
# Build for simulator
xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

### Pure Swift — No External Dependencies

The app communicates directly with Solana's JSON-RPC API using `URLSession`. Account data is deserialized from Borsh binary format using a custom Swift decoder. No Rust FFI, no SPM packages.

### SwiftUI + MVVM

- **Models**: Swift structs matching Rust account layouts exactly, with `BorshDecodable` conformance
- **Views**: SwiftUI views with `NavigationStack` for deep linking
- **ViewModels**: `@Observable` / `ObservableObject` view models handling async data loading
- **Services**: `SolanaRPCClient` (JSON-RPC), `BorshDecoder`, `Base58`, `AccountResolver`

### Project Structure

```
gm00/
├── gm00/gm00/
│   ├── App/           # App entry point, root navigation
│   ├── Models/        # Account type structs, enums
│   ├── Services/      # RPC client, Borsh decoder, Base58
│   ├── ViewModels/    # View models for each screen
│   ├── Views/         # SwiftUI views
│   │   ├── Detail/    # Per-account-type detail views
│   │   └── Components/# Reusable UI components
│   └── Utilities/     # Network types, extensions
├── gm00/gm00Tests/    # Unit tests
├── docs/              # Work plan, account type reference
└── scripts/           # Development scripts
```

### Solana Integration

| Cluster | Program ID |
|---------|-----------|
| Devnet | `GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah` |
| Testnet | `DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb` |
| Mainnet | `ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv` |

The app uses `getProgramAccounts` with `memcmp` filters on the first-byte discriminator to fetch accounts by type. Individual accounts are fetched with `getAccountInfo`. Batch fetches use `getMultipleAccounts`.

### Account Types

See [docs/account-types.md](docs/account-types.md) for the complete reference of all account type structures, fields, and enum values.

## Adding a New Account Type

If the DoubleZero program adds a new account type:

1. Add the discriminator constant to `AccountType.swift`
2. Create a new model file in `Models/` matching the Rust struct layout
3. Add the type to `AccountTypeInfo.browsableTypes`
4. Create a detail view in `Views/Detail/`
5. Add a case to `AccountResolver` and `AccountRowView`
6. Add deserialization tests
7. Add the source files to the Xcode project

## Manual Test Plan

1. Launch on Simulator → Home screen shows all 10 account types
2. Tap "Exchanges" → List loads, sorted by code
3. Tap an exchange → Detail shows all fields
4. Tap device1_pk link → Navigates to Device detail
5. Tap back → Returns to Exchange detail
6. Tap "Users" → List loads with composite codes (e.g., `fra:allnodes-fra1:507`)
7. Search "ATL" → Results show matching accounts
8. Open Settings → Switch to testnet → Data refreshes
9. Enter custom RPC URL → Validates and connects

## Environment Configuration

The app defaults to Devnet. Use the gear icon to:
- Select Devnet, Testnet, or Mainnet-Beta
- Enter a custom RPC URL and Program ID
- Test the connection before saving

## Claude Code Usage

This project includes Claude Code configuration for AI-assisted development:
- See `CLAUDE.md` for top-level instructions
- See subdirectory `CLAUDE.md` files for layer-specific conventions
- Use `/build`, `/test`, `/add-account-type`, `/run-on-simulator` skills

## License

[Add license information here]
