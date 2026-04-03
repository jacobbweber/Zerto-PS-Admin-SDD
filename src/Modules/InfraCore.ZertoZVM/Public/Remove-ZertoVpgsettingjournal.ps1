function Remove-ZertoVpgsettingjournal {
    <#
    .SYNOPSIS
        Delete VPG Journal settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/journal
        OperationId: removeVpgSettingJournal
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/journal" -Method 'Delete'  
    }
}
