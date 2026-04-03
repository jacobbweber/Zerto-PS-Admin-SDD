function Get-ZertoZorg {
    <#
    .SYNOPSIS
        Get the list of all the ZORGs defined in the Zerto Cloud Manager for this site. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/zorgs
        OperationId: getZorgAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'zorgs' -Method 'Get'  
    }
}

