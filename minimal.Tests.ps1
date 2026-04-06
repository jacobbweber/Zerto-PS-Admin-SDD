#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Describe "Minimal Test" {
    It "Should import ZertoZVM.Core" {
        Import-Module src/Modules/ZertoZVM.Core/ZertoZVM.Core.psd1 -Force
        Get-Module ZertoZVM.Core | Should -Not -BeNull
    }
}
