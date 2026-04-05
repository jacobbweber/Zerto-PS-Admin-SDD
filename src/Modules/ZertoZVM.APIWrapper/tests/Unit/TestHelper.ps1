# Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

# Test Scaffolding
$Script:MockPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Mocks\ZertoZVM.APIWrapper.Mocks.json'
