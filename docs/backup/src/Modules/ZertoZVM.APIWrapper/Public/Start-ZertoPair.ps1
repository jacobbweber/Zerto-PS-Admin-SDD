function Start-ZertoPair {
    <#
    .SYNOPSIS
        Add a peer site (start pairing). (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/peersites
        OperationId: startPair
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'peersites' -Method 'Post'  -Body $Body
    }
}
