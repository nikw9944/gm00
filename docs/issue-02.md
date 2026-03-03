## Work Plan Step 0 — Project Bootstrap & Documentation Foundation

**Parallel:** None (must be first — all other issues depend on this)

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

- [ ] Initialize Xcode project (SwiftUI lifecycle, iOS 17+ deployment target, scheme: `gm00`)
- [ ] Create `.gitignore` for Xcode/Swift (xcuserdata, DerivedData, .build, etc.)
- [ ] Create top-level `README.md` with:
  - Project overview (gm00 = DoubleZero serviceability browser for iOS)
  - Prerequisites: macOS 14+, Xcode 16+
  - Getting started instructions
  - Architecture overview (SwiftUI + MVVM, pure Swift, no dependencies)
- [ ] Create top-level `CLAUDE.md` with:
  - Project overview and architecture description
  - Build and test commands (xcodebuild)
  - Coding conventions (SwiftUI patterns, MVVM, naming)
  - Links to subdirectory CLAUDE.md files
- [ ] Create `scripts/setup.sh` (one-time dev environment setup — verify Xcode, simulators)
- [ ] Create `docs/account-types.md` with full reference of all 10 browsable DoubleZero account types, their fields, and cross-references
- [ ] Create initial directory structure matching the project layout in the work plan

## Acceptance Criteria

- Xcode project opens and builds successfully (empty app, blank screen is fine)
- xcodebuild build succeeds from command line
- README.md explains how to get started
- CLAUDE.md provides enough context for Claude Code to assist with development
