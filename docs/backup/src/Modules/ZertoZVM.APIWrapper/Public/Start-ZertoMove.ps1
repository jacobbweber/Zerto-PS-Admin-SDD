function Start-ZertoMove {
    <#
    .SYNOPSIS
        Starts a Move operation for a VPG.

    .DESCRIPTION
        Moves protected VMs from the source site to the recovery site. The move
        operation syncs changes, powers down source VMs, performs a final sync,
        then powers on at the recovery site.

    .PARAMETER VpgIdentifier
        The identifier of the VPG to move.

    .PARAMETER VmIdentifiers
        Subset of VMs to include. Defaults to all VMs in the VPG.

    .EXAMPLE
        Start-ZertoMove -VpgIdentifier 'abcd-1234'

    .OUTPUTS
        PSCustomObject — contains the TaskId.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier,

        [Parameter()]
        [string[]] $VmIdentifiers
    )

    process {
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Start Zerto Move')) {
            $body = @{}
            if ($VmIdentifiers) { $body.VmIdentifiers = $VmIdentifiers }
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier/move" -Method 'Post' -Body $body
        }
    }
}

