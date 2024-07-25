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
    Describe 'Meta Integration Tests' -Tag Integration {
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

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach $script:metaModelInfo {
                $ModelID = $_.ModelId
                $invokeMetaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 20
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-MetaModel @invokeMetaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach $script:metaModelInfo {
                $ModelID = $_.ModelId
                $invokeMetaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 50
                    SystemPrompt     = 'You are a model of very few words'
                    Temperature      = 0.5
                    TopP             = 0.9
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-MetaModel @invokeMetaModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.prompt_token_count | Should -Not -BeNullOrEmpty
                $eval.generation_token_count | Should -Not -BeNullOrEmpty
                $eval.generation | Should -Not -BeNullOrEmpty
                $eval.stop_reason | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.generation
            } #it

        } #context_standard_message

    } #describe
} #inModule
