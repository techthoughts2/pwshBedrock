BeforeDiscovery {
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
    Describe 'Invoke-AmazonTextModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-express-v1'
                        Context = 'test'
                    }
                )
                $standardMessage = "User: Hello, how are you?`n"
                $customMessage = @'
User: Hello, how are you?
Bot: I am well, thank you for asking.
User: Explain zero-point energy.
'@
                Mock -CommandName Test-AmazonCustomConversation -MockWith { $true }
                Mock -CommandName Format-AmazonTextMessage -MockWith {
                    $standardMessage
                }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "inputTextTokenCount": 13,
    "results": [
        {
            "tokenCount": 40,
            "outputText": "Captain Picard.",
            "completionReason": "FINISH"
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
    "inputTextTokenCount": 13,
    "results": [
        {
            "tokenCount": 40,
            "outputText": "Captain Picard.",
            "completionReason": "FINISH"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAmazonTextModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAmazonTextModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'amazon.titan-text-lite-v1'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
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
                    $invokeAmazonTextModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'amazon.titan-text-express-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-express-v1'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAmazonTextModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'amazon.titan-text-express-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAmazonTextModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'amazon.titan-text-express-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-express-v1'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAmazonTextModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'amazon.titan-text-express-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
            } #it

            It 'should remove last message context if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-express-v1'
                        Context = $customMessage
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAmazonTextModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'amazon.titan-text-express-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a custom conversation is provided that does not pass validation' {
                Mock -CommandName Test-AmazonCustomConversation -MockWith { $false }
                {
                    $invokeAmazonTextModelSplat = @{
                        ModelID            = 'amazon.titan-text-express-v1'
                        CustomConversation = $customMessage
                        AccessKey          = 'ak'
                        SecretKey          = 'sk'
                        Region             = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "inputTextTokenCount": 13,
    "results": [
        {
            "tokenCount": 40,
            "outputText": "",
            "completionReason": "FINISH"
        }
    ]
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeAmazonTextModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'amazon.titan-text-express-v1'
                        MaxTokens = 100
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardMessage = "User: Hello, how are you?`n"
                Mock -CommandName Test-AmazonCustomConversation -MockWith { $true }
                Mock -CommandName Format-AmazonTextMessage -MockWith {
                    $standardMessage
                }
                $customMessage = @'
User: Hello, how are you?
Bot: I am well, thank you for asking.
User: Explain zero-point energy.
'@
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "inputTextTokenCount": 13,
    "results": [
        {
            "tokenCount": 40,
            "outputText": "Captain Picard",
            "completionReason": "FINISH"
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
    "inputTextTokenCount": 13,
    "results": [
        {
            "tokenCount": 40,
            "outputText": "Captain Picard.",
            "completionReason": "FINISH"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeAmazonTextModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'amazon.titan-tg1-large'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeAmazonTextModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'amazon.titan-text-express-v1'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.inputTextTokenCount | Should -BeExactly '13'
                $result.results.tokenCount | Should -BeExactly '40'
                $result.results.outputText | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Shaka, when the walls fell.'
                    ModelID          = 'amazon.titan-text-express-v1'
                    NoContextPersist = $true
                    Temperature      = 0.5
                    TopP             = 0.9
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands' {
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Bonjour, mon Capitaine!'
                    ModelID          = 'amazon.titan-text-express-v1'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                Should -Invoke Format-AmazonTextMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a custom conversation is provided' {
                $invokeAmazonTextModelSplat = @{
                    CustomConversation = $customMessage
                    ModelID            = 'amazon.titan-text-express-v1'
                    AccessKey          = 'ak'
                    SecretKey          = 'sk'
                    Region             = 'us-west-2'
                }
                $result = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                Should -Invoke Test-AmazonCustomConversation -Exactly 1 -Scope It
                Should -Invoke Format-AmazonTextMessage -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                $result | Should -Not -BeNullOrEmpty
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'amazon.titan-text-express-v1'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeAmazonTextModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'amazon.titan-text-express-v1'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-AmazonTextModel @invokeAmazonTextModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'amazon.titan-text-express-v1'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeAmazonTextModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'amazon.titan-text-express-v1'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-AmazonTextModel @invokeAmazonTextModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call Format-AmazonTextMessage with the expected parameters when NoContextPersist is specified' {
                Mock -CommandName Format-AmazonTextMessage {
                    $NoContextPersist | Should -BeExactly $true
                } -Verifiable
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Fascinating.'
                    ModelID          = 'amazon.titan-text-express-v1'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                Invoke-AmazonTextModel @invokeAmazonTextModelSplat | Should -InvokeVerifiable
            } #it

            It 'Should not format the message initially if PromptOnly is provided' {
                Mock -CommandName Format-AmazonTextMessage { }
                $invokeAmazonTextModelSplat = @{
                    Message    = 'Fascinating.'
                    ModelID    = 'amazon.titan-text-express-v1'
                    MaxTokens  = 4096
                    PromptOnly = $true
                    AccessKey  = 'ak'
                    SecretKey  = 'sk'
                    Region     = 'us-west-2'
                }
                Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                Should -Invoke Format-AmazonTextMessage -Exactly 1 -Scope It
            } #it

        } #context_Success

    } #describe_Invoke-AmazonTextModel
} #inModule
