function Set-ZertoLocalsiteloginbanner {
    <#
    .SYNOPSIS
        Set the login banner settings of the current site.

This API will be deprecated starting Zerto 10.0_U6. Use the following new API for Site Setting configuration: /management/api/settings/v1/settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/localsite/settings/loginBanner
        OperationId: editLocalSiteLoginBanner
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'localsite/settings/loginBanner' -Method 'Put'  -Body $Body
    }
}
