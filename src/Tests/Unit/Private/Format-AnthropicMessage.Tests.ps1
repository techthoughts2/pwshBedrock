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
    $anthropicModels = (Get-ModelInfo -Provider Anthropic).ModelID
    Describe 'Format-AnthropicMessage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Mock -CommandName 'Convert-MediaToBase64' -MockWith { 'base64String' }
            } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-AnthropicMessage -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-AnthropicMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'anthropic.claude-v2:1' } | Should -Throw
            } #it

            It 'should throw if the base64 conversion fails' {
                Mock -CommandName 'Convert-MediaToBase64' -MockWith { throw 'Failed to convert media to base64' }
                { Format-AnthropicMessage -Role 'user' -Message 'I am not a merry man.' -ModelID 'anthropic.claude-v2:1' -MediaPath 'path/to/media.jpg' } | Should -Throw
            } #it

            It 'should throw if an error is encountered while getting media file info' {
                Mock -CommandName Get-Item -MockWith { throw 'Failed to get media file info' }
                { Format-AnthropicMessage -Role 'user' -Message "The only person you're truly competing against is yourself." -ModelID 'anthropic.claude-v2:1' -MediaPath 'path/to/media.jpg' } | Should -Throw
            } #it

            It 'should throw if Get-Item does not return an extension' {
                Mock -CommandName Get-Item -MockWith { $null }
                { Format-AnthropicMessage -Role 'user' -Message 'The acquisition of wealth is no longer the driving force of our lives. We work to better ourselves and the rest of humanity.' -ModelID 'anthropic.claude-v2:1' -MediaPath 'path/to/media.jpg' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Mock -CommandName 'Convert-MediaToBase64' -MockWith { 'base64String' }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{ Extension = '.jpg' }
                } #endMock
                $standardToolsResult = [PSCustomObject]@{
                    tool_use_id = 'id123'
                    content     = 'Elemental Hotel'
                }
                $standardToolsCall = [PSCustomObject]@{
                    type  = 'tool_use'
                    id    = 'id123'
                    name  = 'top_song'
                    input = [PSCustomObject]@{
                        sign = 'WZPZ'
                    }
                }
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should return a PSObject with the expected values for a standard message for <_>' -ForEach $anthropicModels {
                $formatAnthropicMessageSplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = $_
                }
                $result = Format-AnthropicMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].type | Should -BeExactly 'text'
                $result.content[0].text | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a PSObject with the expected values for a message with media for <_>' -ForEach ($anthropicModels | Where-Object { $_ -ne 'anthropic.claude-v2:1' }) {
                $formatAnthropicMessageSplat = @{
                    Role      = 'user'
                    Message   = 'Live now; make now always the most precious time. Now will never come again.'
                    ModelID   = $_
                    MediaPath = 'path/to/media.jpg'
                }
                $result = Format-AnthropicMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].type | Should -BeExactly 'image'
                $result.content[0].source.type | Should -BeExactly 'base64'
                $result.content[0].source.'media_type' | Should -BeExactly 'image/jpeg'
                $result.content[0].source.data | Should -BeExactly 'base64String'
                $result.content[1].type | Should -BeExactly 'text'
                $result.content[1].text | Should -BeExactly 'Live now; make now always the most precious time. Now will never come again.'
            } #it

            It 'should return a PSObject with the expected values for tools results for <_>' -ForEach ($anthropicModels | Where-Object { $_ -ne 'anthropic.claude-v2:1' }) {
                $formatAnthropicMessageSplat = @{
                    Role         = 'user'
                    ToolsResults = $standardToolsResult
                    ModelID      = $_
                }
                $result = Format-AnthropicMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].tool_use_id | Should -BeExactly 'id123'
                $result.content[0].content | Should -BeExactly 'Elemental Hotel'
            } #it

            It 'should return a PSObject with the expected values for tools results with object data for <_>' -ForEach ($anthropicModels | Where-Object { $_ -ne 'anthropic.claude-v2:1' }) {
                $toolsResults = [PSCustomObject]@{
                    tool_use_id = 'id123'
                    content     = [PSCustomObject]@{
                        name        = 'Gristmill River Restaurant & Bar'
                        rating      = '4.6'
                        price_level = '2'
                        Open        = 'True'
                    }
                }
                $formatAnthropicMessageSplat = @{
                    Role         = 'user'
                    ToolsResults = $toolsResults
                    ModelID      = $_
                }
                $result = Format-AnthropicMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].tool_use_id | Should -BeExactly 'id123'
                $result.content[0].content[0].type | Should -BeExactly 'text'
                $result.content[0].content[1].type | Should -BeExactly 'text'
                $result.content[0].content[2].type | Should -BeExactly 'text'
                $result.content[0].content[3].type | Should -BeExactly 'text'
                $result.content[0].content[0].text | Should -BeExactly 'name = Gristmill River Restaurant & Bar'
                $result.content[0].content[1].text | Should -BeExactly 'rating = 4.6'
                $result.content[0].content[2].text | Should -BeExactly 'price_level = 2'
                $result.content[0].content[3].text | Should -BeExactly 'Open = True'
            } #it

            It 'should return a PSObject with the expected values for tools call for <_>' -ForEach ($anthropicModels | Where-Object { $_ -ne 'anthropic.claude-v2:1' }) {
                $formatAnthropicMessageSplat = @{
                    Role     = 'assistant'
                    ToolCall = $standardToolsCall
                    ModelID  = $_
                }
                $result = Format-AnthropicMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'assistant'
                $result.content.type | Should -BeExactly 'tool_use'
                $result.content.id | Should -BeExactly 'id123'
                $result.content.name | Should -BeExactly 'top_song'
                $result.content.input.sign | Should -BeExactly 'WZPZ'
            } #it

            It 'should populate context for <_>' -ForEach $anthropicModels {
                $formatAnthropicMessageSplat = @{
                    Role    = 'user'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.'
                    ModelID = $_
                }
                Format-AnthropicMessage @formatAnthropicMessageSplat
                $context = Get-ModelContext -ModelID $_
                ($context | Measure-Object).Count | Should -BeExactly 1
            } #it

            It 'should not populate context if NoContextPersist is set to true for <_>' -ForEach $anthropicModels {
                $formatAnthropicMessageSplat = @{
                    Role             = 'user'
                    Message          = 'I am not a'
                    ModelID          = $_
                    NoContextPersist = $true
                }
                $result = Format-AnthropicMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $context = Get-ModelContext -ModelID $_
                $context.Count | Should -BeExactly 0
            } #it

        } #context_Success

    } #describe_Format-AnthropicMessage
} #inModule
