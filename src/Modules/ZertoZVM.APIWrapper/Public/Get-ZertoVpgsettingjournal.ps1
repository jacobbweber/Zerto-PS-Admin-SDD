function Get-ZertoVpgsettingjournal {
    <#
    .SYNOPSIS
        Get VPG Journal settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/journal
        OperationId: getVpgSettingJournal
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/journal" -Method 'Get'  
    }
}
