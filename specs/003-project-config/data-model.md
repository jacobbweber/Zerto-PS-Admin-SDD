# Data Model: Global Environment Configuration

## Config Object (`$Config`)

An in-memory PowerShell object instantiated during `Initialize-ProjectConfig` by parsing `config.json`.

### Schema Map

- `base.logging.paths.logdir` (String): Directory for active logs.
- `base.logging.paths.archive` (String): Directory for archived logs.
- `base.logging.paths.state` (String): Directory for telemetry JSON state cache files.
- `base.logging.paths.telemetry` (String): Directory for active telemetry data (per Constitution).
- `base.logging.filename.syslog` (String): String base name for syslog file.
- `base.logging.filename.devlog` (String): String base name for debug developer log file.
- `base.logging.filename.telemetry` (String): String base name for telemetry log (per Constitution).
- `base.logging.filename.csv` (String): String base name for generated CVS outputs (per Constitution).
- `base.telemetry.hostname` (String): Dynatrace/Reporting endpoint FQDN.
- `base.telemetry.username` (String): Telemetry Context Username.
- `base.telemetry.business_unit` (String): KPI department categorization tag.
- `base.auth.vmware_user` (String): Absolute Path to AES vault holding Zerto Service Account credentials.
- `base.auth.vmware_password` (String): Absolute Path to AES vault holding Zerto API password credentials.
- `base.email.smpt_server` (String): FQDN of the SMTP Relay server.
- `base.env.zvm_uri` (String): Base URI endpoint for target ZVM integration (e.g. `https://zvm:9669`).
