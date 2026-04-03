function Get-ZertoVpgReport {
    param(
        [Parameter(Mandatory)] [string]$VpgId
    )
    process {
        # 1. Create the temporary settings object (Clone)
        $Body = @{ vpgIdentifier = $VpgId }
        $SettingsId = Invoke-ZertoRequest -Method Post -Endpoint "/vpgSettings/copyVpgSettings" -Body $Body
        
        try {
            # 2. Gather data from multiple endpoints
            $Journal = Invoke-ZertoRequest -Method Get -Endpoint "/vpgSettings/$SettingsId/journal"
            $Scratch = Invoke-ZertoRequest -Method Get -Endpoint "/vpgSettings/$SettingsId/scratch"
            $VMs = Invoke-ZertoRequest -Method Get -Endpoint "/vpgSettings/$SettingsId/vms"
            
            # 3. Create a combined custom object for your report
            [PSCustomObject]@{
                VpgId          = $VpgId
                JournalHistory = $Journal.limitation
                ScratchConfig  = $Scratch
                ProtectedVMs   = $VMs.vmIdentifier
            }
        }
        finally {
            # 4. Always delete the settings object to free ZVM memory
            Invoke-ZertoRequest -Method Delete -Endpoint "/vpgSettings/$SettingsId"
        }
    }
}