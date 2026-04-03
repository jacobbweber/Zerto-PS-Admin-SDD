function Get-ZertoLocalsiteloginbanner {
    <#
    .SYNOPSIS
        Get the login banner settings of the current site.

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/localsite/settings/loginBanner
        OperationId: getLocalSiteLoginBanner
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'localsite/settings/loginBanner' -Method 'Get'  
    }
}

