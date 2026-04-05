function Clear-ZertoAlert {
    <#
    .SYNOPSIS
        Dismisses a Zerto alert.

    .DESCRIPTION
        Marks the specified alert as dismissed so it no longer appears in the
        active alert list. Supports pipeline input from Get-ZertoAlert.

    .PARAMETER AlertIdentifier
        The identifier of the alert to dismiss.

    .EXAMPLE
        Clear-ZertoAlert -AlertIdentifier 'alert-abcd-1234'

    .EXAMPLE
        Get-ZertoAlert -Level 'Warning' | Clear-ZertoAlert

    .OUTPUTS
        None
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $AlertIdentifier,
        
        [Parameter()]
        [object] $Body
    )

    process {
        if ($PSCmdlet.ShouldProcess($AlertIdentifier, 'Dismiss Zerto Alert')) {
            Invoke-ZertoRequest -Endpoint "alerts/$AlertIdentifier/dismiss" -Method 'Post' -Body $Body
        }
    }
}



