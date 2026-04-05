# Research Notes: Global Environment Configuration

## Decisions

### 1. File Format
- **Decision**: JSON
- **Rationale**: Built-in support in PowerShell via `ConvertFrom-Json`. Easily readable by both humans and machines. Explicitly requested in the specification and the Constitution.
- **Alternatives considered**: XML, PSD1 (PowerShell Data File), YAML. JSON is the universally required standard per the constitution framework.

### 2. Validation Mechanism
- **Decision**: Export `Test-ProjectConfig` from the core module (`ZertoZVM.Core`).
- **Rationale**: Ensures the paths specified in `config.json` actually exist on the target system filesystem before `Begin` block lets execution proceed to `Process`.
- **Alternatives considered**: None, this was an explicit spec requirement to isolate module loading dependencies and fail fast.
