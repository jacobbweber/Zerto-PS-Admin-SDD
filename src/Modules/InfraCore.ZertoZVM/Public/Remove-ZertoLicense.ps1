function Remove-ZertoLicense {
    <#
    .SYNOPSIS
        Delete the license from the ZVM (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/license
        OperationId: removeLicense
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'license' -Method 'Delete'  
    }
}

