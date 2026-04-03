function Get-ZertoVpgsetting {
    <#
    .SYNOPSIS
        Get all VPG settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings
        OperationId: getVpgSettingAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgSettings' -Method 'Get'  
    }
}

