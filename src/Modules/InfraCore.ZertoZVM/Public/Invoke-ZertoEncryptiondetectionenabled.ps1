function Invoke-ZertoEncryptiondetectionenabled {
    <#
    .SYNOPSIS
        Set the state of the encryption detection (enabled/disabled).

This API will be deprecated starting Zerto 10.0_U6. Use the following new API for Site Setting configuration: /management/api/settings/v1/settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/encryptionDetection/state
        OperationId: encryptionDetectionEnabled
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/state' -Method 'Post'  -Body $Body
    }
}
