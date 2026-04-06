# Research: Get VPG Journal Settings

**Phase 0 Output**

## Decisions & Findings

### 1. ZVM Server Discovery
- **Decision**: Script will use `Test-Path` to verify `E:\source\zvmservers.txt` exists before reading.
- **Rationale**: Prevent "File Not Found" errors in environments where the path might differ or the drive is missing.
- **Mocking**: For Unit/Integration tests, a mock file or an in-memory list will be used via the `-Simulation` switch.

### 2. "Doctor" Mode Implementation
- **Decision**: Output a specific subset of fields (VPGName, VpgIdentifier, ProtectedSiteName) as headerless CSV to `stdout`.
- **Logic**: 
  ```powershell
  if ($Doctor) {
      $Results | Select-Object VPGName, VpgIdentifier, ProtectedSiteName | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1
  }
  ```
- **Rationale**: Adheres to Constitution Section VI requiring headerless CSV output for diagnostics.

### 3. Telemetry KPIs
- **Decision**: Metric names will be `script_name` (string) and `vpg_count` (integer).
- **Rationale**: Consistent with Spec requirements for tracking automation reach.

### 4. Dependency: ZertoZVM.APIWrapper
- **Finding**: `Get-ZertoVPG` is already exported by the `APIWrapper` module.
- **Finding**: `Connect-ZertoZVM` is already exported and supports `-ZVMHost` and `-Credential`.

## Alternatives Considered

- **Alternative**: Store ZVM list in `config.json`.
- **Reason Rejected**: The user specifically requested `E:\source\zvmservers.txt` in the business logic description. We will prioritize the explicit requirement while perhaps offering `config.json` as a secondary fallback in future iterations.
