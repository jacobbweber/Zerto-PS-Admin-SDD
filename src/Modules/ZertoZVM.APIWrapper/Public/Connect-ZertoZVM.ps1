function Connect-ZertoZVM {
    <#
    .SYNOPSIS
        Establishes an authenticated session with a Zerto ZVM.
    
    .DESCRIPTION
        Refactored to support silent re-authentication and session tracking.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string] $ZVMHost,

        [Parameter()]
        [int] $Port = 9669,

        [Parameter()]
        [string] $ApiVersion = 'v1',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [switch] $UseSsl = $true,

        [Parameter()]
        [switch] $SkipCertificateCheck
    )

    # 1. Handle Silent Re-auth / Credential Bootstrapping
    # If no credential provided, check if we have one cached in script scope
    if ($null -eq $Credential) {
        if ($null -ne $script:ZertoSession.CachedCredential) {
            $Credential = $script:ZertoSession.CachedCredential
            Write-Verbose "Connect-ZertoZVM: Using cached credentials for re-authentication."
        }
        else {
            # Fallback to interactive only if absolutely necessary
            $Credential = Get-Credential -Message "Enter Zerto ZVM credentials"
        }
    }

    $scheme = if ($UseSsl) { 'https' } else { 'http' }
    $baseUri = if ($Port) { "${scheme}://${ZVMHost}:${Port}" } else { "${scheme}://${ZVMHost}" }

    # Initialize/Reset session state
    $script:ZertoSession.BaseUri = $baseUri
    $script:ZertoSession.ApiVersion = $ApiVersion
    $script:ZertoSession.SkipCertificateCheck = $SkipCertificateCheck.IsPresent
    $script:ZertoSession.Headers = @{}
    $script:ZertoSession.Connected = $false
    $script:ZertoSession.CachedCredential = $Credential # Cache for silent refresh

    # Build auth header
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

        $token = if ($response -is [string]) { $response } else { $response.sessionToken }

        if ([string]::IsNullOrWhiteSpace($token)) {
            throw "Authentication succeeded but no session token was returned."
        }

        # FINAL SUCCESS STATE
        $script:ZertoSession.Headers = @{ 'x-zerto-session' = $token }
        $script:ZertoSession.Connected = $true
        $script:ZertoSession.TokenTimestamp = [DateTime]::UtcNow # MANDATORY for Assert-ZertoSession

        return [PSCustomObject]@{
            ZVMHost        = $ZVMHost
            Port           = $Port
            ApiVersion     = $ApiVersion
            Connected      = $true
            TokenTimestamp = $script:ZertoSession.TokenTimestamp
        }
    }
    catch {
        $script:ZertoSession.Connected = $false
        throw "Connect-ZertoZVM failed: $_"
    }
}