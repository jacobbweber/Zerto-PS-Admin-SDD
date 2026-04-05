function Get-ZertoLocalsitepairingstatus {
    <#
    .SYNOPSIS
        Get the list of acceptable values for site pairing status (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/localsite/pairingstatuses
        OperationId: getLocalSitePairingStatusAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'localsite/pairingstatuses' -Method 'Get'  
    }
}

