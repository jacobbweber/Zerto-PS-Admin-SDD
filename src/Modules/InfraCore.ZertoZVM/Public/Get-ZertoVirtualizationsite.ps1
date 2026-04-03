function Get-ZertoVirtualizationsite {
    <#
    .SYNOPSIS
        Get a list of virtual sites connected to this site and all peer sites. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites
        OperationId: getVirtualizationSiteAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'virtualizationsites' -Method 'Get'  
    }
}

