function Get-ZertoLocalSite {
    <#
    .SYNOPSIS
        Retrieves information about the local Zerto site.

    .DESCRIPTION
        Returns details about the ZVM's local site, including the site identifier,
        name, ZVM version, and virtual infrastructure type.

    .EXAMPLE
        Get-ZertoLocalSite

    .OUTPUTS
        PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Invoke-ZertoRequest -Endpoint 'localsite'
}
