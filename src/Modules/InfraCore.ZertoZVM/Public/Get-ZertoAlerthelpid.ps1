function Get-ZertoAlerthelpid {
    <#
    .SYNOPSIS
        Get a list of all available alert help identifiers. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/alerts/helpidentifiers
        OperationId: getAlertHelpIdAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'alerts/helpidentifiers' -Method 'Get'  
    }
}

