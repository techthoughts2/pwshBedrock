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
    $mistralAIModels = (Get-ModelInfo -Provider 'Mistral AI').ModelID
    Describe 'Format-MistralAITextMessage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            # BeforeEach {

            # } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-MistralAITextMessage -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-MistralAITextMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'mistral.mistral-7b-instruct-v0:2' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
                $userPrompt = 'Who is your favorite Starfleet Captain?'
                $expectedValue1 = @'
<s>[INST] Who is your favorite Starfleet Captain? [/INST]
'@
                $expectedValue2 = @'
<s>[INST] Who is your favorite Starfleet Captain? [/INST]
Well, I'm quite partial to Captain Picard.</s>
'@
                $expectedValue3 = @'
<s>[INST] Who is your favorite Starfleet Captain? [/INST]
Well, I'm quite partial to Captain Picard.</s>
[INST] Oh, Why? [/INST]
'@
                $normalizedExpectedValue1 = $expectedValue1 -replace "`r`n", "`n"
                $normalizedExpectedValue2 = $expectedValue2 -replace "`r`n", "`n"
                $normalizedExpectedValue3 = $expectedValue3 -replace "`r`n", "`n"
            } #beforeEach

            It 'should return a properly formatted initial message for: <_>' -ForEach $mistralAIModels {
                $formatMistralAIMessageSplat = @{
                    Role    = 'User'
                    Message = $userPrompt
                    ModelID = $_
                }
                $result = Format-MistralAITextMessage @formatMistralAIMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue1
            } #it

            It 'should properly add a model response to the context for: <_>' -ForEach $mistralAIModels {
                $formatMistralAIMessageSplat = @{
                    Role    = 'User'
                    Message = $userPrompt
                    ModelID = $_
                }
                Format-MistralAITextMessage @formatMistralAIMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message = "Well, I'm quite partial to Captain Picard."
                    Role    = 'Model'
                    ModelID = $_
                }
                $result = Format-MistralAITextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue2
            } #it

            It 'should handle a mutli-message conversation for: <_>' -ForEach $mistralAIModels {
                $formatMistralAIMessageSplat = @{
                    Role    = 'User'
                    Message = $userPrompt
                    ModelID = $_
                }
                Format-MistralAITextMessage @formatMistralAIMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message = "Well, I'm quite partial to Captain Picard."
                    Role    = 'Model'
                    ModelID = $_
                }
                Format-MistralAITextMessage @formatMetaTextMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message = 'Oh, Why?'
                    Role    = 'User'
                    ModelID = $_
                }
                $result = Format-MistralAITextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue3
            } #it

            It 'should populate context for the <_> model' -ForEach $mistralAIModels {
                $formatMistralAIMessageSplat = @{
                    Role    = 'User'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.\n'
                    ModelID = $_
                }
                Format-MistralAITextMessage @formatMistralAIMessageSplat
                $context = Get-ModelContext -ModelID $_
                $context | Should -Not -BeNullOrEmpty
            } #it

            It 'should not populate context if NoContextPersist is set to true' -ForEach $mistralAIModels {
                $formatMistralAIMessageSplat = @{
                    Role             = 'User'
                    Message          = 'I am not a'
                    ModelID          = $_
                    NoContextPersist = $true
                }
                $result = Format-MistralAITextMessage @formatMistralAIMessageSplat
                $context = Get-ModelContext -ModelID $_
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-MistralAITextMessage
} #inModule
