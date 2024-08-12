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
    $metaModels = (Get-ModelInfo -Provider Meta).ModelID
    $llama2Models = $metaModels | Where-Object { $_ -like '*llama2*' }
    $llama3Models = $metaModels | Where-Object { $_ -like '*llama3*' }
    Describe 'Format-MetaTextMessage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            # BeforeEach {

            # } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-MetaTextMessage -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-MetaTextMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'meta.llama2-13b-chat-v1' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
                $userPrompt = 'Who is the best captain in Star Trek?'
                $systemPrompt = 'You are a Star Trek trivia expert.'
                $expectedValue1 = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]
'@
                $expectedValue2 = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]Captain Picard</s>
'@
                $expectedValue3 = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a Star Trek trivia expert.<|eot_id|>

Who is the best captain in Star Trek?<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                $expectedValue4 = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a Star Trek trivia expert.<|eot_id|>

Who is the best captain in Star Trek?<|eot_id|><|start_header_id|>assistant<|end_header_id|>

Captain Picard<|eot_id|><|start_header_id|>user<|end_header_id|>
'@
                $expectedValue5 = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a Star Trek trivia expert.<|eot_id|>

Who is the best captain in Star Trek?<|eot_id|><|start_header_id|>assistant<|end_header_id|>

Captain Picard<|eot_id|><|start_header_id|>user<|end_header_id|>

Because of his fondness for Earl Grey?<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                $expectedValue6 = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]Captain Picard</s>
<s>[INST]Because of his fondness for Earl Grey?[/INST]
'@
                $normalizedExpectedValue1 = $expectedValue1 -replace "`r`n", "`n"
                $normalizedExpectedValue2 = $expectedValue2 -replace "`r`n", "`n"
                $normalizedExpectedValue3 = $expectedValue3 -replace "`r`n", "`n"
                $normalizedExpectedValue4 = $expectedValue4 -replace "`r`n", "`n"
                $normalizedExpectedValue5 = $expectedValue5 -replace "`r`n", "`n"
                $normalizedExpectedValue6 = $expectedValue6 -replace "`r`n", "`n"
            } #beforeEach

            It 'should return a properly formatted initial message for Llama 2 model: <_>' -ForEach $llama2Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue1
            } #it

            It 'should properly add a model response to the context for Llama 2 model: <_>' -ForEach $llama2Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Model'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue2
            } #it

            It 'should handle a multi-message conversation for Llama 2 model: <_>' -ForEach $llama2Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Model'
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaTextMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Because of his fondness for Earl Grey?'
                    SystemPrompt = $systemPrompt
                    Role         = 'User'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue6
            } #it

            It 'should return a properly formatted initial message for Llama 3 model: <_>' -ForEach $llama3Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue3
            } #it

            It 'should properly add a model response to the context for Llama 3 model: <_>' -ForEach $llama3Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Model'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue4
            } #it

            It 'should handle a multi-message conversation for Llama 3 model: <_>' -ForEach $llama3Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Model'
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaTextMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Because of his fondness for Earl Grey?'
                    SystemPrompt = $systemPrompt
                    Role         = 'User'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue5
            } #it

            It 'should populate context for the <_> model' -ForEach $metaModels {
                $formatMetaMessageSplat = @{
                    Role    = 'User'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.\n'
                    ModelID = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat
                $context = Get-ModelContext -ModelID $_
                $context | Should -Not -BeNullOrEmpty
            } #it

            It 'should not populate context if NoContextPersist is set to true' -ForEach $metaModels {
                $formatMetaMessageSplat = @{
                    Role             = 'User'
                    Message          = 'I am not a'
                    ModelID          = $_
                    NoContextPersist = $true
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $context = Get-ModelContext -ModelID $_
                Write-Verbose -Message ('Context Count: {0}' -f $context.Count)
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-MetaTextMessage
} #inModule
