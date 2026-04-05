function Stop-ZertoVpgfailovertest {
    <#
    .SYNOPSIS
        Stops a failover test. Specify if test was successful and provide a summary. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgs/{vpgIdentifier}/FailoverTestStop
        OperationId: stopVpgFailoverTest
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/FailoverTestStop" -Method 'Post'  -Body $Body
    }
}
