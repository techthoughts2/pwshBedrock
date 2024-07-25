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
    Describe 'Cohere Command R Integration Tests' -Tag Integration {
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
                Start-Sleep -Milliseconds 500
            }

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach ($script:cohereModelInfo | Where-Object { $_.ModelId -eq 'cohere.command-r-v1:0' -or $_.ModelId -eq 'cohere.command-r-plus-v1:0' }) {
                $ModelID = $_.ModelId
                $invokeCohereCommandSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = $ModelID
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-west-2'
                    Verbose    = $false
                }
                $eval = Invoke-CohereCommandRModel @invokeCohereCommandSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach ($script:cohereModelInfo | Where-Object { $_.ModelId -eq 'cohere.command-r-v1:0' -or $_.ModelId -eq 'cohere.command-r-plus-v1:0' }) {
                $ModelID = $_.ModelId
                $documents = @(
                    [PSCustomObject]@{
                        title   = 'A history of numbers.'
                        snippet = 'The number 1 as a string is "one".'
                    }
                )
                $invokeCohereCommandSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    Documents        = $documents
                    Preamble         = 'You are a person of very few words.'
                    MaxTokens        = 20
                    Temperature      = 0.5
                    TopP             = 0.9
                    TopK             = 50
                    # FrequencyPenalty = 0.5
                    # PresencePenalty  = 0.5
                    StopSequences    = @('Kirk')
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-CohereCommandRModel @invokeCohereCommandSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.response_id | Should -Not -BeNullOrEmpty
                $eval.finish_reason | Should -Not -BeNullOrEmpty
                $eval.text | Should -Not -BeNullOrEmpty
                $eval.chat_history | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.text
            } #it

        } #context_standard_message

    } #describe
} #inModule
