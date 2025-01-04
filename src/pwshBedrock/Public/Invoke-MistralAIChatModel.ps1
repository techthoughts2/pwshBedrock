<#
.SYNOPSIS
    Sends message(s) to the Mistral AI chat model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an Mistral AI chat model on the Amazon Bedrock platform and returns the model's response.
    By default, the conversation context history is persisted to maintain a continuous interaction with the model.
    You can disable this by using the NoContextPersist parameter. Additionally, the cmdlet estimates the cost of model usage
    based on the provided input and output tokens and adds the estimate to the models tally information.
    This model supports Function Calling, which allows the Mistral model to connect to external tools.
    You can provide Tools and ToolChoice parameters to enable this feature.
    If you are providing Tools to enable Function Calling, it is recommended that you use the ReturnFullObject parameter to capture the full response object.
    See the pwshBedrock documentation for more information on Function Calling and the Mistral AI chat model.
.EXAMPLE
    Invoke-MistralAIChatModel -Message 'Explain zero-point energy.' -ModelID 'mistral.mistral-large-2407-v1:0' -Credential $awsCredential -Region 'us-west-2'

    Sends a chat message to the on-demand Mistral AI chat model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-MistralAIChatModel -Message 'Explain zero-point energy.' -ModelID 'mistral.mistral-large-2407-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a chat message to the on-demand Mistral AI chat model in the specified AWS region and returns the full response object.
.EXAMPLE
    $invokeMistralAIChatModelSplat = @{
        SystemPrompt     = 'You are a Star Trek trivia expert.'
        Message          = 'How much does Lt. Commander Data weigh?'
        Tools            = $starTrekTriviaFunctionTool
        ToolChoice       = 'auto'
        ReturnFullObject = $true
        ModelID          = 'mistral.mistral-large-2407-v1:0'
        ReturnFullObject = $true
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat

    Sends a chat message to the on-demand Mistral AI chat model in the specified AWS region with a system prompt and tool function call.
.EXAMPLE
    $invokeMistralAIChatModelSplat = @{
        ToolsResults     = $starTrekTriviaFunctionResults
        ModelID          = 'mistral.mistral-large-2407-v1:0'
        ReturnFullObject = $true
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat

    Sends a chat message to the on-demand Mistral AI chat model in the specified AWS region with tool results from a previous chat turn.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER SystemPrompt
    Sets the behavior and context for the model in the conversation.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER NoContextPersist
    Do not persist the conversation context history.
.PARAMETER Tools
    Definitions of tools that the model may use.
.PARAMETER ToolChoice
    Specifies how functions are called. If set to none the model won't call a function and will generate a message instead. If set to auto the model can choose to either generate a message or call a function. If set to any the model is forced to call a function.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
.PARAMETER Temperature
    The amount of randomness injected into the response.
.PARAMETER TopP
    Use a lower value to ignore less probable options and decrease the diversity of responses.
.PARAMETER AccessKey
    The AWS access key for the user account. This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.
.PARAMETER Credential
    An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.
.PARAMETER EndpointUrl
    The endpoint to make the call against.
    Note: This parameter is primarily for internal AWS use and is not required/should not be specified for  normal usage. The cmdlets normally determine which endpoint to call based on the region specified to the -Region parameter or set as default in the shell (via Set-DefaultAWSRegion). Only specify this parameter if you must direct the call to a specific custom endpoint.
.PARAMETER NetworkCredential
    Used with SAML-based authentication when ProfileName references a SAML role profile.  Contains the network credentials to be supplied during authentication with the  configured identity provider's endpoint. This parameter is not required if the user's default network identity can or should be used during authentication.
.PARAMETER ProfileLocation
    Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs)
    If this optional parameter is omitted this cmdlet will search the encrypted credential file used by the AWS SDK for .NET and AWS Toolkit for Visual Studio first. If the profile is not found then the cmdlet will search in the ini-format credential file at the default location: (user's home directory)\.aws\credentials.
    If this parameter is specified then this cmdlet will only search the ini-format credential file at the location given.
    As the current folder can vary in a shell or during script execution it is advised that you use specify a fully qualified path instead of a relative path.
.PARAMETER ProfileName
    The user-defined name of an AWS credentials or SAML-based role profile containing credential information. The profile is expected to be found in the secure credential file shared with the AWS SDK for .NET and AWS Toolkit for Visual Studio. You can also specify the name of a profile stored in the .ini-format credential file used with  the AWS CLI and other AWS SDKs.
.PARAMETER Region
    The system name of an AWS region or an AWSRegion instance. This governs the endpoint that will be used when calling service operations. Note that  the AWS resources referenced in a call are usually region-specific.
.PARAMETER SecretKey
    The AWS secret key for the user account. This can be a temporary secret key if the corresponding session token is supplied to the -SessionToken parameter.
.PARAMETER SessionToken
    The session token if the access and secret keys are temporary session-based credentials.
.OUTPUTS
    System.String
    or
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    * For a full tools example, see the advanced documentation on the pwshBedrock website.

    This was incredibly hard to make.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-MistralAIChatModel/
.LINK
    https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-mistral-chat-completion.html
.LINK
    https://docs.mistral.ai/capabilities/function_calling/
#>
function Invoke-MistralAIChatModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'MessageSet',
            HelpMessage = 'The message to be sent to the model.')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CombinedSet',
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true, ParameterSetName = 'SystemPromptSet',
            HelpMessage = 'Sets the behavior and context for the model in the conversation.')]
        [Parameter(Mandatory = $true, ParameterSetName = 'CombinedSet',
            HelpMessage = 'Sets the behavior and context for the model in the conversation.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $true, ParameterSetName = 'ToolsResultsSet',
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [ValidateNotNull()]
        [PSCustomObject[]]$ToolsResults,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mistral-large-2407-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned instead of just the message reply.')]
        [switch]$ReturnFullObject,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [switch]$NoContextPersist,

        # model parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $false,
            HelpMessage = "Specifies how functions are called. If set to none the model won''t call a function and will generate a message instead. If set to auto the model can choose to either generate a message or call a function. If set to any the model is forced to call a function.")]
        [ValidateSet('auto', 'any', 'none')]
        [string]$ToolChoice,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 8192)]
        [int]$MaxTokens = 8192,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.01, 0.99)]
        [float]$TopP,

        # Common Parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The AWS access key for the user account.')]
        [string]$AccessKey,

        [Parameter(Mandatory = $false,
            HelpMessage = 'An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.')]
        [Amazon.Runtime.AWSCredentials]$Credential,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The endpoint to make the call against. Not for normal use.')]
        [string]$EndpointUrl,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Used with SAML-based authentication when ProfileName references a SAML role profile.')]
        [System.Management.Automation.PSCredential]$NetworkCredential,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs)')]
        [string]$ProfileLocation,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The user-defined name of an AWS credentials or SAML-based role profile containing credential information.')]
        [string]$ProfileName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system name of an AWS region or an AWSRegion instance.')]
        [object]$Region,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The AWS secret key for the user account.')]
        [string]$SecretKey,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The session token if the access and secret keys are temporary session-based credentials.')]
        [string]$SessionToken

    )

    $modelInfo = $script:mistralAIModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if (
        $PSCmdlet.ParameterSetName -eq 'MessageSet' -or
        $PSCmdlet.ParameterSetName -eq 'SystemPromptSet' -or
        $PSCmdlet.ParameterSetName -eq 'CombinedSet') {
        Write-Debug -Message $PSCmdlet.ParameterSetName

        # the system prompt must always be the first message in the context, otherwise the model will fail validation
        #  *Note: on subsequent calls, the system prompt will be updated instead of replaced, ensuring the system prompt is always the first message in the context
        if ($SystemPrompt) {
            $formatMistralAIChatSplat = @{
                Role             = 'system'
                Message          = $SystemPrompt
                ModelID          = $ModelID
                NoContextPersist = $NoContextPersist
            }
            $formattedSystemMessage = Format-MistralAIChatModel @formatMistralAIChatSplat
        }

        if ($Message) {
            $formatMistralAIChatSplat = @{
                Role             = 'user'
                Message          = $Message
                ModelID          = $ModelID
                NoContextPersist = $NoContextPersist
            }
            $formattedUserMessage = Format-MistralAIChatModel @formatMistralAIChatSplat
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ToolsResultsSet') {
        Write-Debug -Message 'ToolsResultsSet'

        # ToolsResults - must be formed properly
        $toolsResultsEval = Test-MistralAIChatToolResult -ToolResults $ToolsResults
        if ($toolsResultsEval -ne $true) {
            throw 'Tool results validation failed.'
        }
        foreach ($toolResult in $ToolsResults) {
            $formatMistralAIChatSplat = @{
                Role             = 'tool'
                ToolsResults     = $toolResult
                ModelID          = $ModelID
                NoContextPersist = $NoContextPersist
            }
            $formattedToolsResults += Format-MistralAIChatModel @formatMistralAIChatSplat
        }
    }

    if ($NoContextPersist -eq $true) {
        $formattedMessages = @(
            $formattedUserMessage
            $formattedSystemMessage
            $formattedToolsResults
        )
    }
    else {
        $formattedMessages = Get-ModelContext -ModelID $ModelID
    }

    #region cmdletParams

    $bodyObj = @{
        messages = @(
            $formattedMessages
        )
    }

    if ($Tools) {
        # Tools - must be formed properly
        $toolsEval = Test-MistralAIChatTool -Tools $Tools
        if ($toolsEval -ne $true) {
            throw 'Tools validation failed.'
        }
        $bodyObj.Add('tools', $Tools)
    }

    if ($ToolChoice) {
        $bodyObj.Add('tool_choice', $Documents)
    }

    if ($MaxTokens) {
        $bodyObj.Add('max_tokens', $MaxTokens)
    }

    if ($Temperature) {
        $bodyObj.Add('temperature', $Temperature)
    }

    if ($TopP) {
        $bodyObj.Add('top_p', $TopP)
    }

    # at this point in memory, the messages context is still in object form
    $jsonBody = $bodyObj | ConvertTo-Json -Depth 10
    [byte[]]$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

    $inferenceModelID = Format-InferenceProfileID -ModelID $ModelID -Region $Region

    $cmdletParams = @{
        ContentType = 'application/json'
        ModelId     = $inferenceModelID
        Body        = $byteArray
    }

    Write-Debug -Message 'Cmdlet Params:'
    Write-Debug -Message ($cmdletParams | Out-String)

    Write-Debug -Message 'Body JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    #endregion

    #region commonParams

    $commonParams = @{}

    if ($AccessKey) {
        $commonParams.Add('AccessKey', $AccessKey)
    }
    if ($Credential) {
        $commonParams.Add('Credential', $Credential)
    }
    if ($EndpointUrl) {
        $commonParams.Add('EndpointUrl', $EndpointUrl)
    }
    if ($NetworkCredential) {
        $commonParams.Add('NetworkCredential', $NetworkCredential)
    }
    if ($ProfileLocation) {
        $commonParams.Add('ProfileLocation', $ProfileLocation)
    }
    if ($ProfileName) {
        $commonParams.Add('ProfileName', $ProfileName)
    }
    if ($Region) {
        $commonParams.Add('Region', $Region)
    }
    if ($SecretKey) {
        $commonParams.Add('SecretKey', $SecretKey)
    }
    if ($SessionToken) {
        $commonParams.Add('SessionToken', $SessionToken)
    }

    #endregion

    try {
        $rawResponse = Invoke-BDRRModel @cmdletParams @commonParams -ErrorAction Stop
    }
    catch {
        # we need to remove the user context from the global variable if the model is not successfully engaged
        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message 'Catch Block. Context:'
        Write-Debug -Message ($context | Out-String)
        Write-Debug -Message ('Context count: {0}' -f $context.Context.Count)
        if ($context.Context.Count -le 1) {
            Write-Debug -Message 'Resetting context.'
            $context.Context = New-Object System.Collections.Generic.List[object]
        }
        else {
            $context.Context.RemoveAt($context.Context.Count - 1)

            # special case if two messages were loaded into the context
            if ($PSCmdlet.ParameterSetName -eq 'CombinedSet') {
                $context.Context.RemoveAt($context.Context.Count - 1)
            }
        }

        $exceptionMessage = $_.Exception.Message
        if ($exceptionMessage -like "*don't have access*") {
            Write-Debug -Message 'Specific Error'
            Write-Warning -Message 'You do not have access to the requested model.'
            Write-Warning -Message 'In your AWS account, you will need to request access to the model.'
            Write-Warning -Message 'AWS -> Amazon Bedrock -> Model Access -> Request Access'
            throw ('No access to model {0}.' -f $ModelID)
        }
        else {
            Write-Debug -Message 'General Error'
            Write-Debug -Message ($_ | Out-String)
            Write-Error -Message $_
            Write-Error -Message $_.Exception.Message
            throw
        }
    }

    if ([String]::IsNullOrWhiteSpace($rawResponse)) {
        throw 'No response from model API.'
    }

    Write-Verbose -Message 'Processing response.'
    try {
        $jsonBody = ConvertFrom-MemoryStreamToString -MemoryStream $rawResponse.body -ErrorAction Stop
    }
    catch {
        # we need to remove the user context from the global variable if the model is not successfully engaged
        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message ($context | Out-String)
        Write-Debug -Message ('Context count: {0}' -f $context.Context.Count)
        if ($context.Context.Count -le 1) {
            Write-Debug -Message 'Resetting context.'
            $context.Context = New-Object System.Collections.Generic.List[object]
        }
        else {
            $context.Context.RemoveAt($context.Context.Count - 1)

            # special case if two messages were loaded into the context
            if ($PSCmdlet.ParameterSetName -eq 'CombinedSet') {
                $context.Context.RemoveAt($context.Context.Count - 1)
            }
        }

        Write-Error $_
        throw
    }

    Write-Debug -Message 'Response JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    Write-Verbose -Message 'Converting response from JSON.'
    $response = $jsonBody | ConvertFrom-Json

    # in this model null content responses are expected when the assistant is returning tool_calls
    if ($response.choices.stop_reason -eq 'tool_calls') {
        Write-Verbose -Message 'Tool calls detected.'
        # determine if tool_calls is null
        if ($response.choices.message.tool_calls.Count -eq 0) {
            Write-Warning -Message 'Tool calls detected but no tool calls were returned.'
            throw 'No tool calls were returned from model API.'
        }
        if ($NoContextPersist -eq $false) {
            $formatMistralAIChatSplat = @{
                Role             = 'assistant'
                ToolCalls        = $response.choices.message.tool_calls
                ModelID          = $ModelID
                NoContextPersist = $NoContextPersist
            }
            Format-MistralAIChatModel @formatMistralAIChatSplat | Out-Null
        }
    } #if_tool_calls
    else {
        if ([string]::IsNullOrWhiteSpace($response.choices.message.content)) {
            if ($MaxTokens -lt 150) {
                Write-Warning -Message 'In some cases, the model may return an empty response when the max tokens is set to a low value.'
                Write-Warning -Message ('MaxTokens on this call was set to {0}.' -f $MaxTokens)
                Write-Warning -Message 'Try increasing the MaxTokens value and try again.'
            }
            throw ('No response text was returned from model API: {0}' -f $ModelID)
        }

        if ($NoContextPersist -eq $false) {
            Write-Verbose -Message 'Adding response to model context history.'
            $formatMistralAIChatModelSplat = @{
                Role    = 'assistant'
                Message = $response.choices.message.content
                ModelID = $ModelID
            }
            Format-MistralAIChatModel @formatMistralAIChatModelSplat | Out-Null
        }
    } #else_tool_calls


    Write-Verbose -Message 'Calculating cost estimate.'
    $message = $formattedMessages | ConvertTo-Json -Depth 10 | Out-String
    Add-ModelCostEstimate -Usage $response -Message $Message -ModelID $ModelID

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $response.choices.message.content
    }

} #Invoke-MistralAIChatModel
