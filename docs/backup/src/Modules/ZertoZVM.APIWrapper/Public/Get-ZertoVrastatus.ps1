function Get-ZertoVrastatus {
    <#
    .SYNOPSIS
        Get the list of values for VRA status (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vras/statuses
        OperationId: getVraStatusAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vras/statuses' -Method 'Get'  
    }
}

