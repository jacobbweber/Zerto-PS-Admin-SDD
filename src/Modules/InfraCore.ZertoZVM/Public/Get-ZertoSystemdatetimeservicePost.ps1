function Get-ZertoSystemdatetimeservicePost {
    <#
    .SYNOPSIS
        Check system date time casting from parameters. Specify the date and check the return value to prove your expectations. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/serverDateTime/dateTimeArgument
        OperationId: SystemDateTimeService_Post
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Datetime
    )

    process {
    $query = @{}
        if ($Datetime) { $query['dateTime'] = $Datetime }

        Invoke-ZertoRequest -Endpoint 'serverDateTime/dateTimeArgument' -Method 'Get' -QueryParameters $query 
    }
}
