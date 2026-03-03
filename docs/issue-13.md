## Work Plan Step 11 — Test Suite & Fixtures

**Parallel:** Run alongside each feature issue. Tests should be written as features are built.

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

### Test Fixtures

- [ ] Fetch sample account data from devnet for each of the 10 account types
- [ ] Store as base64-encoded test fixture files in the test bundle
- [ ] Include edge cases: empty vecs, zero-length strings, deprecated/zeroed fields
- [ ] Document how to refresh fixtures from devnet

### Unit Tests

- [ ] `BorshDecoderTests.swift` — All primitive types, strings, vecs, options, enums from known byte sequences
- [ ] `ModelDeserializationTests.swift` — Each account type deserialized from real on-chain data snapshots
- [ ] `SolanaRPCClientTests.swift` — Mock URLSession, verify request formation, response parsing, error handling
- [ ] `AccountResolverTests.swift` — Given raw account data, correctly identify type and deserialize
- [ ] `SearchTests.swift` — Search matches across different field types, case-insensitive, partial

### Integration Test Plan (Manual)

- [ ] Document manual test plan in README:
  1. Launch on Simulator -> Home screen shows all 10 account types
  2. Tap "Exchanges" -> List loads, sorted by code
  3. Tap an exchange -> Detail shows all fields
  4. Tap device1_pk link -> Navigates to Device detail
  5. Tap back -> Returns to Exchange detail
  6. Search "ATL" -> Results show matching accounts across types
  7. Open Settings -> Switch to testnet -> Data refreshes
  8. Enter custom URL -> Validates and connects
  9. Test with no network -> Shows error state
  10. Test with empty account types -> Shows empty state

## Acceptance Criteria

- All unit test suites pass
- Test fixtures include real devnet data for each account type
- Manual test plan is documented and reproducible
- Edge cases (empty data, errors, unknown enums) are covered
