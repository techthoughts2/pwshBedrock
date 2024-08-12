BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Invoke-CohereCommandModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "generations": [
        {
            "finish_reason": "COMPLETE",
            "id": "c28eadc4-966d-4157-a9b5-58ab921d0f92",
            "text": "Captain Picard."
        }
    ],
    "id": "1658248f-eb86-4723-9c23-be47bdcbbcb3",
    "prompt": "Hi there, how are you?"
}
'@

                # Convert JSON payload to byte array
                $byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

                # Create a MemoryStream and write the byte array into it
                $memoryStream = [System.IO.MemoryStream]::new()
                $memoryStream.Write($byteArray, 0, $byteArray.Length)

                # Reset the position of the MemoryStream to the beginning
                $memoryStream.Position = 0

                # Assign the MemoryStream to the response body
                $response.Body = $memoryStream
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    $response
                } #endMock

                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "generations": [
        {
            "finish_reason": "COMPLETE",
            "id": "c28eadc4-966d-4157-a9b5-58ab921d0f92",
            "text": "Captain Picard."
        }
    ],
    "id": "1658248f-eb86-4723-9c23-be47bdcbbcb3",
    "prompt": "Hi there, how are you?"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeCohereCommandModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeCohereCommandModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'cohere.command-text-v14'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    [System.Exception]$exception = 'You don''t have access to the model with the specified model ID.'
                    [System.String]$errorId = 'Amazon.BedrockRuntime.Model.AccessDeniedException, Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
                    [System.Object]$target = 'Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID, $errorCategory, $target)
                    [System.Management.Automation.ErrorDetails]$errorDetails = ''
                    $errorRecord.ErrorDetails = $errorDetails
                    throw $errorRecord
                }
                {
                    $invokeCohereCommandModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'cohere.command-light-text-v14'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-light-text-v14'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeCohereCommandModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'cohere.command-light-text-v14'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeCohereCommandModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'cohere.command-light-text-v14'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-light-text-v14'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeCohereCommandModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'cohere.command-light-text-v14'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardMessage = "User: Hello, how are you?`n"

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "generations": [
        {
            "finish_reason": "COMPLETE",
            "id": "c28eadc4-966d-4157-a9b5-58ab921d0f92",
            "text": "Captain Picard."
        }
    ],
    "id": "1658248f-eb86-4723-9c23-be47bdcbbcb3",
    "prompt": "Hi there, how are you?"
}
'@

                # Convert JSON payload to byte array
                $byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

                # Create a MemoryStream and write the byte array into it
                $memoryStream = [System.IO.MemoryStream]::new()
                $memoryStream.Write($byteArray, 0, $byteArray.Length)

                # Reset the position of the MemoryStream to the beginning
                $memoryStream.Position = 0

                # Assign the MemoryStream to the response body
                $response.Body = $memoryStream
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    $response
                } #endMock

                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "generations": [
        {
            "finish_reason": "COMPLETE",
            "id": "c28eadc4-966d-4157-a9b5-58ab921d0f92",
            "text": "Captain Picard."
        }
    ],
    "id": "1658248f-eb86-4723-9c23-be47bdcbbcb3",
    "prompt": "Hi there, how are you?"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeCohereCommandModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'cohere.command-text-v14'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeCohereCommandModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'cohere.command-light-text-v14'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.id | Should -BeExactly '1658248f-eb86-4723-9c23-be47bdcbbcb3'
                $result.prompt | Should -BeExactly 'Hi there, how are you?'
                $result.generations.text | Should -BeExactly "Captain Picard."
                $result.generations.'finish_reason' | Should -BeExactly 'COMPLETE'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeCohereCommandModelSplat = @{
                    Message           = 'Shaka, when the walls fell.'
                    ModelID           = 'cohere.command-light-text-v14'
                    Temperature       = 0.5
                    TopP              = 0.9
                    TopK              = 50
                    MaxTokens         = 4096
                    StopSequences     = @('clouds')
                    ReturnLikelihoods = 'ALL'
                    Generations       = 2
                    Truncate          = 'END'
                    AccessKey         = 'ak'
                    SecretKey         = 'sk'
                    Region            = 'us-west-2'
                }
                $result = Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands' {
                $invokeCohereCommandModelSplat = @{
                    Message   = 'Bonjour, mon Capitaine!'
                    ModelID   = 'cohere.command-light-text-v14'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-CohereCommandModel @invokeCohereCommandModelSplat
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'cohere.command-light-text-v14'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeCohereCommandModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'cohere.command-light-text-v14'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-CohereCommandModel @invokeCohereCommandModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'cohere.command-light-text-v14'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeCohereCommandModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'cohere.command-light-text-v14'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-CohereCommandModel @invokeCohereCommandModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-CohereCommandModel
} #inModule
