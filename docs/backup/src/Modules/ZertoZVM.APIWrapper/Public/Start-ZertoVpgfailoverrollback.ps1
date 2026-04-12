function Start-ZertoVpgfailoverrollback {
    <#
    .SYNOPSIS
        Rolls back the VPG after Failover. Returns the TaskIdentifier of the operation, which can be used to monitor the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/FailoverRollback
        OperationId: startVpgFailoverRollback
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/FailoverRollback" -Method 'Post'  -Body $Body
    }
}
