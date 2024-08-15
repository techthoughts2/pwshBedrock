BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    # $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
}

InModuleScope 'pwshBedrock' {
    Describe 'AI21 Labs Integration Tests' -Tag Integration {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'
        } #beforeAll

        Context 'Standard Message - Jurassic-2 Model' {

            BeforeEach {
                $resetModelContextSplat = @{
                    AllModels = $true
                    Verbose   = $false
                }
                Reset-ModelContext @resetModelContextSplat
            }
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach ($script:ai21ModelInfo | Where-Object { $_.ModelId -ne 'ai21.jamba-instruct-v1:0' }) {
                $ModelID = $_.ModelId
                $invokeAI21LabsModelSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = $ModelID
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-west-2'
                    Verbose    = $false
                }
                $eval = Invoke-AI21LabsJurassic2Model @invokeAI21LabsModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach ($script:ai21ModelInfo | Where-Object { $_.ModelId -ne 'ai21.jamba-instruct-v1:0' }) {
                $ModelID = $_.ModelId
                $invokeAI21LabsModelSplat = @{
                    Message                             = 'Return the number 1 as a string'
                    ModelID                             = $ModelID
                    Temperature                         = 0.5
                    TopP                                = 0.9
                    MaxTokens                           = 10
                    StopSequences                       = @('clouds')
                    CountPenaltyScale                   = 0.5
                    CountPenaltyApplyToWhiteSpaces      = $true
                    CountPenaltyApplyToPunctuations     = $true
                    CountPenaltyApplyToNumbers          = $true
                    CountPenaltyApplyToStopWords        = $true
                    CountPenaltyApplyToEmojis           = $true
                    PresencePenaltyScale                = 0.5
                    PresencePenaltyApplyToWhiteSpaces   = $true
                    PresencePenaltyApplyToPunctuations  = $true
                    PresencePenaltyApplyToNumbers       = $true
                    PresencePenaltyApplyToStopWords     = $true
                    PresencePenaltyApplyToEmojis        = $true
                    FrequencyPenaltyScale               = 100
                    FrequencyPenaltyApplyToWhiteSpaces  = $true
                    FrequencyPenaltyApplyToPunctuations = $true
                    FrequencyPenaltyApplyToNumbers      = $true
                    FrequencyPenaltyApplyToStopWords    = $true
                    FrequencyPenaltyApplyToEmojis       = $true
                    Credential                          = $awsCredential
                    Region                              = 'us-west-2'
                    ReturnFullObject                    = $true
                    Verbose                             = $false
                }
                $eval = Invoke-AI21LabsJurassic2Model @invokeAI21LabsModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.id | Should -Not -BeNullOrEmpty
                $eval.prompt.text | Should -Not -BeNullOrEmpty
                $eval.completions[0].data.text | Should -Not -BeNullOrEmpty
                $eval.completions[0].finishReason.reason | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.completions[0].data.text
            } #it

        } #context_standard_message_jurassic2_model

        Context 'Standard Message - Jamba Model' {
            BeforeEach {
                $resetModelContextSplat = @{
                    AllModels = $true
                    Verbose   = $false
                }
                Reset-ModelContext @resetModelContextSplat
            }
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a standard message for ai21.jamba-instruct-v1:0' {
                $invokeAI21LabsJambaModelSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = 'ai21.jamba-instruct-v1:0'
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-east-1'
                    Verbose    = $false
                }
                $eval = Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for ai21.jamba-instruct-v1:0' {
                $invokeAI21LabsJambaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    SystemPrompt     = 'You are a model of very few words.'
                    ModelID          = 'ai21.jamba-instruct-v1:0'
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    Verbose          = $false
                }
                $eval = Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval.choices.index | Should -Not -BeNullOrEmpty
                $eval.choices.message.role | Should -Not -BeNullOrEmpty
                $eval.choices.message.content | Should -Not -BeNullOrEmpty
                $eval.choices.finish_reason | Should -Not -BeNullOrEmpty
            }

        } #context_standard_message_jamba_model

    } #describe
} #inModule
