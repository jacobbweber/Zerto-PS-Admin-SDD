function Get-ZertoVra {
    <#
    .SYNOPSIS
        Get information about all VRAs. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vras
        OperationId: getVraAll
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Vraname,

        [Parameter()]
        [string] $Status,

        [Parameter()]
        [string] $Vraversion,

        [Parameter()]
        [string] $Hostversion,

        [Parameter()]
        [string] $Ipaddress,

        [Parameter()]
        [string] $Vragroup,

        [Parameter()]
        [string] $Datastorename,

        [Parameter()]
        [string] $Datastoreclustername,

        [Parameter()]
        [string] $Networkname,

        [Parameter()]
        [string] $Vraipconfigurationtypeapi
    )

    process {
    $query = @{}
        if ($Vraname) { $query['vraName'] = $Vraname }
        if ($Status) { $query['status'] = $Status }
        if ($Vraversion) { $query['vraVersion'] = $Vraversion }
        if ($Hostversion) { $query['hostVersion'] = $Hostversion }
        if ($Ipaddress) { $query['ipAddress'] = $Ipaddress }
        if ($Vragroup) { $query['vraGroup'] = $Vragroup }
        if ($Datastorename) { $query['datastoreName'] = $Datastorename }
        if ($Datastoreclustername) { $query['datastoreClusterName'] = $Datastoreclustername }
        if ($Networkname) { $query['networkName'] = $Networkname }
        if ($Vraipconfigurationtypeapi) { $query['vraIpConfigurationTypeApi'] = $Vraipconfigurationtypeapi }

        Invoke-ZertoRequest -Endpoint 'vras' -Method 'Get' -QueryParameters $query 
    }
}
