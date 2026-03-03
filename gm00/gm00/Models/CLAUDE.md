# Models Layer — Claude Code Instructions

## Overview

Each file in this directory defines a Swift struct that maps 1:1 to a Rust account struct from the DoubleZero serviceability program. The Borsh binary layout must match exactly.

## Adding a New Account Type

1. Find the Rust struct in `smartcontract/programs/doublezero-serviceability/src/state/`
2. Create a new Swift file matching the struct name
3. Define the struct with fields in the EXACT same order as Rust
4. Implement `BorshDecodable` — decode fields in order
5. Add `Identifiable` (via `pubkey`), `Hashable` conformance
6. Add `searchableText` computed property
7. Add the discriminator to `AccountType.swift`
8. Add to `AccountTypeInfo.browsableTypes`

## Borsh Layout Rules

- Fields are decoded in declaration order
- `u8` → `UInt8`, `u16` → `UInt16`, `u32` → `UInt32`, `u64` → `UInt64`
- `u128` → `(high: UInt64, low: UInt64)` — low word first
- `f64` → `Double`
- `bool` → `Bool` (1 byte)
- `String` → 4-byte LE length + UTF-8 bytes
- `Pubkey` → 32 bytes → Base58 String
- `Vec<T>` → 4-byte LE count + elements
- `Option<T>` → 1-byte tag (0=None, 1=Some) + value
- `Ipv4Addr` → 4 bytes → "a.b.c.d" String
- `NetworkV4` → 4 bytes IP + 1 byte prefix → NetworkV4 struct
- Enum → 1-byte discriminant

## Special: DZUser

DZUser has a `displayCode: String?` property that is NOT part of the Borsh layout. It is set post-deserialization by the view model, which fetches the parent Device and Exchange accounts to build the composite code: `exchange.code:device.code:tunnel_id`.

## Special: Tenant

TenantAccount does NOT have an `index` field (unlike most other account types). Its PDA is derived from the tenant code, not an index.

## Special: AccessPass

AccessPassType is a variable-size enum:
- Variant 0 (Prepaid): no extra data
- Variants 1-4: contain a Pubkey (32 bytes)
- Variant 5 (Others): contains two Strings
