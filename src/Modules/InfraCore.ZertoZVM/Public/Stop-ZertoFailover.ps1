function Stop-ZertoFailover {
    <#
    .SYNOPSIS
        Stops (commits or rolls back) a live failover in progress.

    .DESCRIPTION
        Commits or rolls back a failover that was previously initiated with
        Start-ZertoFailover. Use -Rollback to revert; default is commit.

    .PARAMETER VpgIdentifier
        The identifier of the VPG whose failover to stop.

    .PARAMETER Rollback
        If specified, rolls back the failover instead of committing it.

    .EXAMPLE
        Stop-ZertoFailover -VpgIdentifier 'abcd-1234'

    .EXAMPLE
        Stop-ZertoFailover -VpgIdentifier 'abcd-1234' -Rollback

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
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Stop Zerto Failover')) {
            $body = @{ IsRollback = $Rollback.IsPresent }
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier/failoverstop" -Method 'Post' -Body $body
        }
    }
}

