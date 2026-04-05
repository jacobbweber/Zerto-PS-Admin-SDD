function Get-ZertoPeerSite {
    <#
    .SYNOPSIS
        Retrieves peer (remote) Zerto sites paired with this ZVM.

    .DESCRIPTION
        Returns all paired peer sites, or a specific site by identifier.

    .PARAMETER SiteIdentifier
        The identifier of a specific peer site to retrieve.

    .EXAMPLE
        Get-ZertoPeerSite

    .EXAMPLE
        Get-ZertoPeerSite -SiteIdentifier 'site-abcd-1234'

    .OUTPUTS
        PSCustomObject or PSCustomObject[]
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $SiteIdentifier
    )

    process {
        $endpoint = if ($SiteIdentifier) { "peersites/$SiteIdentifier" } else { 'peersites' }
        Invoke-ZertoRequest -Endpoint $endpoint
    }
}

