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
    Describe 'Luma AI Integration Tests' -Tag Integration {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'
        } #beforeAll

        Context 'Video Prompt' {
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

            It 'should return an invocation arn when provided a video prompt for <_.ModelId>' -Foreach $script:lumaModelInfo {
                # $ModelID = $_.ModelId
                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'A cat playing with a ball'
                    S3OutputURI       =  's3://bedrockvideotestbucket/'
                    Credential        = $Credential
                    Region            = 'us-west-2'
                    Verbose    = $false
                }
                $eval = Invoke-LumaAIModel @invokeLumaAIModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval.InvocationArn | Should -BeLike 'arn:aws:bedrock*'
                $eval.Message | Should -BeOfType [System.String]
                Write-Verbose -Message $eval
            } #it

        } #context_standard_message_luma_model

    } #describe
} #inModule
