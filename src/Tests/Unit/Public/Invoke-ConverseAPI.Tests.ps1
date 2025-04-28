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
    Describe 'Invoke-ConverseAPI Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $Global:pwshBedrockModelContext = @(
                [PSCustomObject]@{
                    ModelId = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    Context = ''
                }
            )
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'Converse'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                function Invoke-BDRRConverse {
                }
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'Converse' }
                $context.Context = New-Object System.Collections.Generic.List[object]
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    })
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $systemMessage = 'You are a Star Trek trivia master.'
                $toolsResults = [PSCustomObject]@{
                    ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name    = 'Gristmill River Restaurant & Bar'
                            address = '1287 Gruene Rd, New Braunfels, TX 78130'
                            rating  = '4.5'
                            cuisine = 'American'
                            budget  = '2'
                        }
                    }
                    status    = 'success'
                }
                $standardTools = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                        }
                        cuisine  = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
                        }
                        budget   = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
                        }
                        rating   = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
                        }
                    }
                    required    = @(
                        'location'
                    )
                }
                Mock -CommandName Format-ConverseAPI -MockWith {
                    [Amazon.BedrockRuntime.Model.Message]::new()
                } #endMock
                Mock -CommandName Format-ConverseAPIToolConfig -MockWith {
                    [Amazon.BedrockRuntime.Model.Tool]::new()
                } #endMock
                Mock -CommandName Get-ModelContext -MockWith {
                    $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                    $messageObj.Role = 'user'
                    $content = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                    $content.Text = 'Best StarFleet captain?'
                    $messageObj.Content = $content
                    $obj = [PSCustomObject]@{
                        role    = 'user'
                        content = $messageObj
                    }
                } #endMock
                Mock -CommandName Test-ConverseAPIImage -MockWith { $true }
                Mock -CommandName Test-ConverseAPIDocument -MockWith { $true }
                Mock -CommandName Test-ConverseAPITool -MockWith { $true }
                Mock -CommandName Test-ConverseAPIToolResult -MockWith { $true }

                <#
                AdditionalModelResponseFields : {Document null value}
                Metrics                       : Amazon.BedrockRuntime.Model.ConverseMetrics
                Output                        : Amazon.BedrockRuntime.Model.ConverseOutput
                StopReason                    : end_turn
                Trace                         :
                Usage                         : Amazon.BedrockRuntime.Model.TokenUsage
                #>
                $response = [Amazon.BedrockRuntime.Model.ConverseResponse]::new()
                $response.StopReason = 'end_turn'
                $converseMetrics = [Amazon.BedrockRuntime.Model.ConverseMetrics]::new()
                $converseMetrics.LatencyMs = 100
                $response.Metrics = $converseMetrics
                $tokenUsage = [Amazon.BedrockRuntime.Model.TokenUsage]::new()
                $tokenUsage.InputTokens = 9
                $tokenUsage.OutputTokens = 244
                $tokenUsage.TotalTokens = 253
                $response.Usage = $tokenUsage
                $output = [Amazon.BedrockRuntime.Model.ConverseOutput]::new()
                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'assistant'
                $content = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                $content.Text = 'Captain Picard.'
                $messageObj.Content.Add($content)
                $output.Message = $messageObj
                $response.Output = $output

                Mock -CommandName Invoke-BDRRConverse -MockWith {
                    $response
                } #endMock

                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if multiple parameter sets are provided' {
                {
                    $invokeConverseAPISplat = @{
                        Message      = 'Make it so.'
                        ToolsResults = $toolsResults
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if tools are provided but model does not support them' {
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'Make it so.'
                        Tools       = $standardTools
                        ModelID     = 'amazon.titan-tg1-large'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if SystemPrompt is provided but model does not support it' {
                {
                    $invokeConverseAPISplat = @{
                        Message      = 'Make it so.'
                        SystemPrompt = 'You are a Star Trek trivia master.'
                        ModelID      = 'amazon.titan-tg1-large'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if ToolChoice tool is provided but ToolName is not' {
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'Make it so.'
                        Tools       = $standardTools
                        ToolChoice  = 'tool'
                        ModelID     = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if all three guardrail parameters are not provided' {
                {
                    $invokeConverseAPISplat = @{
                        Message          = 'Make it so.'
                        GuardrailVersion = '1'
                        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName      = 'default'
                        Region           = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if a ImagePath is provided for a model that does not support vision' {
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'Make it so.'
                        ImagePath   = 'C:\Users\user\Documents\image.jpg'
                        ModelID     = 'meta.llama3-2-1b-instruct-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if more than 20 ImagePaths are provided' {
                $ImagePaths = @()
                for ($i = 0; $i -lt 21; $i++) {
                    $ImagePaths += "C:\Users\user\Documents\image$i.jpg"
                }
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'Make it so.'
                        ImagePath   = $ImagePaths
                        ModelID     = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if ImagePath is provided and it does not pass validation' {
                Mock -CommandName Test-ConverseAPIImage -MockWith { $false }
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'Make it so.'
                        ImagePath   = 'C:\Users\user\Documents\image.jpg'
                        ModelID     = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if a DocumentPath is provided for a model that does not support documents' {
                {
                    $invokeConverseAPISplat = @{
                        Message      = 'Make it so.'
                        DocumentPath = 'C:\Users\user\Documents\document.docx'
                        ModelID      = 'amazon.titan-text-premier-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if DocumentPath is provided and it does not pass validation' {
                Mock -CommandName Test-ConverseAPIDocument -MockWith { $false }
                {
                    $invokeConverseAPISplat = @{
                        Message      = 'Make it so.'
                        DocumentPath = 'C:\Users\user\Documents\document.docx'
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if more than 5 DocumentPaths are provided' {
                $documentPaths = @()
                for ($i = 0; $i -lt 6; $i++) {
                    $documentPaths += "C:\Users\user\Documents\document$i.docx"
                }
                {
                    $invokeConverseAPISplat = @{
                        Message      = 'Make it so.'
                        DocumentPath = $documentPaths
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if neither a Message, ImagePath, or DocumentPath is provided' {
                {
                    $invokeConverseAPISplat = @{
                        ModelID     = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Tools       = $standardTools
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRConverse -MockWith { throw 'Error' }
                {
                    $invokeConverseAPISplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Invoke-BDRRConverse -MockWith {
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
                    $invokeConverseAPISplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should warn the user and throw if the response indicates that Converse does not support the provided model' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Invoke-BDRRConverse -MockWith {
                    [System.Exception]$exception = 'This action doesn''t support the model that you provided. Try again with a supported text or chat model.'
                    [System.String]$errorId = 'Amazon.BedrockRuntime.Model.AccessDeniedException, Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
                    [System.Object]$target = 'Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID, $errorCategory, $target)
                    [System.Management.Automation.ErrorDetails]$errorDetails = ''
                    $errorRecord.ErrorDetails = $errorDetails
                    throw $errorRecord
                }
                {
                    $invokeConverseAPISplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRConverse -MockWith { $null }
                {
                    $invokeConverseAPISplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if tools parameter is provided and does not pass validation' {
                Mock -CommandName Test-ConverseAPITool -MockWith { $false }
                {
                    $invokeConverseAPISplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Tools     = $standardTools
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if toolResults parameter is provided and does not pass validation' {
                Mock -CommandName Test-ConverseAPIToolResult -MockWith { $false }
                {
                    $invokeConverseAPISplat = @{
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Tools        = $standardTools
                        ToolsResults = $toolsResults
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-ConverseAPI @invokeConverseAPISplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'Converse'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                function Invoke-BDRRConverse {
                }
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'Converse' }
                $context.Context = New-Object System.Collections.Generic.List[object]
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    })
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $systemMessage = 'You are a Star Trek trivia master.'
                $toolsResults = [PSCustomObject]@{
                    ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name    = 'Gristmill River Restaurant & Bar'
                            address = '1287 Gruene Rd, New Braunfels, TX 78130'
                            rating  = '4.5'
                            cuisine = 'American'
                            budget  = '2'
                        }
                    }
                    status    = 'success'
                }
                $standardTools = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                        }
                        cuisine  = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
                        }
                        budget   = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
                        }
                        rating   = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
                        }
                    }
                    required    = @(
                        'location'
                    )
                }
                Mock -CommandName Format-ConverseAPI -MockWith {
                    [Amazon.BedrockRuntime.Model.Message]::new()
                } #endMock
                Mock -CommandName Format-ConverseAPIToolConfig -MockWith {
                    [Amazon.BedrockRuntime.Model.Tool]::new()
                } #endMock
                Mock -CommandName Get-ModelContext -MockWith {
                    $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                    $messageObj.Role = 'user'
                    $content = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                    $content.Text = 'Best StarFleet captain?'
                    $messageObj.Content = $content
                    $obj = [PSCustomObject]@{
                        role    = 'user'
                        content = $messageObj
                    }
                } #endMock
                Mock -CommandName Test-ConverseAPIImage -MockWith { $true }
                Mock -CommandName Test-ConverseAPIDocument -MockWith { $true }
                Mock -CommandName Test-ConverseAPITool -MockWith { $true }
                Mock -CommandName Test-ConverseAPIToolResult -MockWith { $true }

                <#
                AdditionalModelResponseFields : {Document null value}
                Metrics                       : Amazon.BedrockRuntime.Model.ConverseMetrics
                Output                        : Amazon.BedrockRuntime.Model.ConverseOutput
                StopReason                    : end_turn
                Trace                         :
                Usage                         : Amazon.BedrockRuntime.Model.TokenUsage
                #>
                $response = [Amazon.BedrockRuntime.Model.ConverseResponse]::new()
                $response.StopReason = 'end_turn'
                $converseMetrics = [Amazon.BedrockRuntime.Model.ConverseMetrics]::new()
                $converseMetrics.LatencyMs = 100
                $response.Metrics = $converseMetrics
                $tokenUsage = [Amazon.BedrockRuntime.Model.TokenUsage]::new()
                $tokenUsage.InputTokens = 9
                $tokenUsage.OutputTokens = 244
                $tokenUsage.TotalTokens = 253
                $response.Usage = $tokenUsage
                $output = [Amazon.BedrockRuntime.Model.ConverseOutput]::new()
                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'assistant'
                $content = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                $content.Text = 'Captain Picard.'
                $messageObj.Content.Add($content)
                $output.Message = $messageObj
                $response.Output = $output

                Mock -CommandName Invoke-BDRRConverse -MockWith {
                    $response
                } #endMock

                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeConverseAPISplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeConverseAPISplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                $result | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseResponse]
                $result.StopReason | Should -BeExactly 'end_turn'
                $result.Metrics | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseMetrics]
                $result.Metrics.LatencyMs | Should -BeExactly 100
                $result.Usage | Should -BeOfType [Amazon.BedrockRuntime.Model.TokenUsage]
                $result.Usage.InputTokens | Should -BeExactly 9
                $result.Usage.OutputTokens | Should -BeExactly 244
                $result.Usage.TotalTokens | Should -BeExactly 253
                $result.Output | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseOutput]
                $result.Output.Message | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                $result.Output.Message.Role | Should -BeExactly 'assistant'
                $result.Output.Message.Content | Should -BeOfType [Amazon.BedrockRuntime.Model.ContentBlock]
                $result.Output.Message.Content[0].Text | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeConverseAPISplat = @{
                    Message                          = 'Shaka, when the walls fell.'
                    ModelID                          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    DocumentPath                     = 'C:\Users\user\Documents\document.docx'
                    NoContextPersist                 = $true
                    ReturnFullObject                 = $true
                    MaxTokens                        = 3000
                    StopSequences                    = @('Kirk')
                    Temperature                      = 0.5
                    TopP                             = 0.9
                    SystemPrompt                     = 'You are a Star Trek trivia master.'
                    Tools                            = $standardTools
                    ToolChoice                       = 'tool'
                    ToolName                         = 'trivia_engine'
                    GuardrailID                      = 'guardrailID'
                    GuardrailVersion                 = '1'
                    GuardrailTrace                   = 'enabled'
                    AdditionalModelRequestField      = [psobject]@{
                        top_k = 10
                    }
                    AdditionalModelResponseFieldPath = "/stop_sequence"
                    AccessKey                        = 'ak'
                    SecretKey                        = 'sk'
                    Region                           = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                $result | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseResponse]
                $result.StopReason | Should -BeExactly 'end_turn'
                $result.Metrics | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseMetrics]
                $result.Metrics.LatencyMs | Should -BeExactly 100
                $result.Usage | Should -BeOfType [Amazon.BedrockRuntime.Model.TokenUsage]
                $result.Usage.InputTokens | Should -BeExactly 9
                $result.Usage.OutputTokens | Should -BeExactly 244
                $result.Usage.TotalTokens | Should -BeExactly 253
                $result.Output | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseOutput]
                $result.Output.Message | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                $result.Output.Message.Role | Should -BeExactly 'assistant'
                $result.Output.Message.Content | Should -BeOfType [Amazon.BedrockRuntime.Model.ContentBlock]
                $result.Output.Message.Content[0].Text | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands for just a message' {
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Test-ConverseAPIImage -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPITool -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIDocument -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIToolResult -Exactly 0 -Scope It
                Should -Invoke Format-ConverseAPI -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Format-ConverseAPIToolConfig -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRConverse -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when media file is provided' {
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ImagePath = 'C:\Users\user\Documents\image.jpg'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Test-ConverseAPIImage -Exactly 1 -Scope It
                Should -Invoke Test-ConverseAPITool -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIDocument -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIToolResult -Exactly 0 -Scope It
                Should -Invoke Format-ConverseAPI -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Format-ConverseAPIToolConfig -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRConverse -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when document file is provided' {
                $invokeConverseAPISplat = @{
                    Message      = 'Make it so.'
                    DocumentPath = 'C:\Users\user\Documents\document.docx'
                    ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey    = 'ak'
                    SecretKey    = 'sk'
                    Region       = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Test-ConverseAPIImage -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPITool -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIDocument -Exactly 1 -Scope It
                Should -Invoke Test-ConverseAPIToolResult -Exactly 0 -Scope It
                Should -Invoke Format-ConverseAPI -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Format-ConverseAPIToolConfig -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRConverse -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands if tools are provided' {
                $invokeConverseAPISplat = @{
                    Message    = 'Make it so.'
                    Tools      = $standardTools
                    ToolChoice = 'auto'
                    ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey  = 'ak'
                    SecretKey  = 'sk'
                    Region     = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Test-ConverseAPIImage -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPITool -Exactly 1 -Scope It
                Should -Invoke Test-ConverseAPIDocument -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIToolResult -Exactly 0 -Scope It
                Should -Invoke Format-ConverseAPI -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Format-ConverseAPIToolConfig -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRConverse -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when tool_calls are returned' {
                $invokeConverseAPISplat = @{
                    Tools        = $standardTools
                    ToolsResults = $toolsResults
                    ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey    = 'ak'
                    SecretKey    = 'sk'
                    Region       = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Test-ConverseAPIImage -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPITool -Exactly 1 -Scope It
                Should -Invoke Test-ConverseAPIDocument -Exactly 0 -Scope It
                Should -Invoke Test-ConverseAPIToolResult -Exactly 1 -Scope It
                Should -Invoke Format-ConverseAPI -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Format-ConverseAPIToolConfig -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRConverse -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                # * there appears to be a Pester issue where parameters with underscores can not be validated
                # * it also appears that Pester converts object types and can not properly validate Amazon specific types
                Mock -CommandName Invoke-BDRRConverse {
                    $response
                    $ModelID                                | Should -BeExactly 'anthropic.claude-3-sonnet-20240229-v1:0'
                    $AdditionalModelRequestField            | Should -BeOfType [PSObject]
                    $AdditionalModelResponseFieldPath       | Should -BeOfType [string]
                    # $ToolChoice_Any                         | Should -BeOfType [Amazon.BedrockRuntime.Model.AnyToolChoice]
                    # $GuardrailConfig_GuardrailIdentifier    | Should -BeExactly 'guardrailID'
                    # $GuardrailConfig_GuardrailVersion       | Should -BeExactly '1'
                    # $GuardrailConfig_Trace                  | Should -BeExactly 'enabled'
                    # $InferenceConfig_MaxTokens              | Should -BeExactly 3000
                    # $Message                                | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                    # $InferenceConfig_StopSequence           | Should -BeExactly @('Kirk')
                    # $System | Should -BeOfType 'Amazon.BedrockRuntime.Model.SystemContentBlock'
                    # # $InferenceConfig_Temperature            | Should -BeExactly 0.5
                    # # $ToolConfig_Tool                        | Should -BeOfType [Amazon.BedrockRuntime.Model.Tool]
                    # $InferenceConfig_TopP                   | Should -BeExactly 0.9
                    # # $GuardrailConfig_Trace                  | Should -BeExactly 'enabled'
                    $Region         | Should -BeExactly 'us-west-2'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                } -Verifiable
                $invokeConverseAPISplat = @{
                    Message                          = 'Shaka, when the walls fell.'
                    ModelID                          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    DocumentPath                     = 'C:\Users\user\Documents\document.docx'
                    NoContextPersist                 = $true
                    ReturnFullObject                 = $true
                    MaxTokens                        = 3000
                    StopSequences                    = @('Kirk')
                    Temperature                      = 0.5
                    TopP                             = 0.9
                    SystemPrompt                     = 'You are a Star Trek trivia master.'
                    Tools                            = $standardTools
                    ToolChoice                       = 'any'
                    GuardrailID                      = 'guardrailID'
                    GuardrailVersion                 = '1'
                    GuardrailTrace                   = 'enabled'
                    AdditionalModelRequestField      = [PSObject]@{
                        top_k = 10
                    }
                    AdditionalModelResponseFieldPath = "/stop_sequence"
                    AccessKey                        = 'ak'
                    SecretKey                        = 'sk'
                    Region                           = 'us-west-2'
                }
                Invoke-ConverseAPI @invokeConverseAPISplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRConverse {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'anthropic.claude-3-sonnet-20240229-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                } -Verifiable
                $invokeConverseAPISplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-ConverseAPI @invokeConverseAPISplat | Should -InvokeVerifiable
            } #it

            It 'should not warn the user if tool_use is returned' {
                Mock -CommandName Write-Warning {}
                $response.StopReason = 'tool_use'
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Write-Warning -Exactly 0
            } #it

            It 'should warn the user if max_tokens is returned' {
                Mock -CommandName Write-Warning {}
                $response.StopReason = 'max_tokens'
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should warn the user if stop_sequence is returned' {
                Mock -CommandName Write-Warning {}
                $response.StopReason = 'stop_sequence'
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should warn the user if guardrail is returned' {
                Mock -CommandName Write-Warning {}
                $response.StopReason = 'guardrail_intervened'
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should warn the user if content_filtered is returned' {
                Mock -CommandName Write-Warning {}
                $response.StopReason = 'content_filtered'
                $invokeConverseAPISplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-ConverseAPI @invokeConverseAPISplat
                Should -Invoke Write-Warning -Exactly 1
            } #it

        } #context_Success

    } #describe_Invoke-ConverseAPI
} #inModule
