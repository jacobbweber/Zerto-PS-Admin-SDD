function Set-ZertoLicense {
    <#
    .SYNOPSIS
        Add a new license or update an existing one. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/license
        OperationId: setLicense
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'license' -Method 'Put'  -Body $Body
    }
}
