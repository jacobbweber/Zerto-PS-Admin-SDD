function Start-ZertoClustervrasupgrade {
    <#
    .SYNOPSIS
        Upgrade VRA on cluster. Returns TaskIdentifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vras/clusters/{clusterIdentifier}
        OperationId: startClusterVrasUpgrade
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Clusteridentifier,

        [Parameter()]
        [string] $Vaioallowmaintenancemode,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {
    $query = @{}
        if ($Vaioallowmaintenancemode) { $query['vaioAllowMaintenanceMode'] = $Vaioallowmaintenancemode }

        Invoke-ZertoRequest -Endpoint "vras/clusters/$Clusteridentifier" -Method 'Put' -QueryParameters $query -Body $Body
    }
}
