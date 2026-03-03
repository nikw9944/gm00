## Work Plan Step 1 — Solana RPC Client

**Parallel:** Can run with Issue #4 (Borsh Decoder). Depends on Issue #2 (Bootstrap).

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `SolanaRPCClient.swift`:
  - Configurable RPC URL (devnet/testnet/mainnet-beta/custom)
  - getAccountInfo(pubkey:) — fetch single account
  - getProgramAccounts(programId:, filters:) — fetch all accounts with memcmp/dataSize filters
  - getMultipleAccounts(pubkeys:) — batch fetch
  - Proper error handling: network errors, RPC errors, rate limiting, invalid responses
  - Base64 decoding of account data from RPC response
  - JSON-RPC request/response Codable types
- [ ] Implement `Base58.swift`:
  - Encode Data to Base58 string (for pubkey display)
  - Decode Base58 string to Data (for pubkey comparison)
- [ ] Create `Services/CLAUDE.md` documenting the service layer conventions
- [ ] Write `SolanaRPCClientTests.swift`:
  - Mock URLSession using URLProtocol
  - Test request formation (correct JSON-RPC method, params, filters)
  - Test response parsing (valid account data, multiple accounts)
  - Test error cases (network error, RPC error, empty response, malformed JSON)

## Technical Notes

- Use URLSession directly — no external dependencies
- RPC endpoint URLs:
  - Devnet: https://api.devnet.solana.com
  - Testnet: https://api.testnet.solana.com
  - Mainnet: https://api.mainnet-beta.solana.com
- Program IDs per cluster:
  - Mainnet: ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv
  - Devnet: GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah
  - Testnet: DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb
- For filtering by account type, use memcmp filter at offset 0 with the account type discriminator byte (e.g., 4 for Exchange, 5 for Device)

## Acceptance Criteria

- RPC client can fetch single accounts and program accounts from devnet
- Base58 encoding/decoding works correctly
- All unit tests pass
- Error handling covers network failures and RPC errors
