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
    Describe 'Cohere Command Integration Tests' -Tag Integration {
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

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach ($script:cohereModelInfo | Where-Object { $_.ModelId -eq 'cohere.command-text-v14' -or $_.ModelId -eq 'cohere.command-light-text-v14' }) {
                $ModelID = $_.ModelId
                $invokeCohereCommandSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = $ModelID
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-west-2'
                    Verbose    = $false
                }
                $eval = Invoke-CohereCommandModel @invokeCohereCommandSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach ($script:cohereModelInfo | Where-Object { $_.ModelId -eq 'cohere.command-text-v14' -or $_.ModelId -eq 'cohere.command-light-text-v14' }) {
                $ModelID = $_.ModelId
                $invokeCohereCommandSplat = @{
                    Message           = 'Return the number 1 as a string'
                    ModelID           = $ModelID
                    Temperature       = 0.5
                    TopP              = 0.9
                    TopK              = 50
                    MaxTokens         = 10
                    StopSequences     = @('clouds')
                    ReturnLikelihoods = 'ALL'
                    Generations       = 1
                    Truncate          = 'END'
                    Credential        = $awsCredential
                    Region            = 'us-west-2'
                    ReturnFullObject  = $true
                    Verbose           = $false
                }
                $eval = Invoke-CohereCommandModel @invokeCohereCommandSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.id | Should -Not -BeNullOrEmpty
                $eval.prompt | Should -Not -BeNullOrEmpty
                $eval.generations.text | Should -Not -BeNullOrEmpty
                $eval.generations.'finish_reason' | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.generations.text
            } #it

        } #context_standard_message

    } #describe
} #inModule
