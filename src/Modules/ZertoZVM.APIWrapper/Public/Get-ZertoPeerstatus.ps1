function Get-ZertoPeerstatus {
    <#
    .SYNOPSIS
        Get the list of acceptable values for site pairing status (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/peersites/pairingstatuses
        OperationId: getPeerStatusAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'peersites/pairingstatuses' -Method 'Get'  
    }
}

