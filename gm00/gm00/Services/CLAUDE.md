# Services Layer — Claude Code Instructions

## Components

### SolanaRPCClient
- Actor-based (thread-safe) JSON-RPC client
- Uses URLSession for HTTP POST to Solana RPC endpoints
- Key methods: `getAccountInfo`, `getProgramAccounts`, `getMultipleAccounts`, `getAccountsByType`
- Configurable per cluster (devnet/testnet/mainnet) or custom URL
- `getMultipleAccounts` auto-chunks into batches of 100

### BorshDecoder
- Sequential binary reader with cursor tracking
- Call `readU8()`, `readString()`, `readPubkey()`, etc. in field order
- `remaining` property tracks unread bytes
- Throws `BorshDecoderError` on insufficient data or invalid values

### Base58
- Static encode/decode using Bitcoin alphabet
- Used for Solana pubkey display

### AccountResolver
- Given a pubkey, fetches data and determines account type from first byte
- Returns `ResolvedAccount` enum with the typed, deserialized account
- `resolveFromData` for when you already have the raw bytes

## Error Handling

- Network errors wrapped in `RPCError.networkError`
- HTTP non-200 → `RPCError.httpError`
- RPC-level errors → `RPCError.rpcError`
- Account not found → `RPCError.accountNotFound`
- Deserialization failures → `BorshDecoderError`

## Adding Support for a New RPC Method

1. Add a new method to `SolanaRPCClient`
2. Use `makeRequest(method:params:)` for the JSON-RPC call
3. Parse the result dictionary
4. Handle errors appropriately
