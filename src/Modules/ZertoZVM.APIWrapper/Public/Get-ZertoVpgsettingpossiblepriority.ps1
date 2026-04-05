function Get-ZertoVpgsettingpossiblepriority {
    <#
    .SYNOPSIS
        Get values for Priority. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/priority
        OperationId: getVpgSettingPossiblePriorityAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/priority" -Method 'Get'  
    }
}
