function Stop-ZertoFailoverTest {
    <#
    .SYNOPSIS
        Stops a failover test that is currently in progress.

    .DESCRIPTION
        Shuts down the test VMs at the recovery site and marks the test as complete.

    .PARAMETER VpgIdentifier
        The identifier of the VPG whose failover test to stop.

    .EXAMPLE
        Stop-ZertoFailoverTest -VpgIdentifier 'abcd-1234'

    .OUTPUTS
        PSCustomObject — contains the TaskId.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier
    )

    process {
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Stop Zerto Failover Test')) {
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier/failoverteststop" -Method 'Post'
        }
    }
}

