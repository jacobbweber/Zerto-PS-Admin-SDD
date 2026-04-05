function Get-ZertoVraclustersettings {
    <#
    .SYNOPSIS
        Get VRA cluster install settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vras/clusters/{clusterIdentifier}/settings
        OperationId: getVraClusterSettings
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Clusteridentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/clusters/$Clusteridentifier/settings" -Method 'Get'  
    }
}
