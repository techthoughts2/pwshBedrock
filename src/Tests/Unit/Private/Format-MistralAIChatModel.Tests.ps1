BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    $anthropicModels = (Get-ModelInfo -Provider Anthropic).ModelID
    Describe 'Format-MistralAIChatModel Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-MistralAIChatModel -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-MistralAIChatModel -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'mistral.mistral-large-2402-v1:0' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should return a PSObject with the expected values for a standard message' {
                $formatMistralAIChatSplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result = Format-MistralAIChatModel @formatMistralAIChatSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a PSObject with the expected values for a assistant message' {
                $formatMistralAIChatSplat = @{
                    Role    = 'assistant'
                    Message = 'I have been and always shall be your friend.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result = Format-MistralAIChatModel @formatMistralAIChatSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'assistant'
                $result.content | Should -BeExactly 'I have been and always shall be your friend.'
            } #it

            It 'should return a PSObject with the expected values for a tool message' {
                $formatMistralAIChatSplat = @{
                    Role         = 'tool'
                    ToolsResults = [PSCustomObject]@{
                        role         = 'tool'
                        tool_call_id = 'v6RMMiRlT7ygYkT4uULjtg'
                        content      = [ordered]@{
                            song   = 'Elemental Hotel'
                            artist = '8 Storey Hike'
                        }
                    }
                    ModelID      = 'mistral.mistral-large-2402-v1:0'
                }
                $result = Format-MistralAIChatModel @formatMistralAIChatSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'tool'
                $result.tool_call_id | Should -BeExactly 'v6RMMiRlT7ygYkT4uULjtg'
                $result.content | Should -BeExactly '{"song":"Elemental Hotel","artist":"8 Storey Hike"}'
            } #it

            It 'should properly format an assistant message if tool call is provided' {
                $formatMistralAIChatSplat = @{
                    Role      = 'assistant'
                    Message   = 'string'
                    ModelID   = 'mistral.mistral-large-2402-v1:0'
                    ToolCalls = @(
                        [PSCustomObject]@{
                            id       = 'idString'
                            function = @{
                                name      = 'nameString'
                                arguments = 'argumentsString'
                            }
                        }
                    )
                }
                $result = Format-MistralAIChatModel @formatMistralAIChatSplat
                $result | Should -BeOfType 'System.Management.Automation.PSCustomObject'
                $result.role | Should -BeExactly 'assistant'
                $result.content | Should -BeExactly 'string'
                # $result.tool_calls | Should -BeOfType 'System.Object[]'
                $result.tool_calls[0].id | Should -BeExactly 'idString'
                $result.tool_calls[0].function.name | Should -BeExactly 'nameString'
                $result.tool_calls[0].function.arguments | Should -BeExactly 'argumentsString'
            } #it

            It 'should return a PSObject with the expected values for a system message' {
                $formatMistralAIChatSplat = @{
                    Role    = 'system'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result = Format-MistralAIChatModel @formatMistralAIChatSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'system'
                $result.content | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a PSObject with the expected values for an updated system message' {
                $formatMistralAIChatSplat = @{
                    Role    = 'system'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result1 = Format-MistralAIChatModel @formatMistralAIChatSplat

                $formatMistralAIChatSplat = @{
                    Role    = 'system'
                    Message = 'You are a helpful android.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result2 = Format-MistralAIChatModel @formatMistralAIChatSplat
                $context = Get-ModelContext -ModelID 'mistral.mistral-large-2402-v1:0'
                $systemContext = $context | Where-Object { $_.Role -eq 'system' }
                $systemContext.Content | Should -BeExactly 'You are a helpful android.'
            } #it

            It 'should return a PSObject with the expected values for an added system message' {
                $formatMistralAIChatSplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result1 = Format-MistralAIChatModel @formatMistralAIChatSplat

                $formatMistralAIChatSplat = @{
                    Role    = 'system'
                    Message = 'You are a helpful android.'
                    ModelID = 'mistral.mistral-large-2402-v1:0'
                }
                $result2 = Format-MistralAIChatModel @formatMistralAIChatSplat
                $context = Get-ModelContext -ModelID 'mistral.mistral-large-2402-v1:0'
                $systemContext = $context | Where-Object { $_.Role -eq 'system' }
                $systemContext.Content | Should -BeExactly 'You are a helpful android.'
            } #it

            It 'should not populate context if NoContextPersist is set to true' {
                $formatMistralAIChatSplat = @{
                    Role             = 'user'
                    Message          = 'I am not a'
                    ModelID          = 'mistral.mistral-large-2402-v1:0'
                    NoContextPersist = $true
                }
                $result = Format-MistralAIChatModel @formatMistralAIChatSplat
                $context = Get-ModelContext -ModelID 'mistral.mistral-large-2402-v1:0'
                Write-Verbose -Message ('Context Count: {0}' -f $context.Count)
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-MistralAIChatModel
} #inModule
