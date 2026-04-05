function Get-ZertoZsspsession {
    <#
    .SYNOPSIS
        Get details of all ZSSP sessions (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/zsspsessions
        OperationId: getZsspSessionAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'zsspsessions' -Method 'Get'  
    }
}

