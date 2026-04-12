function Get-ZertoResourcereport {
    <#
    .SYNOPSIS
        Get VM resource reports. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/reports/resources
        OperationId: getResourceReportAll
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Starttime,

        [Parameter()]
        [string] $Endtime,

        [Parameter()]
        [int] $Pagenumber,

        [Parameter()]
        [int] $Pagesize,

        [Parameter()]
        [string] $Zorgname,

        [Parameter()]
        [string] $Vpgname,

        [Parameter()]
        [string] $Vmname,

        [Parameter()]
        [string] $Protectedsitename,

        [Parameter()]
        [string] $Protectedclustername,

        [Parameter()]
        [string] $Protectedhostname,

        [Parameter()]
        [string] $Protectedorgvdc,

        [Parameter()]
        [string] $Protectedvcdorg,

        [Parameter()]
        [string] $Recoverysitename,

        [Parameter()]
        [string] $Recoveryclustername,

        [Parameter()]
        [string] $Recoveryhostname,

        [Parameter()]
        [string] $Recoveryorgvdc,

        [Parameter()]
        [string] $Recoveryvcdorg
    )

    process {
    $query = @{}
        if ($Starttime) { $query['startTime'] = $Starttime }
        if ($Endtime) { $query['endTime'] = $Endtime }
        if ($Pagenumber) { $query['pageNumber'] = $Pagenumber }
        if ($Pagesize) { $query['pageSize'] = $Pagesize }
        if ($Zorgname) { $query['zorgName'] = $Zorgname }
        if ($Vpgname) { $query['vpgName'] = $Vpgname }
        if ($Vmname) { $query['vmName'] = $Vmname }
        if ($Protectedsitename) { $query['protectedSiteName'] = $Protectedsitename }
        if ($Protectedclustername) { $query['protectedClusterName'] = $Protectedclustername }
        if ($Protectedhostname) { $query['protectedHostName'] = $Protectedhostname }
        if ($Protectedorgvdc) { $query['protectedOrgVdc'] = $Protectedorgvdc }
        if ($Protectedvcdorg) { $query['protectedVcdOrg'] = $Protectedvcdorg }
        if ($Recoverysitename) { $query['recoverySiteName'] = $Recoverysitename }
        if ($Recoveryclustername) { $query['recoveryClusterName'] = $Recoveryclustername }
        if ($Recoveryhostname) { $query['recoveryHostName'] = $Recoveryhostname }
        if ($Recoveryorgvdc) { $query['recoveryOrgVdc'] = $Recoveryorgvdc }
        if ($Recoveryvcdorg) { $query['recoveryVcdOrg'] = $Recoveryvcdorg }

        Invoke-ZertoRequest -Endpoint 'reports/resources' -Method 'Get' -QueryParameters $query 
    }
}
