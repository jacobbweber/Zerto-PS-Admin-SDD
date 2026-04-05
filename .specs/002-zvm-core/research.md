# Phase 0: Outline & Research - ZertoZVM.Core

## Decisions

### 1. Thread-Safe File Append Pattern
**Decision**: Implement `[System.IO.File]::AppendAllLines()` wrapped inside an exponential-backoff, retry-based helper function (`Invoke-ThreadSafeFileWrite`).
**Rationale**: In heavily parallel runspace-driven configurations, standard PowerShell cmdlets like `Add-Content` frequently run into "file in use by another process" locking failures (even if those processes are just sibling runspaces within the same parent). 
**Alternatives Considered**:
- Mutexes (`[System.Threading.Mutex]`): Rejected as overly complex for local logging and risks locking up primary application logic paths on failure.
- Out-File / Add-Content: Rejected due to explicit lock conflicts during nano-second simultaneous access.

### 2. Configuration Bootstrapping Object Structure
**Decision**: Import JSON via `ConvertFrom-Json` without `-AsHashTable` and store natively as a `PSObject` (`$Global:Config`).
**Rationale**: `PSObject` hierarchy (`$Config.base.logging.paths`) matches the spec perfectly and is inherently read-safe universally across contexts.

## Outstanding Clarifications
None. Design paths are rigidly supported by constraints.
