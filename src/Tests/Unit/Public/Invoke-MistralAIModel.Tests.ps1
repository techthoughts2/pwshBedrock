#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Invoke-MistralAIModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = 'test'
                    }
                )
                $standardMessage = @'
<s>[INST] Who is the best captain in Star Trek? [/INST]
'@
                Mock -CommandName Format-MistralAITextMessage -MockWith {
                    $standardMessage
                }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "outputs": [
        {
            "text": "Captain Picard.",
            "stop_reason": "stop"
        }
    ]
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
    "outputs": [
        {
            "text": "Captain Picard.",
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeMistralAIModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeMistralAIModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'mistral.mixtral-8x7b-instruct-v0:1'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
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
                    $invokeMistralAIModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeMistralAIModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeMistralAIModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeMistralAIModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
            } #it

            It 'should remove last message context if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = $standardMessage
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeMistralAIModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "outputs": [
        {
            "text": "",
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeMistralAIModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                        MaxTokens = 100
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIModel @invokeMistralAIModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = 'test'
                    }
                )
                $standardMessage = @'
<s>[INST] Who is the best captain in Star Trek? [/INST]
'@
                Mock -CommandName Format-MistralAITextMessage -MockWith {
                    $standardMessage
                }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "outputs": [
        {
            "text": "Captain Picard.",
            "stop_reason": "stop"
        }
    ]
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
    "outputs": [
        {
            "text": "Captain Picard.",
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeMistralAIModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'mistral.mistral-large-2402-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-MistralAIModel @invokeMistralAIModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly "Captain Picard."
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeMistralAIModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'mistral.mixtral-8x7b-instruct-v0:1'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MistralAIModel @invokeMistralAIModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.outputs.text | Should -BeExactly 'Captain Picard.'
                $result.outputs.stop_reason | Should -BeExactly 'stop'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeMistralAIModelSplat = @{
                    Message          = 'Shaka, when the walls fell.'
                    ModelID          = 'mistral.mixtral-8x7b-instruct-v0:1'
                    NoContextPersist = $true
                    MaxTokens        = 100
                    StopSequences    = @('stop')
                    Temperature      = 0.5
                    TopP             = 0.9
                    TopK             = 40
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MistralAIModel @invokeMistralAIModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly "Captain Picard."
            } #it

            It 'should run all expected subcommands' {
                $invokeMistralAIModelSplat = @{
                    Message          = 'Bonjour, mon Capitaine!'
                    ModelID          = 'mistral.mixtral-8x7b-instruct-v0:1'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MistralAIModel @invokeMistralAIModelSplat
                Should -Invoke Format-MistralAITextMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'mistral.mixtral-8x7b-instruct-v0:1'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeMistralAIModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'mistral.mixtral-8x7b-instruct-v0:1'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-MistralAIModel @invokeMistralAIModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'mistral.mixtral-8x7b-instruct-v0:1'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeMistralAIModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'mistral.mixtral-8x7b-instruct-v0:1'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-MistralAIModel @invokeMistralAIModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call Format-MistralAITextMessage with the expected parameters when NoContextPersist is specified' {
                Mock -CommandName Format-MistralAITextMessage {
                    $NoContextPersist | Should -BeExactly $true
                } -Verifiable
                $invokeMistralAIModelSplat = @{
                    Message          = 'Fascinating.'
                    ModelID          = 'mistral.mixtral-8x7b-instruct-v0:1'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                Invoke-MistralAIModel @invokeMistralAIModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-MistralAIModel
} #inModule
