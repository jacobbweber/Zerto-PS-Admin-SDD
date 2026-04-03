function Get-ZertoAlert {
    <#
    .SYNOPSIS
        Retrieves alerts from the Zerto ZVM.

    .DESCRIPTION
        Returns all active alerts or a specific alert by ID.
        Filtering by entity type or level is also supported.

    .PARAMETER AlertIdentifier
        The identifier of a specific alert to retrieve.

    .PARAMETER Level
        Filter by alert level: 'Warning' or 'Error'.

    .EXAMPLE
        Get-ZertoAlert

    .EXAMPLE
        Get-ZertoAlert -Level 'Error'

    .EXAMPLE
        Get-ZertoAlert -AlertIdentifier 'alert-abcd-1234'

    .OUTPUTS
        PSCustomObject or PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $AlertIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [ValidateSet('Warning', 'Error')]
        [string] $Level
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "alerts/$AlertIdentifier"
        }
        else {
            $query = @{}
            if ($Level) { $query.level = $Level }
            Invoke-ZertoRequest -Endpoint 'alerts' -QueryParameters $query
        }
    }
}

