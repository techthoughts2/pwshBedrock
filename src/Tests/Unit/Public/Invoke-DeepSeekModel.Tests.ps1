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
    Describe 'Invoke-DeepSeekModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'deepseek.r1-v1:0'
                        Context = 'test'
                    }
                )
                $standardMessage = "<｜begin_of_sentence｜><｜User｜>Hello, how are you?<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>"
                $customMessage = "<｜begin_of_sentence｜><｜User｜>What is quantum computing?<｜Assistant｜>Quantum computing is a type of computing that uses quantum bits or qubits instead of classical bits. This allows quantum computers to perform certain calculations much faster than classical computers.<｜end_of_sentence｜><｜User｜>Explain quantum entanglement.<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>"

                Mock -CommandName Test-DeepSeekCustomConversation -MockWith { $true }
                Mock -CommandName Format-DeepSeekTextMessage -MockWith {
                    $standardMessage
                }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "choices": [
        {
            "text": "<think>\nOkay, the user greeted me with \"Hi there, how are you?\" I need to respond politely. Since I'm an AI, I don't have feelings, but I should acknowledge their greeting and offer help. Let me make sure to keep it friendly and open. Maybe start with a thank you, mention I'm here to help, and prompt them to ask their questions. Keep it concise and welcoming.\n</think>\n\nHello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?",
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
    "choices": [
        {
            "text": "<think>\nOkay, the user greeted me with \"Hi there, how are you?\" I need to respond politely. Since I'm an AI, I don't have feelings, but I should acknowledge their greeting and offer help. Let me make sure to keep it friendly and open. Maybe start with a thank you, mention I'm here to help, and prompt them to ask their questions. Keep it concise and welcoming.\n</think>\n\nHello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?",
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
                    $invokeDeepSeekModelSplat = @{
                        Message     = 'Hello there!'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeDeepSeekModelSplat = @{
                        Message     = 'Explain quantum computing in simple terms.'
                        ModelID     = 'deepseek.r1-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
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
                    $invokeDeepSeekModelSplat = @{
                        Message   = 'Can you help me with a coding problem?'
                        ModelID   = 'deepseek.r1-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'deepseek.r1-v1:0'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeDeepSeekModelSplat = @{
                        Message   = "How do I implement quicksort in Python?"
                        ModelID   = 'deepseek.r1-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeDeepSeekModelSplat = @{
                        Message   = "What's the best way to implement a binary search tree?"
                        ModelID   = 'deepseek.r1-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'deepseek.r1-v1:0'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeDeepSeekModelSplat = @{
                        Message   = 'Explain the concept of recursion.'
                        ModelID   = 'deepseek.r1-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
            } #it

            It 'should remove last message context if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'deepseek.r1-v1:0'
                        Context = $customMessage
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeDeepSeekModelSplat = @{
                        Message   = 'Write a function to calculate Fibonacci numbers.'
                        ModelID   = 'deepseek.r1-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a custom conversation is provided that does not pass validation' {
                Mock -CommandName Test-DeepSeekCustomConversation -MockWith { $false }
                {
                    $invokeDeepSeekModelSplat = @{
                        ModelID            = 'deepseek.r1-v1:0'
                        CustomConversation = $customMessage
                        AccessKey          = 'ak'
                        SecretKey          = 'sk'
                        Region             = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "results": {
        "outputText": ""
    }
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeDeepSeekModelSplat = @{
                        Message   = 'How do I optimize database queries?'
                        ModelID   = 'deepseek.r1-v1:0'
                        MaxTokens = 100
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardMessage = "<｜begin_of_sentence｜><｜User｜>Hello, how are you?<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>"
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'deepseek.r1-v1:0'
                        Context = $standardMessage
                    }
                )
                Mock -CommandName Test-DeepSeekCustomConversation -MockWith { $true }
                Mock -CommandName Format-DeepSeekTextMessage -MockWith {
                    $standardMessage
                }
                $customMessage = "<｜begin_of_sentence｜><｜User｜>What is quantum computing?<｜Assistant｜>Quantum computing is...<｜end_of_sentence｜><｜User｜>Explain quantum entanglement.<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>"

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "choices": [
        {
            "text": "<think>\nI am thinking\n</think>\n\nHello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?",
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
    "choices": [
        {
            "text": "<think>\nI am thinking.\n</think>\n\nHello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?",
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeDeepSeekModelSplat = @{
                    Message   = "How can I learn about machine learning?"
                    ModelID   = 'deepseek.r1-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly "Hello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?"
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeDeepSeekModelSplat = @{
                    Message          = 'What are the best practices for writing clean code?'
                    ModelID          = 'deepseek.r1-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.Text | Should -Not -BeNullOrEmpty
                $result.Think | Should -Not -BeNullOrEmpty
            } #it

            It 'should extract the thinking section from the response' {
                $invokeDeepSeekModelSplat = @{
                    Message          = 'What are the best practices for writing clean code?'
                    ModelID          = 'deepseek.r1-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                $result.Think | Should -BeOfType [System.String]
                $result.Think | Should -Not -BeNullOrEmpty
                $result.Think | Should -BeLike '*thinking.*'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeDeepSeekModelSplat = @{
                    Message          = 'Explain the principles of functional programming.'
                    ModelID          = 'deepseek.r1-v1:0'
                    NoContextPersist = $true
                    Temperature      = 0.5
                    TopP             = 0.9
                    MaxTokens        = 1000
                    StopSequences    = @('stop')
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly "Hello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?"
            } #it

            It 'should run all expected subcommands' {
                $invokeDeepSeekModelSplat = @{
                    Message          = 'How do I implement a linked list?'
                    ModelID          = 'deepseek.r1-v1:0'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                Should -Invoke Format-DeepSeekTextMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a custom conversation is provided' {
                $invokeDeepSeekModelSplat = @{
                    CustomConversation = $customMessage
                    ModelID            = 'deepseek.r1-v1:0'
                    AccessKey          = 'ak'
                    SecretKey          = 'sk'
                    Region             = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                Should -Invoke Test-DeepSeekCustomConversation -Exactly 1 -Scope It
                Should -Invoke Format-DeepSeekTextMessage -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                $result | Should -Not -BeNullOrEmpty
            } #it

            It "should remove ``<｜end_of_sentence｜>`` tag from response content" {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "choices": [
        {
            "text": "<think>\nI am thinking about this answer.\n</think>\n\nHello! I'm just a virtual assistant<｜end_of_sentence｜>, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?",
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock

                # Enable debug output capture to verify the removal message is logged
                # $DebugPreference = 'Continue'
                $debugOutput = $null
                Mock -CommandName Write-Debug -MockWith {
                    param($Message)
                    $debugOutput = $Message
                } -ParameterFilter { $Message -eq 'Removing <｜end_of_sentence｜> tag from content.' }

                $invokeDeepSeekModelSplat = @{
                    Message   = "How can I learn about cloud computing?"
                    ModelID   = 'deepseek.r1-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -Not -Match '<\｜end_of_sentence\｜>'
                $result | Should -BeExactly "Hello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?"
                Should -Invoke Write-Debug -Exactly 1 -ParameterFilter { $Message -eq 'Removing <｜end_of_sentence｜> tag from content.' }
                # $DebugPreference = 'SilentlyContinue'
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'us.deepseek.r1-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                    return $response
                } -Verifiable
                $invokeDeepSeekModelSplat = @{
                    Message   = 'How do I improve code performance?'
                    ModelID   = 'deepseek.r1-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-DeepSeekModel @invokeDeepSeekModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'us.deepseek.r1-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeDeepSeekModelSplat = @{
                    Message           = "What are the SOLID principles in software design?"
                    ModelID           = 'deepseek.r1-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-DeepSeekModel @invokeDeepSeekModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call Format-DeepSeekTextMessage with the expected parameters when NoContextPersist is specified' {
                Mock -CommandName Format-DeepSeekTextMessage {
                    $NoContextPersist | Should -BeExactly $true
                } -Verifiable
                $invokeDeepSeekModelSplat = @{
                    Message          = 'Explain design patterns in software engineering.'
                    ModelID          = 'deepseek.r1-v1:0'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                Invoke-DeepSeekModel @invokeDeepSeekModelSplat | Should -InvokeVerifiable
            } #it

            It 'Should not format the message initially if PromptOnly is provided' {
                Mock -CommandName Format-DeepSeekTextMessage { }
                $invokeDeepSeekModelSplat = @{
                    Message    = 'Explain object-oriented programming.'
                    ModelID    = 'deepseek.r1-v1:0'
                    PromptOnly = $true
                    AccessKey  = 'ak'
                    SecretKey  = 'sk'
                    Region     = 'us-west-2'
                }
                Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                Should -Invoke Format-DeepSeekTextMessage -Exactly 1 -Scope It
            } #it

            It 'should handle responses without thinking sections properly' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "choices": [
        {
            "text": "Hello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?",
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock

                $invokeDeepSeekModelSplat = @{
                    Message          = 'What are the best practices for writing clean code?'
                    ModelID          = 'deepseek.r1-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-DeepSeekModel @invokeDeepSeekModelSplat
                $result.Think | Should -BeNullOrEmpty
                $result.Text | Should -BeExactly "Hello! I'm just a virtual assistant, so I don't have feelings, but I'm here and ready to help you with whatever you need. How can I assist you today?"
            } #it

        } #context_Success

    } #describe_Invoke-DeepSeekModel
} #inModule
