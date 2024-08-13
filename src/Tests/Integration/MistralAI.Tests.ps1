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
    Describe 'Mistral AI Integration Tests' -Tag Integration {
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

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach $script:mistralAIModelInfo {
                $ModelID = $_.ModelId
                $invokeMetaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-MistralAIModel @invokeMetaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach $script:mistralAIModelInfo {
                $ModelID = $_.ModelId
                $invokeMetaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Temperature      = 0.5
                    TopP             = 0.9
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    NoContextPersist = $true
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-MistralAIModel @invokeMetaModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.outputs.text | Should -Not -BeNullOrEmpty
                $eval.outputs.stop_reason | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.outputs.text
            } #it

        } #context_standard_message

    } #describe
} #inModule
