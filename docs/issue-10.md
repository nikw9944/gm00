## Work Plan Step 8 — Search

**Parallel:** Depends on Issues #3 (RPC), #4 (Borsh), #5 (Models).

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `SearchView.swift`:
  - Search bar at bottom of screen (or as a dedicated tab)
  - Results grouped by account type with section headers
  - Each result row shows the matching account's primary info (same as list row)
  - Tapping a result navigates to the account's detail view
  - Empty state when no search text
  - "No results" state when search returns nothing
- [ ] Implement `SearchViewModel.swift`:
  - On search text change (debounced 300ms): search across all account types
  - For each account type, fetch all accounts (use cached data if available)
  - Match search text against all string/text fields using the Searchable protocol:
    - code, name, country (for Location)
    - IP addresses (formatted as string)
    - Pubkeys (Base58 string)
    - Status values (as string)
  - Case-insensitive matching
  - Results sorted: exact matches first, then partial matches
  - Group results by account type
- [ ] Implement caching layer:
  - Cache fetched and deserialized accounts to avoid re-fetching on each keystroke
  - Cache invalidation on environment change or manual refresh
- [ ] Write `SearchTests.swift`:
  - Test partial string matching
  - Test case-insensitive matching
  - Test matching across different field types (code, IP, pubkey)
  - Test empty search returns no results
  - Test debouncing behavior

## Acceptance Criteria

- Search bar is accessible from any screen
- Typing text shows matching accounts across all types
- Results are grouped by account type
- Tapping a result navigates to the detail view
- Search is responsive (debounced, uses cached data)
- Works across code, name, IP, pubkey, and status fields
