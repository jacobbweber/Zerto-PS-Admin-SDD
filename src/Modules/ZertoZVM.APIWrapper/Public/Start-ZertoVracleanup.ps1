function Start-ZertoVracleanup {
    <#
    .SYNOPSIS
        UnInstall all VRAs from all clusters. Returns list of TaskIdentifiers for each cluster (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vras/cleanup
        OperationId: startVraCleanup
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Vaioallowmaintenancemode
    )

    process {
    $query = @{}
        if ($Vaioallowmaintenancemode) { $query['vaioAllowMaintenanceMode'] = $Vaioallowmaintenancemode }

        Invoke-ZertoRequest -Endpoint 'vras/cleanup' -Method 'Delete' -QueryParameters $query 
    }
}
