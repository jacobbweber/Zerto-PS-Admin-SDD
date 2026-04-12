function Get-ZertoVpgsubstatus {
    <#
    .SYNOPSIS
        Get the list of values for VPG sub status. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/substatuses
        OperationId: getVpgSubStatusAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/substatuses' -Method 'Get'  
    }
}

