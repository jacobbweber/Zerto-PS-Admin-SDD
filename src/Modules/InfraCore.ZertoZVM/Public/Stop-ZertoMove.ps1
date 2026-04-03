function Stop-ZertoMove {
    <#
    .SYNOPSIS
        Stops (commits or rolls back) a Move operation in progress.

    .PARAMETER VpgIdentifier
        The identifier of the VPG whose move to stop.

    .PARAMETER Rollback
        If specified, rolls back the move instead of committing it.

    .EXAMPLE
        Stop-ZertoMove -VpgIdentifier 'abcd-1234'

    .EXAMPLE
        Stop-ZertoMove -VpgIdentifier 'abcd-1234' -Rollback

    .OUTPUTS
        PSCustomObject — contains the TaskId.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier,

        [Parameter()]
        [switch] $Rollback
    )

    process {
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Stop Zerto Move')) {
            $body = @{ IsRollback = $Rollback.IsPresent }
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier/movestop" -Method 'Post' -Body $body
        }
    }
}

