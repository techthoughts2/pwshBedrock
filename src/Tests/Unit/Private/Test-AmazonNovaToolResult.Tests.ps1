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
    Describe 'Test-AmazonNovaToolResult Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    toolUseId = 'string'
                    content   = 'string'
                    Status    = 'success'
                }
                $standardToolsMulti = @(
                    [PSCustomObject]@{
                        toolUseId = 'string1'
                        content   = 'string'
                        Status    = 'success'
                    },
                    [PSCustomObject]@{
                        toolUseId = 'string2'
                        content   = 'string'
                        Status    = 'success'
                    }
                )
                $multiWithDuplicateIds = @(
                    [PSCustomObject]@{
                        toolUseId = 'string'
                        content   = 'string'
                        Status    = 'success'
                    },
                    [PSCustomObject]@{
                        toolUseId = 'string'
                        content   = 'string'
                        Status    = 'success'
                    }
                )
                $incorrectStandardTools1 = [PSCustomObject]@{
                    content = 'string'
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    toolUseId = 'string'
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    toolUseId = 'string'
                    content   = 'string'
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
                $result = Test-AmazonNovaToolResult -ToolResults $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return true for multiple standard tool objects' {
                $result = Test-AmazonNovaToolResult -ToolResults $standardToolsMulti
                $result | Should -Be $true
            } #it

            It 'Should return false if there are duplicate tool_call_ids' {
                $result = Test-AmazonNovaToolResult -ToolResults $multiWithDuplicateIds
                $result | Should -Be $false
            } #it

            It 'Should return false is missing toolUseId property' {
                $result = Test-AmazonNovaToolResult -ToolResults $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false is missing content property' {
                $result = Test-AmazonNovaToolResult -ToolResults $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false is missing Status property' {
                $result = Test-AmazonNovaToolResult -ToolResults $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-AmazonNovaToolResult -ToolResults $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-AmazonNovaToolResult -ToolResults $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-AmazonNovaToolResult
} #inModule
