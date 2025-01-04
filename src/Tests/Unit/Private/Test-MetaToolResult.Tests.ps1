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
    Describe 'Test-MetaToolResult Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    output = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools1 = [PSCustomObject]@{
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    output = 'string'
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    output = @(
                        'string1',
                        'string2'
                    )
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    output = @()
                }
                $malformedTools = @(
                    [PSCustomObject]@{ role = 'zzzz'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'xxxx'; message = 'Hello, how are you?' }
                )
                $malformedTools2 = [PSCustomObject]@{
                    role = 'user'
                }
            } #beforeEach

            It 'Should return true for a standard tool object' {
                $result = Test-MetaToolResult -ToolResults $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return false is missing output property' {
                $result = Test-MetaToolResult -ToolResults $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false is output property is not an array' {
                $result = Test-MetaToolResult -ToolResults $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false is output contains items that are not PSCustomObjects' {
                $result = Test-MetaToolResult -ToolResults $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false is output is empty' {
                $result = Test-MetaToolResult -ToolResults $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object' {
                $result = Test-MetaToolResult -ToolResults $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for a tool object missing properties' {
                $result = Test-MetaToolResult -ToolResults $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-MetaToolResult
} #inModule
