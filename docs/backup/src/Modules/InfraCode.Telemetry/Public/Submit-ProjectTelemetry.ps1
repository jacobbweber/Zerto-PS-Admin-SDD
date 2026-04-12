function Submit-ProjectTelemetry {
    <#
    .SYNOPSIS
        Serializes and transmits a telemetry session to Dynatrace via OneAgent or the v2 Metrics API.

    .DESCRIPTION
        Transforms the [PSCustomObject] produced by New-ProjectTelemetry into Dynatrace Line Protocol
        (text/plain) and POSTs it to the specified ingest endpoint. Supports an optional JSON backup
        to the configured log directory before submission.

        Line Protocol format per metric:
            namespace.key,dim1=val1,dim2=val2 gauge,value [timestamp_ms]
            namespace.key,dim1=val1,dim2=val2 count,delta=N

        Transport modes:
          - Agent : POST to http://localhost:14499/metrics/ingest (no auth required)
          - API   : POST to {DT_Url}/api/v2/metrics/ingest (requires Config.DT_Token)

    .PARAMETER Session
        The [PSCustomObject] returned by New-ProjectTelemetry. Must contain .Namespace,
        .Dimensions, and .Metrics properties.

    .PARAMETER SubmitType
        Transport method. 'Agent' targets the local OneAgent ingest endpoint.
        'API' targets the remote Dynatrace v2 Metrics API.

    .PARAMETER Config
        A hashtable or [PSCustomObject] containing connection settings. Required keys:
          - LogDir   : Path for backup JSON files (when -Backup is used).
          - DT_Url   : Dynatrace environment URL (required for SubmitType 'API').
          - DT_Token : API token with metrics.ingest scope (required for SubmitType 'API').

    .PARAMETER Backup
        When specified, writes the full Session object as a JSON file to Config.LogDir
        before transmitting, using the filename pattern:
            Telemetry_Backup_yyyyMMdd_HHmmss.json

    .OUTPUTS
        [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject] — the Invoke-RestMethod response.

    .EXAMPLE
        Submit-ProjectTelemetry -Session $Telemetry -SubmitType Agent -Config $Config -Backup

    .EXAMPLE
        Submit-ProjectTelemetry -Session $Telemetry -SubmitType API -Config $Config
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Session,

        [Parameter(Mandatory)]
        [ValidateSet('API', 'Agent')]
        [string]$SubmitType,

        [Parameter(Mandatory)]
        [PSCustomObject]$Config,

        [Parameter()]
        [switch]$Backup
    )

    process {

        # ── 1. Validate session has metrics ──────────────────────────────────────
        if ($Session.Metrics.Count -eq 0) {
            Write-Warning "Submit-ProjectTelemetry: No metrics in session — skipping submission."
            return
        }

        # ── 2. Optional JSON Backup ───────────────────────────────────────────────
        if ($Backup) {
            $Timestamp  = Get-Date -UFormat '%Y%m%d_%H%M%S'
            $BackupPath = Join-Path $Config.LogDir "Telemetry_Backup_$Timestamp.json"
            Write-Verbose "Writing telemetry backup to: $BackupPath"
            $Session | ConvertTo-Json -Depth 10 | Out-File -FilePath $BackupPath -Encoding utf8
        }

        # ── 3. Build Line Protocol payload ────────────────────────────────────────
        # Format: namespace.key,dim1=val1,dim2=val2 [type,]value
        $Lines = foreach ($Metric in $Session.Metrics) {

            $DimString = ($Session.Dimensions.Keys | ForEach-Object {
                "$_=$($Session.Dimensions[$_])"
            }) -join ','

            $MetricKey = "$($Session.Namespace).$($Metric.Key)"

            # Dynatrace: for 'gauge' emit as "gauge,VALUE"; for 'count,delta' as "count,delta=VALUE"
            $PayloadStr = switch -Wildcard ($Metric.Type) {
                'count,delta' { "count,delta=$($Metric.Value)" }
                default       { "gauge,$($Metric.Value)" }
            }

            if ([string]::IsNullOrEmpty($DimString)) {
                "$MetricKey $PayloadStr"
            }
            else {
                "$MetricKey,$DimString $PayloadStr"
            }
        }

        $Body = $Lines -join "`n"
        Write-Verbose "Line Protocol payload ($($Session.Metrics.Count) metrics):`n$Body"

        # ── 4. Transmit ───────────────────────────────────────────────────────────
        $ContentType = 'text/plain; charset=utf-8'

        switch ($SubmitType) {
            'Agent' {
                $Uri = 'http://localhost:14499/metrics/ingest'
                Write-Verbose "Submitting via OneAgent → $Uri"

                if ($PSCmdlet.ShouldProcess($Uri, 'POST telemetry (Agent)')) {
                    return Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType $ContentType
                }
            }

            'API' {
                $Uri     = "$($Config.DT_Url)/api/v2/metrics/ingest"
                $Headers = @{ Authorization = "Api-Token $($Config.DT_Token)" }
                Write-Verbose "Submitting via Dynatrace v2 API → $Uri"

                if ($PSCmdlet.ShouldProcess($Uri, 'POST telemetry (API)')) {
                    return Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -Headers $Headers -ContentType $ContentType
                }
            }
        }
    }
}
