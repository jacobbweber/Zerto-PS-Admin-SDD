function Get-ZertoDatastore {
    <#
    .SYNOPSIS
        Retrieves datastores visible to the Zerto ZVM.

    .DESCRIPTION
        Returns all datastores registered in the ZVM's virtual infrastructure.
        Optionally filter by site identifier.

    .PARAMETER SiteIdentifier
        If provided, limits results to datastores on the specified virtualization site.

    .EXAMPLE
        Get-ZertoDatastore

    .OUTPUTS
        PSCustomObject or PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $DatastoreIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [string] $SiteIdentifier
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "datastores/$DatastoreIdentifier"
        }
        else {
            $query = @{}
            if ($SiteIdentifier) { $query.siteIdentifier = $SiteIdentifier }
            Invoke-ZertoRequest -Endpoint 'datastores' -QueryParameters $query
        }
    }




}
