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
    $deepseekModels = @('deepseek.r1-v1:0')
    Describe 'Format-DeepSeekTextMessage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            # BeforeEach {

            # } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-DeepSeekTextMessage -Role 'User' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-DeepSeekTextMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'deepseek.r1-v1:0' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {
            BeforeEach {
                Reset-ModelContext -AllModels -Force
                $userPrompt = 'What is the meaning of life?'
                $systemPrompt = 'You are a helpful assistant.'
                $expectedInitialFormat = @'
<｜begin_of_sentence｜>You are a helpful assistant.<｜User｜>What is the meaning of life?
'@
                $expectedAssistantResponse = @'
<｜begin_of_sentence｜>You are a helpful assistant.<｜User｜>What is the meaning of life?<｜Assistant｜>42
'@
                $expectedFollowupQuestion = @'
<｜begin_of_sentence｜>You are a helpful assistant.<｜User｜>What is the meaning of life?<｜Assistant｜>42<｜User｜>Why is it 42?
'@
                $expectedNoSystemPrompt = @'
<｜begin_of_sentence｜><｜User｜>What is the meaning of life?
'@

                $normalizedExpectedInitialFormat = $expectedInitialFormat -replace "`r`n", "`n"
                $normalizedExpectedAssistantResponse = $expectedAssistantResponse -replace "`r`n", "`n"
                $normalizedExpectedFollowupQuestion = $expectedFollowupQuestion -replace "`r`n", "`n"
                $normalizedExpectedNoSystemPrompt = $expectedNoSystemPrompt -replace "`r`n", "`n"
            } #beforeEach
            It 'should return a properly formatted initial message with system prompt' {
                $formatDeepSeekMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = 'deepseek.r1-v1:0'
                }
                $result = Format-DeepSeekTextMessage @formatDeepSeekMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = ($result -replace "`r`n", "`n").TrimEnd()
                $normalizedResult | Should -Be $normalizedExpectedInitialFormat.TrimEnd()
            } #it

            It 'should return a properly formatted initial message without system prompt' {
                # Reset context first to ensure clean state
                Reset-ModelContext -ModelID 'deepseek.r1-v1:0' -Force

                $formatDeepSeekMessageSplat = @{
                    Role    = 'User'
                    Message = $userPrompt
                    ModelID = 'deepseek.r1-v1:0'
                }
                $result = Format-DeepSeekTextMessage @formatDeepSeekMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = ($result -replace "`r`n", "`n").TrimEnd()
                $normalizedResult | Should -Be $normalizedExpectedNoSystemPrompt.TrimEnd()
            } #it

            It 'should properly add an assistant response to the context' {
                # Reset context first to ensure clean state
                Reset-ModelContext -ModelID 'deepseek.r1-v1:0' -Force

                $formatDeepSeekMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = 'deepseek.r1-v1:0'
                }
                Format-DeepSeekTextMessage @formatDeepSeekMessageSplat | Out-Null
                $formatDeepSeekMessageSplat = @{
                    Role    = 'Assistant'
                    Message = '42'
                    ModelID = 'deepseek.r1-v1:0'
                }
                $result = Format-DeepSeekTextMessage @formatDeepSeekMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = ($result -replace "`r`n", "`n").TrimEnd()
                $normalizedResult | Should -Be $normalizedExpectedAssistantResponse.TrimEnd()
            } #it

            It 'should handle a multi-message conversation' {
                # Reset context first to ensure clean state
                Reset-ModelContext -ModelID 'deepseek.r1-v1:0' -Force

                $formatDeepSeekMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = 'deepseek.r1-v1:0'
                }
                Format-DeepSeekTextMessage @formatDeepSeekMessageSplat | Out-Null
                $formatDeepSeekMessageSplat = @{
                    Role    = 'Assistant'
                    Message = '42'
                    ModelID = 'deepseek.r1-v1:0'
                }
                Format-DeepSeekTextMessage @formatDeepSeekMessageSplat | Out-Null
                $formatDeepSeekMessageSplat = @{
                    Role    = 'User'
                    Message = 'Why is it 42?'
                    ModelID = 'deepseek.r1-v1:0'
                }
                $result = Format-DeepSeekTextMessage @formatDeepSeekMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = ($result -replace "`r`n", "`n").TrimEnd()
                $normalizedResult | Should -Be $normalizedExpectedFollowupQuestion.TrimEnd()
            } #it

            It 'should populate context for the <_> model' -ForEach $deepseekModels {
                $formatDeepSeekMessageSplat = @{
                    Role    = 'User'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.'
                    ModelID = $_
                }
                Format-DeepSeekTextMessage @formatDeepSeekMessageSplat
                $context = Get-ModelContext -ModelID $_
                $context | Should -Not -BeNullOrEmpty
            } #it

            It 'should not populate context if NoContextPersist is set to true for the <_> model' -ForEach $deepseekModels {
                # Reset context first to ensure clean state
                Reset-ModelContext -ModelID $_ -Force

                $formatDeepSeekMessageSplat = @{
                    Role             = 'User'
                    Message          = 'I am not a merry man!'
                    ModelID          = $_
                    NoContextPersist = $true
                }
                $result = Format-DeepSeekTextMessage @formatDeepSeekMessageSplat
                $result | Should -BeOfType 'System.String'
                $context = Get-ModelContext -ModelID $_
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-DeepSeekTextMessage
} #inModule
