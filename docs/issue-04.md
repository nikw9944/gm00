## Work Plan Step 2 — Borsh Decoder

**Parallel:** Can run with Issue #3 (Solana RPC Client). Depends on Issue #2 (Bootstrap).

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `BorshDecoder.swift` supporting all required types:
  - Primitives: u8, u16, u32, u64, u128, i64, f64, bool
  - String — 4-byte little-endian length prefix + UTF-8 bytes
  - Pubkey — 32 raw bytes, Base58 string representation
  - Vec of T — 4-byte little-endian count + elements
  - Option of T — 1-byte tag (0=None, 1=Some) + value
  - Ipv4Addr — 4 bytes
  - NetworkV4 — 4 bytes IPv4 + 1 byte prefix length
  - Enum variants — 1-byte discriminator index + variant-specific data
- [ ] Define `BorshDecodable` protocol
- [ ] Implement `NetworkTypes.swift`:
  - IPv4Address type (4 bytes, formatted display "x.x.x.x")
  - NetworkV4 type (IPv4 + prefix length, formatted "x.x.x.x/y")
- [ ] Write `BorshDecoderTests.swift`:
  - Test each primitive type with known byte sequences
  - Test String decoding (empty, short, max length)
  - Test Vec decoding (empty, multiple elements)
  - Test Option decoding (None, Some)
  - Test Pubkey decoding (32 bytes to correct Base58)
  - Test enum variant decoding
  - Test error cases (EOF, invalid UTF-8, negative length)
  - Test nested types (Vec of Strings, Option of Pubkey)

## Technical Notes

- All integers are little-endian (Borsh spec)
- The first byte of every DoubleZero account is the AccountType discriminator (not Anchor's 8-byte hash — this is a native Solana program)
- Strings: 4-byte LE length prefix, then that many UTF-8 bytes
- Vecs: 4-byte LE count, then that many elements serialized consecutively
- Enums: single byte for variant index, followed by variant data (if any)
- u128 is 16 bytes little-endian (used for account indices)

## Acceptance Criteria

- All Borsh types used by DoubleZero accounts can be decoded correctly
- BorshDecodable protocol allows each model type to implement its own decoding
- Comprehensive unit tests pass with known byte sequences
- Error reporting includes byte offset of failure for debugging
