function Start-ZertoClustervrasuninstall {
    <#
    .SYNOPSIS
        UnInstall VRAs from cluster. Returns TaskIdentifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vras/clusters/{clusterIdentifier}
        OperationId: startClusterVrasUninstall
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Clusteridentifier,

        [Parameter()]
        [string] $Vaioallowmaintenancemode
    )

    process {
    $query = @{}
        if ($Vaioallowmaintenancemode) { $query['vaioAllowMaintenanceMode'] = $Vaioallowmaintenancemode }

        Invoke-ZertoRequest -Endpoint "vras/clusters/$Clusteridentifier" -Method 'Delete' -QueryParameters $query 
    }
}
