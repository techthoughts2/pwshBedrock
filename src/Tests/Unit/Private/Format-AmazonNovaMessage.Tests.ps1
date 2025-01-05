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

    Describe '1 Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Mock -CommandName 'Convert-MediaToBase64' -MockWith { 'base64String' }
            } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-AmazonNovaMessage -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-AmazonNovaMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'amazon.nova-pro-v1:0' } | Should -Throw
            } #it

            It 'should throw if the base64 conversion fails' {
                Mock -CommandName 'Convert-MediaToBase64' -MockWith { throw 'Failed to convert media to base64' }
                { Format-AmazonNovaMessage -Role 'user' -Message 'I am not a merry man.' -ModelID 'amazon.nova-pro-v1:0' -MediaPath 'path/to/media.jpg' } | Should -Throw
            } #it

            It 'should throw if an error is encountered while getting media file info' {
                Mock -CommandName Get-Item -MockWith { throw 'Failed to get media file info' }
                { Format-AmazonNovaMessage -Role 'user' -Message "The only person you're truly competing against is yourself." -ModelID 'amazon.nova-pro-v1:0' -MediaPath 'path/to/media.jpg' } | Should -Throw
            } #it

            It 'should throw if Get-Item does not return an extension' {
                Mock -CommandName Get-Item -MockWith { $null }
                { Format-AmazonNovaMessage -Role 'user' -Message 'The acquisition of wealth is no longer the driving force of our lives. We work to better ourselves and the rest of humanity.' -ModelID 'amazon.nova-pro-v1:0' -MediaPath 'path/to/media.jpg' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Mock -CommandName 'Convert-MediaToBase64' -MockWith { 'base64String' }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{ Extension = '.jpg' }
                } #endMock
                $standardToolsResult = [PSCustomObject]@{
                    toolUseId = 'id123'
                    content   = 'Elemental Hotel'
                    Status    = 'success'
                }
                $errorToolsResult = [PSCustomObject]@{
                    toolUseId = 'id123'
                    content   = ''
                    Status    = 'error'
                }
                $standardToolsCall = [PSCustomObject]@{
                    toolUseId = 'id123'
                    name      = 'top_song'
                    input     = [PSCustomObject]@{
                        sign = 'WZPZ'
                    }
                }
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should return a PSObject with the expected values for a standard message for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = $_.ModelId
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].text | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a PSObject with the expected values for a message with image media for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role      = 'user'
                    Message   = 'Live now; make now always the most precious time. Now will never come again.'
                    ModelID   = $_.ModelId
                    MediaPath = 'path/to/media.jpg'
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].image.format | Should -BeExactly 'jpg'
                $result.content[0].image.source.bytes | Should -BeExactly 'base64String'
                $result.content[1].text | Should -BeExactly 'Live now; make now always the most precious time. Now will never come again.'
            } #it

            It 'should return a PSObject with the expected values for a message with video media for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{ Extension = '.mp4' }
                } #endMock
                $formatAmazonNovaMessageSplat = @{
                    Role      = 'user'
                    Message   = 'Live now; make now always the most precious time. Now will never come again.'
                    ModelID   = $_.ModelId
                    MediaPath = 'path/to/media.mp4'
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].video.format | Should -BeExactly 'mp4'
                $result.content[0].video.source.bytes | Should -BeExactly 'base64String'
                $result.content[1].text | Should -BeExactly 'Live now; make now always the most precious time. Now will never come again.'
            } #it

            It 'should return a PSObject with the expected values for a message with document media for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Extension = '.pdf'
                        BaseName  = 'document'
                    }
                } #endMock
                $formatAmazonNovaMessageSplat = @{
                    Role      = 'user'
                    Message   = 'Live now; make now always the most precious time. Now will never come again.'
                    ModelID   = $_.ModelId
                    MediaPath = 'path/to/document.pdf'
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].document.format | Should -BeExactly 'pdf'
                $result.content[0].document.name | Should -BeExactly 'document'
                $result.content[0].document.source.bytes | Should -BeExactly 'base64String'
                $result.content[1].text | Should -BeExactly 'Live now; make now always the most precious time. Now will never come again.'
            } #it

            It 'should return a PSObject with the expected values for tools results for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role         = 'user'
                    ToolsResults = $standardToolsResult
                    ModelID      = $_.ModelId
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].toolResult.toolUseId | Should -BeExactly 'id123'
                $result.content[0].toolResult.content | Should -BeExactly 'Elemental Hotel'
            } #it

            It 'should return a PSObject with the expected values for error tools results for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role         = 'user'
                    ToolsResults = $errorToolsResult
                    ModelID      = $_.ModelId
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].toolResult.toolUseId | Should -BeExactly 'id123'
                $result.content[0].toolResult.content | Should -BeNullOrEmpty
            } #it

            It 'should return a PSObject with the expected values for tools results with object data for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $toolsResults = [PSCustomObject]@{
                    toolUseId = 'id123'
                    content   = [PSCustomObject]@{
                        name        = 'Gristmill River Restaurant & Bar'
                        rating      = '4.6'
                        price_level = '2'
                        Open        = 'True'
                    }
                    Status    = 'success'
                }
                $formatAmazonNovaMessageSplat = @{
                    Role         = 'user'
                    ToolsResults = $toolsResults
                    ModelID      = $_.ModelId
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].toolResult.toolUseId | Should -BeExactly 'id123'
                $result.content[0].toolResult.content[0].json | Should -Not -BeNullOrEmpty
                $result.content[0].toolResult.content[0].json.name | Should -BeExactly 'Gristmill River Restaurant & Bar'
                $result.content[0].toolResult.content[0].json.rating | Should -BeExactly '4.6'
                $result.content[0].toolResult.content[0].json.price_level | Should -BeExactly '2'
                $result.content[0].toolResult.content[0].json.Open | Should -BeExactly 'True'
            } #it

            It 'should return a PSObject with the expected values for error tools results with object data for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $toolsResults = [PSCustomObject]@{
                    toolUseId = 'id123'
                    content   = $null
                    Status    = 'error'
                }
                $formatAmazonNovaMessageSplat = @{
                    Role         = 'user'
                    ToolsResults = $toolsResults
                    ModelID      = $_.ModelId
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content[0].toolResult.toolUseId | Should -BeExactly 'id123'
                $result.content[0].toolResult.content | Should -BeNullOrEmpty
            } #it

            It 'should return a PSObject with the expected values for tools call for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role     = 'assistant'
                    ToolCall = $standardToolsCall
                    ModelID  = $_.ModelId
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'assistant'
                $result.content.toolUse.toolUseId | Should -BeExactly 'id123'
                $result.content.toolUse.name | Should -BeExactly 'top_song'
                $result.content.toolUse.input.sign | Should -BeExactly 'WZPZ'
            } #it

            It 'should populate context for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role    = 'user'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.'
                    ModelID = $_.ModelId
                }
                Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $context = Get-ModelContext -ModelID $_.ModelId
                ($context | Measure-Object).Count | Should -BeExactly 1
            } #it

            It 'should not populate context if NoContextPersist is set to true for <_.ModelId>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $formatAmazonNovaMessageSplat = @{
                    Role             = 'user'
                    Message          = 'I am not a'
                    ModelID          = $_.ModelId
                    NoContextPersist = $true
                }
                $result = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $context = Get-ModelContext -ModelID $_.ModelId
                $context.Count | Should -BeExactly 0
            } #it

        } #context_Success

    } #describe_Format-AmazonNovaMessage
} #inModule
