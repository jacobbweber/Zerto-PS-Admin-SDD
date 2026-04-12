function Start-ZertoVpgfailover {
    <#
    .SYNOPSIS
        Starts a Failover of a VPG using a checkpoint. Returns the TaskIdentifier of the operation, which can be used to monitor the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/Failover
        OperationId: startVpgFailover
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/Failover" -Method 'Post'  -Body $Body
    }
}
