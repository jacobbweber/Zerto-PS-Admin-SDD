function Get-ZertoVpgStorageReport {
    param([string]$VpgId)
    
    # 1. Create sandbox
    $SettingsId = Invoke-ZertoRequest -Method Post -Endpoint "/vpgSettings/copyVpgSettings" -Body @{ vpgIdentifier = $VpgId }
    
    try {
        # 2. Get VPG-level settings
        $VpgJournal = Invoke-ZertoRequest -Method Get -Endpoint "/vpgSettings/$SettingsId/journal"
        $VpgScratch = Invoke-ZertoRequest -Method Get -Endpoint "/vpgSettings/$SettingsId/scratch"
        
        # 3. Get VM-level settings
        $VMs = Invoke-ZertoRequest -Method Get -Endpoint "/vpgSettings/$SettingsId/vms"
        
        foreach ($vm in $VMs) {
            # Check if the VM has a specific Journal Hard Limit defined
            $hasJournalOverride = $null -ne $vm.journal.limitation.hardLimitInMB
    
            # Check if the VM has a specific Scratch Datastore defined
            $hasScratchOverride = $null -ne $vm.scratch.datastoreIdentifier

            [PSCustomObject]@{
                VpgId              = $VpgId
                VmName             = $vm.vmIdentifier 
                # Display the actual active limit (VM override if it exists, otherwise VPG default)
                ActiveJournalLimit = if ($hasJournalOverride) { $vm.journal.limitation.hardLimitInMB } else { $VpgJournal.limitation.hardLimitInMB }
                JournalOverride    = $hasJournalOverride
                # Display the actual active datastore
                ActiveScratchDS    = if ($hasScratchOverride) { $vm.scratch.datastoreIdentifier } else { $VpgScratch.datastoreIdentifier }
                ScratchOverride    = $hasScratchOverride
            }
        }
    }
    finally {
        # 4. Critical: Clean up session
        Invoke-ZertoRequest -Method Delete -Endpoint "/vpgSettings/$SettingsId"
    }
}