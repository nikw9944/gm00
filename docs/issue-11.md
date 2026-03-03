## Work Plan Step 9 — Settings / Environment Selector

**Parallel:** Can run independently after Issue #2 (Bootstrap). No dependencies on other feature issues.

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Implement `SettingsView.swift`:
  - Picker for environment: Devnet, Testnet, Mainnet-Beta
  - Text field for custom RPC URL input
  - Display currently selected environment
  - "Test Connection" button to verify RPC URL is reachable
  - Save selection (persists across app launches)
- [ ] Implement `SettingsViewModel.swift`:
  - Store selected environment in @AppStorage (UserDefaults)
  - Validate custom URL format
  - Test RPC connection on URL change (make a simple getVersion call)
  - Map environment to correct program ID:
    - Devnet: GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah
    - Testnet: DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb
    - Mainnet: ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv
- [ ] Update SolanaRPCClient to use the selected environment's RPC URL and program ID
- [ ] On environment change: clear cached data and trigger refresh of visible data
- [ ] Show current environment indicator in the main screen header/toolbar

## Acceptance Criteria

- User can switch between devnet, testnet, and mainnet-beta
- User can enter a custom RPC URL
- Environment persists across app launches
- Switching environments refreshes displayed data
- Invalid custom URLs show an error
- Current environment is visible from the main screen
