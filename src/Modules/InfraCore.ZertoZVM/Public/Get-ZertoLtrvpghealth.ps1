function Get-ZertoLtrvpghealth {
    <#
    .SYNOPSIS
        Get a list of Extended Journal Copy VPGs (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/health/vpgs
        OperationId: getLtrVpgHealthAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'ltr/health/vpgs' -Method 'Get'  
    }
}

