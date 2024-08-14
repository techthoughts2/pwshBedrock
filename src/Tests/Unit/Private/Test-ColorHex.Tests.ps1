BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    Describe 'Test-ColorHex Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $validHexColor = '#FF0000'
            $invalidHexColor = '#FF000'
            $tooManyColors = @('#FF0000', '#00FF00', '#0000FF', '#FF0000', '#00FF00', '#0000FF', '#FF0000', '#00FF00', '#0000FF', '#FF0000', '#00FF00', '#0000FF')
        } #beforeAll

        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            It 'Should return true for a valid hex color' {
                $result = Test-ColorHex -Colors $validHexColor
                $result | Should -Be $true
            } #it

            It 'Should return false for an invalid hex color' {
                $result = Test-ColorHex -Colors $invalidHexColor
                $result | Should -Be $false
            } #it

            It 'Should return false for too many colors' {
                $result = Test-ColorHex -Colors $tooManyColors
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-ColorHex
} #inModule
