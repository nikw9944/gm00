## Proposed GitHub Issues

The following issues should be created for this project. Issue body files are available in `docs/issue-NN.md`.

**Note:** `gh issue create` is not available in the current automation permissions. These issues need to be created manually or by an operator with appropriate access.

### Dependency Graph

```
Issue #2 (Bootstrap) ─── must be first
  ├──→ Issue #3 (RPC Client) ──────┐
  ├──→ Issue #4 (Borsh Decoder) ───┤
  │                                 ├──→ Issue #5 (Models) ──┬──→ Issue #7 (List Screen)
  │                                 │                        ├──→ Issue #8 (Detail Screens) ──→ Issue #9 (Cross-Nav)
  │                                 │                        └──→ Issue #10 (Search)
  ├──→ Issue #6 (Home/Nav Shell) ───┘
  ├──→ Issue #11 (Settings) ── independent after #2
  ├──→ Issue #12 (Claude Integration) ── ongoing throughout
  └──→ Issue #13 (Test Fixtures) ── ongoing throughout
                                                              └──→ Issue #14 (Final Docs)
```

### Issue List

| # | Title | Step | Labels | Can Parallel With | Depends On |
|---|-------|------|--------|-------------------|------------|
| 2 | Project Bootstrap & Documentation Foundation | 0 | setup | None (first) | None |
| 3 | Solana RPC Client | 1 | feature, backend | #4 | #2 |
| 4 | Borsh Decoder | 2 | feature, backend | #3 | #2 |
| 5 | Account Type Models | 3 | feature, backend | #6 | #4 |
| 6 | Home Screen & Navigation Shell | 4 | feature, ui | #3, #4, #5 (mock data) | #2 |
| 7 | Account List Screen | 5 | feature, ui | #8, #10 | #3, #4, #5 |
| 8 | Account Detail Screens | 6 | feature, ui | #7, #10 | #3, #4, #5 |
| 9 | Cross-Account Navigation | 7 | feature, ui | #10 | #7, #8 |
| 10 | Search | 8 | feature, ui | #7, #8 | #3, #4, #5 |
| 11 | Settings / Environment Selector | 9 | feature, ui | Any after #2 | #2 |
| 12 | Claude Integration (CLAUDE.md, Skills) | 10 | dx | All (ongoing) | #2 |
| 13 | Test Suite & Fixtures | 11 | testing | All (ongoing) | #2 |
| 14 | Final README & Documentation Polish | 12 | documentation | None (last) | All |
