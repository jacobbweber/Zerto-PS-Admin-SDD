function Get-ZertoPubliccloudsecuritygroup {
    <#
    .SYNOPSIS
        Get the list of security groups at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/publiccloud/securityGroups
        OperationId: getPublicCloudSecurityGroupAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/publiccloud/securityGroups" -Method 'Get'  
    }
}
