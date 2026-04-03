function Stop-ZertoTask {
    <#
    .SYNOPSIS
        Cancels an in-progress Zerto task.

    .DESCRIPTION
        Sends a DELETE request to cancel the specified task. Only tasks that are
        in a cancellable state can be stopped.

    .PARAMETER TaskIdentifier
        The identifier of the task to cancel.

    .EXAMPLE
        Stop-ZertoTask -TaskIdentifier 'task-abcd-1234'

    .EXAMPLE
        Get-ZertoTask -Type 'InitialSync' | Stop-ZertoTask

    .OUTPUTS
        None
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $TaskIdentifier
    )

    process {
        if ($PSCmdlet.ShouldProcess($TaskIdentifier, 'Cancel Zerto Task')) {
            Invoke-ZertoRequest -Endpoint "tasks/$TaskIdentifier" -Method 'Delete'
        }
    }
}

