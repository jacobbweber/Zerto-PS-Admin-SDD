function Get-ZertoVirtualizationsitevm {
    <#
    .SYNOPSIS
        Get the list of eligible VMs for protection that are not currently protected at the site. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/vms
        OperationId: getVirtualizationSiteVmAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/vms" -Method 'Get'  
    }
}
