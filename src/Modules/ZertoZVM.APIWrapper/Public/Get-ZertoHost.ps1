function Get-ZertoHost {
    <#
    .SYNOPSIS
        Retrieves hosts (ESXi / Hyper-V) on a Zerto virtualization site.

    .DESCRIPTION
        Returns the list of compute hosts visible to the ZVM on the specified
        virtualization site. Useful when planning resource placement for recovered VMs.

    .PARAMETER SiteIdentifier
        The identifier of the virtualization site whose hosts to retrieve.

    .EXAMPLE
        $localSiteId = (Get-ZertoLocalSite).SiteIdentifier
        Get-ZertoHost -SiteIdentifier $localSiteId

    .OUTPUTS
        PSCustomObject[]
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $SiteIdentifier
    )

    Invoke-ZertoRequest -Endpoint "virtualizationsites/$SiteIdentifier/hosts"
}

