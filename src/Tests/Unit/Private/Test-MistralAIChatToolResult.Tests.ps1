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
    Describe 'Test-MistralAIChatToolResult Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    role         = 'tool'
                    tool_call_id = 'string'
                    content      = 'string'
                }
                $standardToolsMulti = @(
                    [PSCustomObject]@{
                        role         = 'tool'
                        tool_call_id = 'string'
                        content      = 'string'
                    },
                    [PSCustomObject]@{
                        role         = 'tool'
                        tool_call_id = 'string2'
                        content      = 'string'
                    }
                )
                $multiWithDuplicateIds = @(
                    [PSCustomObject]@{
                        role         = 'tool'
                        tool_call_id = 'string'
                        content      = 'string'
                    },
                    [PSCustomObject]@{
                        role         = 'tool'
                        tool_call_id = 'string'
                        content      = 'string'
                    }
                )
                $incorrectStandardTools1 = [PSCustomObject]@{
                    tool_call_id = 'string'
                    content      = 'string'
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    role         = 'tool'
                    tool_call_id = 'string'
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    role    = 'tool'
                    content = 'string'
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    role         = 'user'
                    tool_call_id = 'string'
                    content      = 'string'
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
                $result = Test-MistralAIChatToolResult -ToolResults $standardTools -debug
                $result | Should -Be $true
            } #it

            It 'Should return true for multiple standard tool objects' {
                $result = Test-MistralAIChatToolResult -ToolResults $standardToolsMulti
                $result | Should -Be $true
            } #it

            It 'Should return false if there are duplicate tool_call_ids' {
                $result = Test-MistralAIChatToolResult -ToolResults $multiWithDuplicateIds
                $result | Should -Be $false
            } #it

            It 'Should return false is missing role property' {
                $result = Test-MistralAIChatToolResult -ToolResults $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false is missing tool_call_id property' {
                $result = Test-MistralAIChatToolResult -ToolResults $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false is missing content property' {
                $result = Test-MistralAIChatToolResult -ToolResults $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false is role property is not tool' {
                $result = Test-MistralAIChatToolResult -ToolResults $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-MistralAIChatToolResult -ToolResults $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-MistralAIChatToolResult -ToolResults $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-MistralAIChatToolResult
} #inModule
