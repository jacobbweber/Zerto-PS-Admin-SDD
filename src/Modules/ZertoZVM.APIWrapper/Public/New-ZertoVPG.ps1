function New-ZertoVPG {
    <#
    .SYNOPSIS
        Creates a new Virtual Protection Group (VPG) on the Zerto ZVM.

    .DESCRIPTION
        Accepts a VPG settings object and submits it to the API. Returns the task
        identifier for the async creation operation.

    .PARAMETER VpgSettings
        Hashtable or PSCustomObject representing the full VPG settings body.
        Refer to Zerto API documentation for the required schema.

    .EXAMPLE
        $settings = @{
            Vpg          = @{ Name = 'ProdVPG'; RpoInSeconds = 300 }
            RecoverySite = @{ Identifier = 'site-id' }
        }
        New-ZertoVPG -VpgSettings $settings

    .OUTPUTS
        PSCustomObject — contains the TaskId for the async VPG creation task.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [object] $VpgSettings
    )

    if ($PSCmdlet.ShouldProcess('Zerto ZVM', "Create VPG '$($VpgSettings.Vpg.Name)'")) {
        Invoke-ZertoRequest -Endpoint 'vpgs' -Method 'Post' -Body $VpgSettings
    }
}
