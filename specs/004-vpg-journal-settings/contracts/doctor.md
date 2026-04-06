# Doctor Contract: Get VPG Journal Settings

**Phase 1 Output**

## Output Format (headerless CSV)

The following fields will be output to `stdout` when the `-Doctor` switch is active.

| Column | Data Type | Example |
|--------|-----------|---------|
| 1      | `[string]`| `VPG_Production_SQL` |
| 2      | `[string]`| `vpg-86b208eb-21be-4161-9f93-c2d3a371879b` |
| 3      | `[string]`| `ProtectedSite_A` |

**Separator**: Comma (`,`)  
**Quoting**: Optional (none preferred for raw consumption)  
**Header**: None  

## Sample

```csv
VPG_Production_SQL,vpg-86b208eb-21be-4161-9f93-c2d3a371879b,ProtectedSite_A
VPG_Staging_Web,vpg-12c45d67-89ef-01ab-23cd-ef4567890abc,ProtectedSite_B
```
