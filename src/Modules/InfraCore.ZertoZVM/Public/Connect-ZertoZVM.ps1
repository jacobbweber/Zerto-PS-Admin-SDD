function Connect-ZertoZVM {
    <#
    .SYNOPSIS
        Establishes an authenticated session with a Zerto ZVM.

    .DESCRIPTION
        Authenticates against the Zerto ZVM REST API and stores the session token,
        base URI, and API version in module-scoped state. Must be called before
        any other InfraCode.ZertoZVM functions.

    .PARAMETER ZVMHost
        Hostname or IP address of the Zerto ZVM (e.g. "zvm.example.com" or "192.168.1.10").

    .PARAMETER Port
        TCP port of the ZVM. Defaults to 9669.

    .PARAMETER ApiVersion
        API version string. Defaults to "v1".

    .PARAMETER Credential
        PSCredential containing the ZVM username and password.
        If omitted, Get-Credential is called interactively.

    .PARAMETER UseSsl
        Use HTTPS (default). Pass -UseSsl:$false for plain HTTP (lab/sim only).

    .PARAMETER SkipCertificateCheck
        Skip TLS certificate validation. Useful for self-signed lab certificates.

    .EXAMPLE
        Connect-ZertoZVM -ZVMHost "zvm.lab.local" -Credential (Get-Credential) -SkipCertificateCheck

    .EXAMPLE
        $cred = [pscredential]::new('admin', (ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Connect-ZertoZVM -ZVMHost "localhost" -Port 9669 -Credential $cred -SkipCertificateCheck

    .OUTPUTS
        PSCustomObject with ZVMHost, ApiVersion, and Connected status.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string] $ZVMHost,

        [Parameter()]
        [ValidateRange(1, 65535)]
        [int] $Port,

        [Parameter()]
        [string] $ApiVersion = 'v1',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = (Get-Credential -Message "Enter Zerto ZVM credentials"),

        [Parameter()]
        [switch] $UseSsl = $true,

        [Parameter()]
        [switch] $SkipCertificateCheck
    )

    $scheme = if ($UseSsl) { 'https' } else { 'http' }
    $baseUri = if ($Port) { "${scheme}://${ZVMHost}:${Port}" } else { "${scheme}://${ZVMHost}" }

    # Store session state (partial — not yet Connected)
    $script:ZertoSession.BaseUri = $baseUri
    $script:ZertoSession.ApiVersion = $ApiVersion
    $script:ZertoSession.SkipCertificateCheck = $SkipCertificateCheck.IsPresent
    $script:ZertoSession.Headers = @{}
    $script:ZertoSession.Connected = $false

    # Build auth header from credential (Basic auth for session creation)
    $plainUser = $Credential.UserName
    $plainPass = $Credential.GetNetworkCredential().Password
    $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${plainUser}:${plainPass}"))

    $sessionUri = "$baseUri/vra/api/$ApiVersion/session/add"
    $irmParams = @{
        Uri         = $sessionUri
        Method      = 'Post'
        Headers     = @{ Authorization = "Basic $encoded" }
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }
    if ($SkipCertificateCheck) { $irmParams.SkipCertificateCheck = $true }

    try {
        Write-Verbose "Connect-ZertoZVM: Authenticating to $sessionUri"
        $response = Invoke-RestMethod @irmParams

        # The token arrives in the response body or a header depending on ZVM version.
        # v1 returns the token as a plain string in the body.
        $token = if ($response -is [string]) { $response } else { $response.sessionToken }

        if ([string]::IsNullOrWhiteSpace($token)) {
            throw "Authentication succeeded but no session token was returned."
        }

        $script:ZertoSession.Headers = @{ 'x-zerto-session' = $token }
        $script:ZertoSession.Connected = $true

        [PSCustomObject]@{
            ZVMHost    = $ZVMHost
            Port       = $Port
            ApiVersion = $ApiVersion
            Connected  = $true
        }
    }
    catch {
        # Reset session on failure
        $script:ZertoSession.BaseUri = $null
        $script:ZertoSession.Connected = $false
        $script:ZertoSession.Headers = @{}
        throw "Connect-ZertoZVM failed: $_"
    }
}
