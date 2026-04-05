function Get-ZertoPeer {
    <#
    .SYNOPSIS
        Get a list of all peer sites (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/peersites
        OperationId: getPeerAll
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Peername,

        [Parameter()]
        [string] $Pairingstatus,

        [Parameter()]
        [string] $Location,

        [Parameter()]
        [string] $Hostname,

        [Parameter()]
        [int] $Port
    )

    process {
    $query = @{}
        if ($Peername) { $query['peerName'] = $Peername }
        if ($Pairingstatus) { $query['pairingStatus'] = $Pairingstatus }
        if ($Location) { $query['location'] = $Location }
        if ($Hostname) { $query['hostName'] = $Hostname }
        if ($Port) { $query['port'] = $Port }

        Invoke-ZertoRequest -Endpoint 'peersites' -Method 'Get' -QueryParameters $query 
    }
}
