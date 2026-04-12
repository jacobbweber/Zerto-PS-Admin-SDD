function Export-ProjectCSVReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject[]]$Results,
        [Parameter(Mandatory = $false)]
        [string]$Path = "results.csv"
    )
    process {
        Write-Verbose "Exporting $($Results.Count) results to $Path"
        $Results | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
    }
}
