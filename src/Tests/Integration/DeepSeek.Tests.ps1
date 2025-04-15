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
    Describe 'DeepSeekIntegration Tests' -Tag Integration {
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

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach $script:deepseekModelInfo {
                $ModelID = $_.ModelId
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 1000
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-DeepSeekModel @invokeAmazonTextModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach $script:deepseekModelInfo {
                $ModelID = $_.ModelId
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 1000
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-DeepSeekModel @invokeAmazonTextModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.Text | Should -Not -BeNullOrEmpty
                $eval.Think | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.Text
            } #it

        } #context_standard_message

        Context 'Custom Message' {
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a custom message for <_.ModelId>' -Foreach $script:deepseekModelInfo {
                $ModelID = $_.ModelId
                $customConversation = @'
<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>
'@
                $invokeAmazonTextModelSplat = @{
                    CustomConversation = $customConversation
                    ModelID            = $ModelID
                    Credential         = $awsCredential
                    Region             = 'us-west-2'
                    Verbose            = $false
                }
                $eval = Invoke-DeepSeekModel @invokeAmazonTextModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Output $eval
            } #it

            AfterAll {
                $getModelTallySplat = @{
                    JustTotalCost = $true
                    Verbose       = $false
                }
                $totalCost = Get-ModelTally @getModelTallySplat
                Write-Verbose -Message "Total cost for all models: $totalCost"
            }

        } #context_custom_message

    } #describe
} #inModule
