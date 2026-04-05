# Quickstart: ZertoZVM.Core

### Loading Environment Variables

Your controller script `Begin` block MUST load and validate the configuration schema automatically to function properly within the pipeline:

```powershell
Import-Module 'ZertoZVM.Core'

# Bootstrap configuration into the Global Context
Initialize-ProjectConfig -Path ".\config.json"

# Validate environmental integrity (folders, paths)
Test-ProjectConfig -Config $Global:Config
```

### Logging Output

Log entries safely split to audit vs debugging streams automatically:

```powershell
$logParams = @{
    Level          = 'Info'
    Message        = "Action successfully executed against VPG"
    LogPath        = $Config.base.logging.paths.logdir
    SyslogFileName = $Config.base.logging.paths.syslog
    DevLogFileName = $Config.base.logging.paths.devlog
}

Write-Log @logParams
```
