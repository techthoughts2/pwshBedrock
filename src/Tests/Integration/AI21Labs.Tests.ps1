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

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach $script:ai21ModelInfo {
                $ModelID = $_.ModelId
                $invokeAI21LabsJambaModelSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = $ModelID
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

            It 'should return an object when provided a standard message for for <_.ModelId>' -Foreach $script:ai21ModelInfo {
                $ModelID = $_.ModelId
                $invokeAI21LabsJambaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    SystemPrompt     = 'You are a model of very few words.'
                    ModelID          = $ModelID
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
