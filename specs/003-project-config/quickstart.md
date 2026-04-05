# Quickstart

## Loading the Configuration
Within any controller script's `Begin{}` pipeline block, use the initialization function to load configuration into the global scope:

```powershell
$Config = Initialize-ProjectConfig -ConfigPath ".\config.json"
```

## Validating Pre-Flight Checks
Immediately following the config load, ensure all dynamic environmental prerequisites (like root logging paths) validate securely:

```powershell
$isHealthy = Test-ProjectConfig -Config $Config
if (-not $isHealthy) {
  throw "Pre-flight environment misconfiguration."
}
```
