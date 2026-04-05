function Get-ZertoLicense {
    <#
    .SYNOPSIS
        Get license details of the ZVM (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/license
        OperationId: getLicense
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'license' -Method 'Get'  
    }
}

