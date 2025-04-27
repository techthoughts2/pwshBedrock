BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    $script:supportedModels = @(
        'mistral.mistral-large-2402-v1:0',
        'mistral.mistral-small-2402-v1:0',
        'mistral.mistral-large-2407-v1:0',
        'mistral.pixtral-large-2502-v1:0'
    )
    # $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
}

InModuleScope 'pwshBedrock' {
    Describe 'Mistral AI Chat Integration Tests' -Tag Integration {
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
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message for <_> when provided a standard message' -ForEach $supportedModels {
                $ModelID = $_
                $invokeMistralAIChatModelSplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = $ModelID
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-east-1'
                    Verbose    = $false
                }
                $eval = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object for <_> when provided a standard message' -ForEach $supportedModels {
                $ModelID = $_
                $invokeMistralAIChatModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
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

        Context 'Vision Message' {
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a vision message for <_.ModelID>' -Foreach ($script:mistralAIModelInfo | Where-Object { $_.Vision -eq $true }) {
                # Write-Verbose ('$PSScriptRoot is {0}' -f $PSScriptRoot)
                # Write-Verbose ('$mediaFile is {0}' -f $fullMediaFilePath)
                $ModelID = $_.ModelID
                $invokeMistralAIChatModelSplat = @{
                    Message          = 'Describe the photo in one word'
                    ModelID          = $ModelID
                    MediaPath        = $fullMediaFilePath
                    MaxTokens        = 100
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    SystemPrompt     = 'You are a man of few words with great wit.'
                    Temperature      = 1
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

        } #context_vision_message

    } #describe
} #inModule
