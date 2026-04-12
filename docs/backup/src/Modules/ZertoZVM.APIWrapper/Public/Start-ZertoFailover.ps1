function Start-ZertoFailover {
    <#
    .SYNOPSIS
        Initiates a live failover for one or more VPGs.

    .DESCRIPTION
        Triggers a Failover operation on the specified VPG. Optionally scoped to
        a specific checkpoint and subset of VMs.

    .PARAMETER VpgIdentifier
        The identifier of the VPG to fail over.

    .PARAMETER CheckpointIdentifier
        The checkpoint identifier to recover to. Defaults to the latest.

    .PARAMETER VmIdentifiers
        Array of VM identifiers to include. Defaults to all VMs in the VPG.

    .EXAMPLE
        Start-ZertoFailover -VpgIdentifier 'abcd-1234'

    .EXAMPLE
        Start-ZertoFailover -VpgIdentifier 'abcd-1234' -CheckpointIdentifier 'chk-5678'

    .OUTPUTS
        PSCustomObject — contains the TaskId for the async failover task.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
        Assert-ZertoSession

        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Start Zerto Live Failover')) {
            $body = @{}
            if ($CheckpointIdentifier) { $body.CheckpointIdentifier = $CheckpointIdentifier }
            if ($VmIdentifiers) { $body.VmIdentifiers = $VmIdentifiers }

            Invoke-ZertoRequest -Method 'POST' -UriPath "vpgs/$VpgIdentifier/failover" -Body $body
        }
    }
}

