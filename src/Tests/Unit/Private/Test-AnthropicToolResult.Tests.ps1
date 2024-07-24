#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
$script:assetPath = [System.IO.Path]::Combine('..', 'assets')
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'pwshBedrock' {
    Describe 'Test-AnthropicToolResult Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    tool_use_id = 'string'
                    content     = 'string'
                }
                $standardToolsMulti = @(
                    [PSCustomObject]@{
                        tool_use_id = 'string1'
                        content     = 'string'
                    },
                    [PSCustomObject]@{
                        tool_use_id = 'string2'
                        content     = 'string'
                    }
                )
                $multiWithDuplicateIds = @(
                    [PSCustomObject]@{
                        tool_use_id = 'string'
                        content     = 'string'
                    },
                    [PSCustomObject]@{
                        tool_use_id = 'string'
                        content     = 'string'
                    }
                )
                $incorrectStandardTools1 = [PSCustomObject]@{
                    content = 'string'
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    tool_use_id = 'string'
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
                $result = Test-AnthropicToolResult -ToolResults $standardTools -debug
                $result | Should -Be $true
            } #it

            It 'Should return true for multiple standard tool objects' {
                $result = Test-AnthropicToolResult -ToolResults $standardToolsMulti
                $result | Should -Be $true
            } #it

            It 'Should return false if there are duplicate tool_call_ids' {
                $result = Test-AnthropicToolResult -ToolResults $multiWithDuplicateIds
                $result | Should -Be $false
            } #it

            It 'Should return false is missing tool_use_id property' {
                $result = Test-AnthropicToolResult -ToolResults $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false is missing content property' {
                $result = Test-AnthropicToolResult -ToolResults $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-AnthropicToolResult -ToolResults $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-AnthropicToolResult -ToolResults $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-AnthropicToolResult
} #inModule
