function Start-ZertoVpgsettingcommit {
    <#
    .SYNOPSIS
        Commit and deploy the VPG settings. Returns the command task identifier. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/{vpgSettingsIdentifier}/commit
        OperationId: startVpgSettingCommit
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/commit" -Method 'Post'  -Body $Body
    }
}
