function Get-ZertoVpgentitytype {
    <#
    .SYNOPSIS
        Get the list of values for VPG entity. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/entitytypes
        OperationId: getVpgEntityTypeAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/entitytypes' -Method 'Get'  
    }
}

