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
# $awsCredential = $c
InModuleScope 'pwshBedrock' {
    Describe 'Anthropic Integration Tests' -Tag Integration {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'

            Set-Location -Path $PSScriptRoot
            $assetPath = [System.IO.Path]::Combine($PSScriptRoot, '..', 'assets')
            $mediaFile = [System.IO.Path]::Combine($assetPath, 'tanagra.jpg')
            $fullMediaFilePath = [System.IO.Path]::GetFullPath($mediaFile)
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
                Start-Sleep -Milliseconds 1500
            }

            It 'should return a message when provided a standard message for <_.ModelID>' -Foreach ($script:anthropicModelInfo | Where-Object { $_.ModelID -ne 'anthropic.claude-3-opus-20240229-v1:0' }) {
                $ModelID = $_.ModelID
                $invokeAnthropicModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AnthropicModel @invokeAnthropicModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelID>' -Foreach ($script:anthropicModelInfo | Where-Object { $_.ModelID -ne 'anthropic.claude-3-opus-20240229-v1:0' }) {
                $ModelID = $_.ModelID
                $invokeAnthropicModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-AnthropicModel @invokeAnthropicModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.Id | Should -Not -BeNullOrEmpty
                $eval.type | Should -Not -BeNullOrEmpty
                $eval.role | Should -Not -BeNullOrEmpty
                $eval.model | Should -Not -BeNullOrEmpty
                $eval.content | Should -Not -BeNullOrEmpty
                $eval.content.text | Should -Not -BeNullOrEmpty
                $eval.content.type | Should -Not -BeNullOrEmpty
                $eval.'stop_reason' | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.content.text
            } #it

        } #context_standard_message

        Context 'Vision Message' {
            AfterEach {
                Start-Sleep -Milliseconds 1500
            }

            It 'should return a message when provided a vision message for <_.ModelID>' -Foreach ($script:anthropicModelInfo | Where-Object { $_.Vision -eq $true -and $_.ModelID -ne 'anthropic.claude-3-opus-20240229-v1:0' }) {
                # Write-Verbose ('$PSScriptRoot is {0}' -f $PSScriptRoot)
                # Write-Verbose ('$mediaFile is {0}' -f $fullMediaFilePath)
                $ModelID = $_.ModelID
                $invokeAnthropicModelSplat = @{
                    Message          = 'Describe the photo in one word'
                    ModelID          = $ModelID
                    MediaPath        = $fullMediaFilePath
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    SystemPrompt     = 'You are a man of few words with great wit.'
                    Temperature      = 1
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AnthropicModel @invokeAnthropicModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

        } #context_vision_message

        Context 'Custom Message' {
            AfterEach {
                Start-Sleep -Milliseconds 1500
            }

            It 'should return a message when provided a custom message for <_.ModelID>' -Foreach ($script:anthropicModelInfo | Where-Object { $_.ModelID -ne 'anthropic.claude-3-opus-20240229-v1:0' }) {
                $ModelID = $_.ModelID
                $customMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Once upon a time...'
                        }
                    )
                }
                [PSCustomObject]@{
                    role    = 'assistant'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                            text = "I was falling in love"
                        }
                    )
                }
                [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                            text = "But now I'm only falling apart"
                        }
                    )
                }
                $invokeAnthropicModelSplat = @{
                    CustomConversation = $customMessage
                    ModelID            = $ModelID
                    MaxTokens          = 10
                    Credential         = $awsCredential
                    Region             = 'us-west-2'
                    NoContextPersist   = $true
                    Verbose            = $false
                }
                $eval = Invoke-AnthropicModel @invokeAnthropicModelSplat
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
