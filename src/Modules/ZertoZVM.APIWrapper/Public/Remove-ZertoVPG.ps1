function Remove-ZertoVPG {
    <#
    .SYNOPSIS
        Deletes a Virtual Protection Group (VPG) from the Zerto ZVM.

    .DESCRIPTION
        Sends a DELETE request for the specified VPG. Supports -WhatIf and -Confirm
        as a safeguard against accidental deletion.

    .PARAMETER VpgIdentifier
        The identifier of the VPG to delete.

    .PARAMETER KeepRecoveryVolumes
        If specified, retains the recovery volumes at the target site after deletion.

    .EXAMPLE
        Remove-ZertoVPG -VpgIdentifier 'abcd-1234' -Confirm

    .EXAMPLE
        Get-ZertoVPG -Name 'TestVPG' | Remove-ZertoVPG

    .OUTPUTS
        PSCustomObject — contains the TaskId for the async delete task.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier,

        [Parameter()]
        [switch] $KeepRecoveryVolumes
    )

    process {
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Delete Zerto VPG')) {
            $body = @{ keepRecoveryVolumes = $KeepRecoveryVolumes.IsPresent }
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier" -Method 'Delete' -Body $body
        }
    }
}


