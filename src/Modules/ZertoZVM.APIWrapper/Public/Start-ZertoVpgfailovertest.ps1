function Start-ZertoVpgfailovertest {
    <#
    .SYNOPSIS
        Start a failover test using a specific checkpoint or the latest checkpoint if one is not . (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/FailoverTest
        OperationId: startVpgFailoverTest
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/FailoverTest" -Method 'Post'  -Body $Body
    }
}
