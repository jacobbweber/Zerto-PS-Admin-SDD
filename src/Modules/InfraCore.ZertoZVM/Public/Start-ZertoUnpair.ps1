function Start-ZertoUnpair {
    <#
    .SYNOPSIS
        Unpair a peer site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/peersites/{siteIdentifier}
        OperationId: startUnpair
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "peersites/$Siteidentifier" -Method 'Delete'  
    }
}
