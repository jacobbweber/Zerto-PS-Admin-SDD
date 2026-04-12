Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'public'
$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'private'

if (Test-Path -Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter '*.ps1' -File | ForEach-Object { . $_.FullName }
}

if (Test-Path -Path $publicPath) {
    $publicFiles = Get-ChildItem -Path $publicPath -Filter '*.ps1' -File
    foreach ($file in $publicFiles) {
        . $file.FullName
        Export-ModuleMember -Function $file.BaseName
    }
}
