function Get-ZertoVpgstatus {
    <#
    .SYNOPSIS
        Get the list of values for VPG status. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/statuses
        OperationId: getVpgStatusAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/statuses' -Method 'Get'  
    }
}

