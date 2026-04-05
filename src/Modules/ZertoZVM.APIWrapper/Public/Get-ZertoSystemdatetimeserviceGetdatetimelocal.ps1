function Get-ZertoSystemdatetimeserviceGetdatetimelocal {
    <#
    .SYNOPSIS
        Get current system date-time in a Local time zone (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/serverDateTime/serverDateTimeLocal
        OperationId: SystemDateTimeService_GetDateTimeLocal
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'serverDateTime/serverDateTimeLocal' -Method 'Get'  
    }
}

