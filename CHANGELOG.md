# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Home button in toolbar to jump back to home screen from any depth (#6)

### Fixed
- Fix setup.sh failing when only Xcode CommandLineTools is installed (#3)

### Added
- Initial iOS app implementation (#1)
- Browse 10 DoubleZero account types: Exchanges, Contributors, Locations, Devices, Links, Users, Multicast Groups, Tenants, Access Passes, Reservations
- Solana JSON-RPC client for communicating with the DoubleZero serviceability program
- Borsh binary decoder for deserializing on-chain account data
- Base58 encoder/decoder for Solana pubkey display
- Cross-account navigation via tappable pubkey links
- Full-text search across all account types
- User composite code display (exchange.code:device.code:tunnel_id)
- Environment selector: Devnet, Testnet, Mainnet-Beta, Custom RPC URL
- Unit tests for Borsh decoder, model deserialization, account resolution, and search
- Claude Code integration: CLAUDE.md files, /build, /test, /add-account-type, /run-on-simulator skills
- Comprehensive documentation: README.md, account-types.md, work plan
