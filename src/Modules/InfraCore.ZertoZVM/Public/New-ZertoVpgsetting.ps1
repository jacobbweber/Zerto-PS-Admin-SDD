function New-ZertoVpgsetting {
    <#
    .SYNOPSIS
        Create a new VPG settings object, returns the settings object identifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings
        OperationId: newVpgSetting
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Repopulatesettings,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {
    $query = @{}
        if ($Repopulatesettings) { $query['repopulateSettings'] = $Repopulatesettings }

        Invoke-ZertoRequest -Endpoint 'vpgSettings' -Method 'Post' -QueryParameters $query -Body $Body
    }
}
