function Get-ZertoNetwork {
    <#
    .SYNOPSIS
        Retrieves networks available on a Zerto virtualization site.

    .DESCRIPTION
        Returns the list of networks (port groups) visible to the ZVM on the
        specified virtualization site. Typically used when configuring VPG network mappings.

    .PARAMETER SiteIdentifier
        The identifier of the virtualization site whose networks to retrieve.
        Use Get-ZertoPeerSite or Get-ZertoLocalSite to obtain site identifiers.

    .EXAMPLE
        $localSiteId = (Get-ZertoLocalSite).SiteIdentifier
        Get-ZertoNetwork -SiteIdentifier $localSiteId

    .OUTPUTS
        PSCustomObject[]
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $SiteIdentifier
    )

    Invoke-ZertoRequest -Endpoint "virtualizationsites/$SiteIdentifier/networks"
}

