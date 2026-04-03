function Get-ZertoPairingtoken {
    <#
    .SYNOPSIS
        Generate a token for pairing (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/peersites/generatetoken
        OperationId: getPairingToken
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'peersites/generatetoken' -Method 'Post'  -Body $Body
    }
}
