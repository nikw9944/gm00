# gm00 — Claude Code Instructions

## Project Overview

gm00 is a native iOS (SwiftUI) app that browses the DoubleZero ledger's serviceability program on Solana. It displays all on-chain account types, supports deep navigation between linked accounts, and provides full-text search.

## Build & Test

```bash
# Build for simulator
xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

- **SwiftUI + MVVM** — Declarative UI with ObservableObject view models
- **Pure Swift** — No external dependencies. URLSession for HTTP, custom Borsh decoder
- **iOS 17+** — NavigationStack, modern SwiftUI features
- **Solana JSON-RPC** — Direct HTTP POST to Solana RPC endpoints

## Directory Structure

- `gm00/gm00/App/` — App entry point, root ContentView with NavigationStack
- `gm00/gm00/Models/` — Account type structs matching Rust layouts ([Models CLAUDE.md](gm00/gm00/Models/CLAUDE.md))
- `gm00/gm00/Services/` — RPC client, Borsh decoder, Base58 ([Services CLAUDE.md](gm00/gm00/Services/CLAUDE.md))
- `gm00/gm00/ViewModels/` — View models for each screen
- `gm00/gm00/Views/` — SwiftUI views, detail views, components ([Views CLAUDE.md](gm00/gm00/Views/CLAUDE.md))
- `gm00/gm00/Utilities/` — NetworkV4 type, String/Data extensions
- `gm00/gm00Tests/` — Unit tests

## Coding Conventions

- Use Swift naming conventions: camelCase for properties/methods, PascalCase for types
- All account models conform to `BorshDecodable`, `Identifiable`, `Hashable`
- Pubkeys are stored as Base58-encoded Strings
- Enums use `UInt8` raw values matching Rust discriminants
- View models are `@MainActor` and use `@Published` properties
- Error states show retry buttons; loading states show ProgressView

## Key Design Decisions

1. **No Rust FFI** — Pure Swift JSON-RPC is simpler for a read-only app
2. **First-byte discriminator** — DoubleZero uses a single byte (not Anchor's 8-byte hash)
3. **User composite codes** — Resolved post-deserialization by fetching Device → Exchange
4. **Client-side search** — Fetch all accounts, filter in-memory
5. **NavigationStack** — Single stack for all navigation, supports deep linking

## Program IDs

| Cluster | Program ID |
|---------|-----------|
| Devnet | `GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah` |
| Testnet | `DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb` |
| Mainnet | `ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv` |
