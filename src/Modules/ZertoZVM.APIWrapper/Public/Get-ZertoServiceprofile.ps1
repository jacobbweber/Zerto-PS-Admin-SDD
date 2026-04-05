function Get-ZertoServiceprofile {
    <#
    .SYNOPSIS
        Get the list of all service profiles for the site processing the API. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/serviceprofiles
        OperationId: getServiceProfileAll
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Siteidentifier
    )

    process {
    $query = @{}
        if ($Siteidentifier) { $query['siteIdentifier'] = $Siteidentifier }

        Invoke-ZertoRequest -Endpoint 'serviceprofiles' -Method 'Get' -QueryParameters $query 
    }
}
