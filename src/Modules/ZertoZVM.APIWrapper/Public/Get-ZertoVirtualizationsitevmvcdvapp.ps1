function Get-ZertoVirtualizationsitevmvcdvapp {
    <#
    .SYNOPSIS
        Get the list of unprotected VCD vApps at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/vcdvapps
        OperationId: getVirtualizationSiteVmVcdVappAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/vcdvapps" -Method 'Get'  
    }
}
