function Start-ZertoSetvraclustersettings {
    <#
    .SYNOPSIS
        Store VRA install settings for a cluster. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras/clusters/{clusterIdentifier}/settings
        OperationId: startSetVraClusterSettings
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Clusteridentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/clusters/$Clusteridentifier/settings" -Method 'Post'  -Body $Body
    }
}
