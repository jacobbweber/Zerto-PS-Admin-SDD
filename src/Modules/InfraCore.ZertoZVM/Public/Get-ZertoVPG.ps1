function Get-ZertoVPG {
    <#
    .SYNOPSIS
        Retrieves Virtual Protection Groups (VPGs) from the Zerto ZVM.

    .DESCRIPTION
        Returns all VPGs or a specific VPG by ID. Supports optional filtering
        by name and status via query parameters.

    .PARAMETER VpgIdentifier
        The identifier of a specific VPG. If omitted, all VPGs are returned.

    .PARAMETER Name
        Filter results to VPGs whose name matches this string.

    .PARAMETER Status
        Filter by VPG status (e.g. 'MeetingSLA', 'NotMeetingSLA', 'Empty').

    .EXAMPLE
        Get-ZertoVPG

    .EXAMPLE
        Get-ZertoVPG -Name 'ProdVPG'

    .EXAMPLE
        Get-ZertoVPG -VpgIdentifier 'abcd-1234-...'

    .OUTPUTS
        PSCustomObject or PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $VpgIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [string] $Name,

        [Parameter(ParameterSetName = 'All')]
        [ValidateSet('Initializing', 'MeetingSLA', 'NotMeetingSLA', 'RpoNotMeetingSLA',
            'HistoryNotMeetingSLA', 'FailingOver', 'Moving', 'Deleting', 'Recovered',
            'Empty', 'NeedsConfiguration', 'Error', 'Upgrading')]
        [string] $Status
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "vpgs/$VpgIdentifier"
        }
        else {
            $query = @{}
            if ($Name) { $query.name = $Name }
            if ($Status) { $query.status = $Status }

            Invoke-ZertoRequest -Endpoint 'vpgs' -QueryParameters $query
        }
    }
}

