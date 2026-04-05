function Set-ZertoVPG {
    <#
    .SYNOPSIS
        Updates the settings of an existing Virtual Protection Group (VPG).

    .DESCRIPTION
        Sends a PUT request to update the VPG identified by VpgId with the
        provided settings object. Returns the async task identifier.

    .PARAMETER VpgIdentifier
        The identifier of the VPG to update.

    .PARAMETER VpgSettings
        Hashtable or PSCustomObject with the updated VPG settings body.

    .EXAMPLE
        Set-ZertoVPG -VpgIdentifier 'abcd-1234' -VpgSettings @{ Vpg = @{ RpoInSeconds = 600 } }

    .OUTPUTS
        PSCustomObject — contains the TaskId for the async update task.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier,

        [Parameter(Mandatory)]
        [object] $VpgSettings
    )

    process {
        if ($PSCmdlet.ShouldProcess($VpgIdentifier, 'Update Zerto VPG')) {
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier" -Method 'Put' -Body $VpgSettings
        }
    }
}


