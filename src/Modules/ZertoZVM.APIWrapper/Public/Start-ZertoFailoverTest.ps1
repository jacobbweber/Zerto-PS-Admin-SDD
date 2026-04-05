function Start-ZertoFailoverTest {
    <#
    .SYNOPSIS
        Starts a failover test for a VPG.

    .DESCRIPTION
        Initiates a non-disruptive failover test. The production VMs continue
        running at the source site; test VMs spin up at the recovery site.

    .PARAMETER VpgIdentifier
        The identifier of the VPG to test.

    .PARAMETER CheckpointIdentifier
        The checkpoint identifier to recover to. Defaults to latest.

    .PARAMETER VmIdentifiers
        Subset of VMs to include in the test. Defaults to all.

    .EXAMPLE
        Start-ZertoFailoverTest -VpgIdentifier 'abcd-1234'

    .OUTPUTS
        PSCustomObject — contains the TaskId.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier,

        [Parameter()]
        [string] $CheckpointIdentifier,

        [Parameter()]
        [string[]] $VmIdentifiers
    )

    process {
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Start Zerto Failover Test')) {
            $body = @{}
            if ($CheckpointIdentifier) { $body.CheckpointIdentifier = $CheckpointIdentifier }
            if ($VmIdentifiers) { $body.VmIdentifiers = $VmIdentifiers }

            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier/failovertest" -Method 'Post' -Body $body
        }
    }
}

