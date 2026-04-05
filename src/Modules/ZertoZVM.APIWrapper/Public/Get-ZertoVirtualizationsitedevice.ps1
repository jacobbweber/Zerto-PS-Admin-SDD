function Get-ZertoVirtualizationsitedevice {
    <#
    .SYNOPSIS
        Get a list of all avaialable devices for all available hosts in the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/devices
        OperationId: getVirtualizationSiteDeviceAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier,

        [Parameter()]
        [string] $Hostidentifier,

        [Parameter()]
        [string] $Devicename
    )

    process {
    $query = @{}
        if ($Hostidentifier) { $query['hostIdentifier'] = $Hostidentifier }
        if ($Devicename) { $query['deviceName'] = $Devicename }

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/devices" -Method 'Get' -QueryParameters $query 
    }
}
