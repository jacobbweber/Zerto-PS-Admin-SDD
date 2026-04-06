function Set-FormattedEmail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject[]]$Results,
        [Parameter(Mandatory = $false)]
        [string]$Title = "Zerto Report"
    )
    process {
        $html = "<html><body><h1>$Title</h1><ul>"
        foreach ($res in $Results) {
            $html += "<li>$($res.VPGName) (Status: $($res.Status))</li>"
        }
        $html += "</ul></body></html>"
        return $html
    }
}

function Send-FormattedEmail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$HtmlBody,
        [Parameter(Mandatory = $false)]
        [string]$To,
        [Parameter(Mandatory = $false)]
        [string]$SmtpServer
    )
    process {
        Write-Verbose "Sending email to $To via $SmtpServer"
        # In a real environment, this would call Send-MailMessage
    }
}
