# Research: ZertoZVM.APIWrapper

**Date**: 2026-04-05
**Feature**: 001-zertoapiwrapper-module

## Consolidated Findings

*(All unknowns resolved during `/speckit-clarify` session prior to planning.)*

1. **Observability**
   - **Decision**: Observability strictly relies on native `Write-Verbose`.
   - **Rationale**: Prevents a cross-dependency on `ZertoZVM.Core` (where `Write-Log` is maintained). Keeps the API layer completely decoupled.

2. **Async Operations (`TaskId`)**
   - **Decision**: `TaskId` is returned only by asynchronous operations (e.g., Failover).
   - **Rationale**: Avoids faking TaskIds for synchronous API endpoints that natively return `204 No Content` or simple JSON bodies. Stays true to the 1:1 API mapping structure.

3. **Concurrency Locks**
   - **Decision**: Concurrent token refresh resolves via "last-writer-wins" (no locks applied).
   - **Rationale**: The specification explicitly constraints this version to single-session designs. Injecting thread-locking logic introduces out-of-scope complexity for a single-session assumption framework.

4. **Credential Lifetime**
   - **Decision**: `CachedCredential` persists for the lifetime of the process unless purged manually.
   - **Rationale**: Empowers `Assert-ZertoSession` to perpetually re-authenticate long-running downstream automation loops without arbitrary mid-flight credential teardowns.

5. **Write Network Targets**
   - **Decision**: Write/Action HTTP calls have the identical 3-second network target as reads.
   - **Rationale**: Ensures network latency tests track only the REST response latency rather than the asynchronous background tasks natively executed on the ZVM side.
