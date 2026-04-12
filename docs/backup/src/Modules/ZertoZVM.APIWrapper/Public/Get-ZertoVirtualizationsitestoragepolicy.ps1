function Get-ZertoVirtualizationsitestoragepolicy {
    <#
    .SYNOPSIS
        Get the list of storage policies at the site (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/virtualizationsites/{siteIdentifier}/orgvdcs/{orgVdcIdentifier}/storagepolicies
        OperationId: getVirtualizationSiteStoragePolicyAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Siteidentifier,

        [Parameter(Mandatory)]
        [string] $Orgvdcidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "virtualizationsites/$Siteidentifier/orgvdcs/$Orgvdcidentifier/storagepolicies" -Method 'Get'  
    }
}
