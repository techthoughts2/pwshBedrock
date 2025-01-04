BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    # $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
}
# $awsCredential = $c
InModuleScope 'pwshBedrock' {
    Describe 'Amazon Nova Integration Tests' -Tag Integration {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'

            Set-Location -Path $PSScriptRoot
            $assetPath = [System.IO.Path]::Combine($PSScriptRoot, '..', 'assets')
            $imageFile = [System.IO.Path]::Combine($assetPath, 'tanagra.jpg')
            $fullImageFilePath = [System.IO.Path]::GetFullPath($imageFile)
            $videoFile = [System.IO.Path]::Combine($assetPath, 'super_boy.mp4')
            $fullVideoFilePath = [System.IO.Path]::GetFullPath($videoFile)
            $documentFile = [System.IO.Path]::Combine($assetPath, 'ds9.docx')
            $fullDocumentFilePath = [System.IO.Path]::GetFullPath($documentFile)
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

            It 'should return a message when provided a standard message for <_.ModelID>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $ModelID = $_.ModelID
                $invokeAmazonNovaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonNovaTextModel @invokeAmazonNovaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelID>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $ModelID = $_.ModelID
                $invokeAmazonNovaModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    NoContextPersist = $true
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonNovaTextModel @invokeAmazonNovaModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.usage | Should -Not -BeNullOrEmpty
                $eval.stopReason | Should -Not -BeNullOrEmpty
                $eval.output | Should -Not -BeNullOrEmpty
                $eval.output.message | Should -Not -BeNullOrEmpty
                $eval.output.message.content | Should -Not -BeNullOrEmpty
                $eval.output.message.content.text | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.output.message.content.text
            } #it

        } #context_standard_message

        Context 'Vision Message' {
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a image vision message for <_.ModelID>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Vision -eq $true }) {
                # Write-Verbose ('$PSScriptRoot is {0}' -f $PSScriptRoot)
                # Write-Verbose ('$imageFile is {0}' -f $fullImageFilePath)
                $ModelID = $_.ModelID
                $invokeAmazonNovaModelSplat = @{
                    Message          = 'Describe the photo in one word'
                    ModelID          = $ModelID
                    MediaPath        = $fullImageFilePath
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    SystemPrompt     = 'You are a man of few words with great wit.'
                    Temperature      = 1
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonNovaTextModel @invokeAmazonNovaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return a message when provided a video vision message for <_.ModelID>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Vision -eq $true }) {
                $ModelID = $_.ModelID
                $invokeAmazonNovaModelSplat = @{
                    Message          = 'Describe the video in one word'
                    ModelID          = $ModelID
                    MediaPath        = $fullVideoFilePath
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    SystemPrompt     = 'You are a man of few words with great wit.'
                    Temperature      = 1
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonNovaTextModel @invokeAmazonNovaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return a message when provided a document vision message for <_.ModelID>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Vision -eq $true }) {
                $ModelID = $_.ModelID
                $invokeAmazonNovaModelSplat = @{
                    Message          = 'Describe the document in one sentence'
                    ModelID          = $ModelID
                    MediaPath        = $fullDocumentFilePath
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-east-1'
                    SystemPrompt     = 'You are a man of few words with great wit.'
                    Temperature      = 1
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonNovaTextModel @invokeAmazonNovaModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

        } #context_vision_message

        Context 'Custom Message' {
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a custom message for <_.ModelID>' -ForEach ($script:amazonModelInfo | Where-Object { $_.ModelName -like '*nova*' -and $_.Text -eq $true }) {
                $ModelID = $_.ModelID
                $customMessage = @(
                    [PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = 'Explain zero-point energy.'
                            }
                        )
                    }
                    [PSCustomObject]@{
                        role    = 'assistant'
                        content = @(
                            [PSCustomObject]@{
                                text = 'It is when someone in basketball is having a really bad game.'
                            }
                        )
                    }
                    [PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = 'No, as it relates to physics.'
                            }
                        )
                    }
                )
                $invokeAmazonNovaModelSplat = @{
                    CustomConversation = $customMessage
                    ModelID            = $ModelID
                    MaxTokens          = 10
                    Credential         = $awsCredential
                    Region             = 'us-east-1'
                    NoContextPersist   = $true
                    Verbose            = $false
                }
                $eval = Invoke-AmazonNovaTextModel @invokeAmazonNovaModelSplat
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
