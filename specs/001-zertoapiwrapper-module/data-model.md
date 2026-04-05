# Data Model: ZertoZVM.APIWrapper

**Date**: 2026-04-05

## State Entity

### `ZertoSession` (Module Scoped)
Maintains the actively connected API state across the process lifecycle.
- **`BaseUri`** `[string]`: Parsed URL combining hostname, port, and API version.
- **`ApiVersion`** `[string]`: Targeting endpoints. Defaulting to `v1`.
- **`Headers`** `[hashtable]`: Injects REST standard content type and `x-zerto-session` authentication tokens.
- **`TokenTimestamp`** `[DateTime]`: Marker to determine 5-minute expiration window before token recycle.
- **`Connected`** `[bool]`: Status flag.
- **`SkipCertificateCheck`** `[bool]`: Tracks user parameter for bypassing TLS issues in test environments.
- **`CachedCredential`** `[PSCredential]`: Secure store containing username and password to seamlessly re-authenticate without human intervention.

## Resource Entities (PSCustomObjects)

### `ZertoVPG`
Virtual Protection Group details mapping perfectly to `/v1/vpgs`.
- Identifiers: `VpgIdentifier`, `Name`
- Core fields: `Status`, `SubStatus`, `ActualRPO`, `ConfiguredRPO`

### `ZertoVRA`
Virtual Replication Appliance tracking.
- Identifiers: `VraIdentifier`, `Name`
- Core fields: `Status`, `IpAddress`, `VraGroup`

### `ZertoTask`
Represents asynchronous actions fired by state mutating operations.
- Identifiers: `TaskId`
- Used to poll loop queries against `/v1/tasks/{TaskId}`.

### `ZertoAlert`
System health and replication notifications.
- Core attributes: `Level` (Warning/Error), `TurnedOn`, `Description`
