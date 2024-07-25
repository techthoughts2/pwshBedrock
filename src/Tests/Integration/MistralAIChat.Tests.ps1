#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
#-------------------------------------------------------------------------
#if the module is already in memory, remove it
Get-Module $ModuleName | Remove-Module -Force
$PathToManifest = [System.IO.Path]::Combine('..', '..', 'Artifacts', "$ModuleName.psd1")
#-------------------------------------------------------------------------
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
# $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')

InModuleScope 'pwshBedrock' {
    Describe 'Mistral AI Chat Integration Tests' -Tag Integration {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'
        } #beforeAll

        Context 'Standard Message' {

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

            It 'should return a message when provided a standard message' {
                $invokeMistralAIChatModelSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = 'mistral.mistral-large-2402-v1:0'
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-west-2'
                    Verbose    = $false
                }
                $eval = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message' {
                $invokeMistralAIChatModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = 'mistral.mistral-large-2402-v1:0'
                    SystemPrompt     = 'You are a model of very few words.'
                    MaxTokens        = 30
                    Temperature      = 0.5
                    TopP             = 0.9
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval.choices.index | Should -Not -BeNullOrEmpty
                $eval.choices.message.role | Should -Not -BeNullOrEmpty
                $eval.choices.message.content | Should -Not -BeNullOrEmpty
                $eval.choices.stop_reason | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.choices.message.content
            } #it

        } #context_standard_message

    } #describe
} #inModule
