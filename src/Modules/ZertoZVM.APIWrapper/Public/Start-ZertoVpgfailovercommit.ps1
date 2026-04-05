function Start-ZertoVpgfailovercommit {
    <#
    .SYNOPSIS
        Commits the Failover of a VPG. Returns the TaskIdentifier of the operation, which can be used to monitor the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/FailoverCommit
        OperationId: startVpgFailoverCommit
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/FailoverCommit" -Method 'Post'  -Body $Body
    }
}
