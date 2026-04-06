# Data Model: Get VPG Journal Settings

**Phase 1 Output**

## Action Manifest ($Results)

The `$Results` collection will store a list of VPG Journal Records.

| Property | Type | Description |
|----------|------|-------------|
| **VPGName** | `[string]` | Name of the Virtual Protection Group. |
| **VpgIdentifier** | `[string]` | Zerto internal identifier (ID). |
| **ProtectedSiteName** | `[string]` | The site that is being protected. |
| **ZVMHost** | `[string]` | The ZVM hostname that reported the VPG. |
| **Status** | `[string]` | Current health status of the VPG (e.g., MeetingSLA). |

## Internal Logic State

- **ZVMList**: `[string[]]` loaded from `E:\source\zvmservers.txt` or supplied via parameter.
- **VPGSearchList**: `[string[]]` supplied via `-VpgName`.
- **ZertoSession**: Cached session from `ZertoZVM.APIWrapper`.
