## Work Plan Step 10 — Claude Integration (CLAUDE.md, Skills, Subagents)

**Parallel:** Can run throughout the project. Should be updated incrementally as features are built.

**Reference:** See `docs/work-plan-1.md` for full context.

## Tasks

### CLAUDE.md Files

- [ ] Create/finalize top-level `CLAUDE.md`:
  - Project overview: gm00 is an iOS SwiftUI app browsing DoubleZero Solana accounts
  - Build command: xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' build
  - Test command: xcodebuild -scheme gm00 -destination 'platform=iOS Simulator,name=iPhone 16' test
  - Architecture: SwiftUI + MVVM, pure Swift, no external dependencies
  - Directory structure overview with file descriptions
  - Coding conventions: Swift naming, SwiftUI patterns, error handling
  - Links to subdirectory CLAUDE.md files
- [ ] Create `gm00/gm00/Models/CLAUDE.md`:
  - How Swift models map 1:1 to Rust account structs
  - Borsh layout rules: field order must match Rust, all little-endian
  - How to add a new account type (step-by-step)
  - Enum naming conventions
- [ ] Create `gm00/gm00/Services/CLAUDE.md`:
  - RPC client design and API
  - BorshDecoder usage patterns
  - Error handling conventions
  - How to add a new RPC method
- [ ] Create `gm00/gm00/Views/CLAUDE.md`:
  - View hierarchy and navigation patterns
  - How to add a new detail view
  - Component reuse guidelines
  - SwiftUI patterns used (Observable, NavigationStack, etc.)

### Claude Skills

- [ ] Create `.claude/commands/build.md`:
  - Skill to build the project for iOS Simulator
  - Includes the exact xcodebuild command
- [ ] Create `.claude/commands/test.md`:
  - Skill to run all unit tests
  - Includes the exact xcodebuild test command
- [ ] Create `.claude/commands/add-account-type.md`:
  - Step-by-step guide for adding a new DoubleZero account type
  - Lists all files that need to be created/modified
  - Provides templates for model, detail view, list row
- [ ] Create `.claude/commands/run-on-simulator.md`:
  - Skill to build and launch on iOS Simulator
  - Includes simulator boot and app install commands

## Acceptance Criteria

- Claude Code can understand the project structure from CLAUDE.md
- Claude Code can build and test the project using skills
- The add-account-type skill provides enough guidance to add a new type correctly
- Subdirectory CLAUDE.md files document local conventions accurately
