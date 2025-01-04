<#
.SYNOPSIS
    Sends message(s) or media files to an Anthropic model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an Anthropic model on the Amazon Bedrock platform and returns the model's response.
    The message can be either text or a media file. If a media file is specified, it is converted to base64 according to the model's requirements.
    By default, the conversation context history is persisted to maintain a continuous interaction with the model.
    You can disable this by using the NoContextPersist parameter. Additionally, the cmdlet estimates the cost of model usage
    based on the provided input and output tokens and adds the estimate to the models tally information.
    This model supports Function Calling, which allows the Anthropic model to connect to external tools. This is only supported
    for Anthropic 3 models. You can provide the Tools and ToolChoice parameters to specify the tools that the model may use and how.
    If you are providing Tools to enable Function Calling, it is recommended that you use the ReturnFullObject parameter to capture the full response object.
    See the pwshBedrock documentation for more information on Function Calling and the Anthropic model.
.EXAMPLE
    Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -Credential $awsCredential -Region 'us-west-2'

    Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -ProfileName default -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the full response object.
.EXAMPLE
    Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -ProfileName default -Region 'us-west-2' -NoContextPersist

    Sends a text message to the on-demand Anthropic model in the specified AWS region without persisting the conversation context history. This is useful for one-off interactions.
.EXAMPLE
    $invokeAnthropicModelSplat = @{
        Message    = 'What can you tell me about this picture? Is it referencing something?'
        ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
        MediaPath  = 'C:\images\tanagra.jpg'
        AccessKey  = 'xxxxxxxxxxxxxxxxxxxx'
        SecretKey  = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        Region     = 'us-west-2'
    }
    Invoke-AnthropicModel @invokeAnthropicModelSplat

    Sends a text message with a media file to the on-demand Anthropic model in the specified AWS region and returns the response.
.EXAMPLE
    $invokeAnthropicModelSplat = @{
        Message          = 'Give a brief synopsis to your class of students of what this picture represented a hundreds years ago.'
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        MediaPath        = 'C:\images\tanagra.jpg'
        Temperature      = 1
        SystemPrompt     = 'You are a historian from the future who has studied the provided photo for many years.'
        Credential       = $credential
        Region           = 'us-west-2'
    }
    Invoke-AnthropicModel @invokeAnthropicModelSplat

    Sends a text message with a media file to the on-demand Anthropic model in the specified AWS region and returns the response. A system prompt is provided to give additional context to the model on how to respond. Temperature is set to 1 for creative responses.
.EXAMPLE
    $invokeAnthropicModelSplat = @{
        Message          = 'Can you name all of the Star Fleet captains featured in the various shows over the years?'
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        SystemPrompt     = 'You are an expert on all things Star Trek, having studied the show for decades. You often win Star Trek Trivia contests and enjoy sharing your vast knowledge of Star Trek with others.'
        Temperature      = 1
        StopSequences    = 'Picard'
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $objReturn = Invoke-AnthropicModel @invokeAnthropicModelSplat

    Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the full response object. A system prompt is provided to give additional context to the model on how to respond. Temperature is set to 1 for creative responses. Stop sequences are provided to stop the model from generating more text when it encounters the word 'Picard'.
.EXAMPLE
    Invoke-AnthropicModel -CustomConversation $customConversation -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -ProfileName default -Region 'us-west-2'

    Sends a custom conversation to the on-demand Anthropic model in the specified AWS region and returns the response. The custom conversation must adhere to the Anthropic model conversation format. Reference the pwshBedrock documentation for more information on the custom conversation format.
.EXAMPLE
    $invokeAnthropicModelSplat = @{
        Message          = 'Can you name all of the Star Fleet captains featured in the various shows over the years?'
        ModelID          = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
        SystemPrompt     = 'You are an expert on all things Star Trek, having studied the show for decades. You often win Star Trek Trivia contests and enjoy sharing your vast knowledge of Star Trek with others.'
        Tools            = $starTrekTriviaFunctionTool
        ToolChoice       = 'auto'
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $objReturn = Invoke-AnthropicModel @invokeAnthropicModelSplat

    Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the full response object. A system prompt is provided to give additional context to the model on how to respond. A tool is provided to the model to use if needed. The tool choice is set to auto, allowing the model to decide if it should use the tool. The tool is a function that provides Star Trek trivia information.
.EXAMPLE
    $invokeAnthropicModelSplat = @{
        ToolsResults = $standardToolResult
        ModelID      = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
        Credential   = $credential
        Region       = 'us-west-2'
    }
    Invoke-AnthropicModel @invokeAnthropicModelSplat

    Sends the results of a tool invocation to the on-demand Anthropic model in the specified AWS region and returns the response. The tool results must adhere to the Anthropic model tool result format. Reference the pwshBedrock documentation for more information on the tool result format.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER MediaPath
    File path to local media file.
    Up to 20 media files can be sent in a single request. The media files must adhere to the model's media requirements.
.PARAMETER CustomConversation
    An array of custom conversation objects.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
    Defaults to 4096. Ranges from 1 to 4096.
    Note that Anthropic Claude models might stop generating tokens before reaching the value of max_tokens.
.PARAMETER SystemPrompt
    The system prompt for the request.
    System prompt is a way of providing context and instructions to Anthropic Claude, such as specifying a particular goal or role.
.PARAMETER StopSequences
    Custom text sequences that cause the model to stop generating. Anthropic Claude models normally stop when they have naturally completed their turn, in this case the value of the stop_reason response field is end_turn. If you want the model to stop generating when it encounters custom strings of text, you can use the stop_sequences parameter. If the model encounters one of the custom text strings, the value of the stop_reason response field is stop_sequence and the value of stop_sequence contains the matched stop sequence.
.PARAMETER Temperature
    The amount of randomness injected into the response.
    Defaults to 1.0. Ranges from 0.0 to 1.0.
    Use temperature closer to 0.0 for analytical / multiple choice, and closer to 1.0 for creative and generative tasks.
.PARAMETER TopP
    Use nucleus sampling.
    In nucleus sampling, Anthropic Claude computes the cumulative distribution over all the options for each subsequent token in decreasing probability order and cuts it off once it reaches a particular probability specified by top_p. You should alter either temperature or top_p, but not both.
    Recommended for advanced use cases only. You usually only need to use temperature.
.PARAMETER TopK
    Only sample from the top K options for each subsequent token.
    Use top_k to remove long tail low probability responses.
    Recommended for advanced use cases only. You usually only need to use temperature.
.PARAMETER Tools
    Definitions of tools that the model may use.
.PARAMETER ToolChoice
    In some cases, you may want Claude to use a specific tool to answer the user’s question, even if Claude thinks it can provide an answer without using a tool.
    auto - allows Claude to decide whether to call any provided tools or not. This is the default value.
    any - tells Claude that it must use one of the provided tools, but doesn’t force a particular tool.
    tool -allows us to force Claude to always use a particular tool.
        if you specify tool, you must also provide the ToolName of the tool you want Claude to use.
.PARAMETER ToolName
    Optional parameter - The name of the tool that Claude should use to answer the user’s question.
    This parameter is only required if you set the ToolChoice parameter to tool.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
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
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-AnthropicModel/
.LINK
    https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude-messages.html
.LINK
    https://docs.anthropic.com/en/docs/models-overview
.LINK
    https://docs.anthropic.com/en/api/messages
.LINK
    https://docs.anthropic.com/en/api/messages-examples
.LINK
    https://docs.anthropic.com/en/docs/system-prompts
.LINK
    https://docs.anthropic.com/en/docs/vision
.LINK
    https://docs.anthropic.com/en/docs/build-with-claude/tool-use
#>
function Invoke-AnthropicModel {
    [CmdletBinding(
        DefaultParameterSetName = 'Standard'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'The message to be sent to the model.',
            ParameterSetName = 'Standard')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.',
            ParameterSetName = 'Standard')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$MediaPath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'An array of custom conversation objects.',
            ParameterSetName = 'PreCraftedMessages')]
        [ValidateNotNull()]
        [PSCustomObject[]]$CustomConversation,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'anthropic.claude-v2:1',
            'anthropic.claude-3-haiku-20240307-v1:0',
            'anthropic.claude-3-5-haiku-20241022-v1:0',
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-5-sonnet-20241022-v2:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0'
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
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 4096)]
        [int]$MaxTokens = 4096,

        # https://docs.anthropic.com/en/docs/system-prompts
        [Parameter(Mandatory = $false,
            HelpMessage = 'The system prompt for the request.')]
        [ValidateNotNullOrEmpty()]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use nucleus sampling. Not for normal use.')]
        [ValidateRange(0.0, 1.0)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Only sample from the top K options for each subsequent token. Not for normal use.')]
        [ValidateRange(0, 500)]
        [int]$TopK,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies how functions are called.')]
        [ValidateSet('auto', 'any', 'tool')]
        [string]$ToolChoice,

        [Parameter(Mandatory = $false,
            HelpMessage = "The name of the tool that Claude should use to answer the user's question.")]
        [string]$ToolName,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.',
            ParameterSetName = 'ToolsResultsSet')]
        [ValidateNotNull()]
        [PSCustomObject[]]$ToolsResults,

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

    $modelInfo = $script:anthropicModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if ($ToolChoice -eq 'tool' -and [string]::IsNullOrWhiteSpace($ToolName)) {
        throw 'ToolName must be specified when ToolChoice is set to tool.'
    }
    # tool options are not supported by the anthropic 2 model
    if ($ModelID -eq 'anthropic.claude-v2:1' ) {
        if ($Tools -or $ToolChoice -or $ToolName) {
            throw 'Tool options are not supported by the anthropic 2 model.'
        }
    }

    Write-Debug -Message ('Parameter Set: {0}' -f $PSCmdlet.ParameterSetName)
    switch ($PSCmdlet.ParameterSetName) {
        'Standard' {
            if ($MediaPath) {
                Write-Verbose -Message 'Vision message with media path provided.'
                if ($modelInfo.Vision -ne $true) {
                    Write-Warning -Message ('You provided a media path for model {0}. Vision is not supported for this model.' -f $ModelID)
                    throw 'Vision is not supported for this model.'
                }

                if ($MediaPath.Count -gt 20) {
                    throw ('You provided {0} media files. You can only provide up to 20 media files.' -f $MediaPath.Count)
                }

                foreach ($media in $MediaPath) {
                    if (-not (Test-AnthropicMedia -MediaPath $media)) {
                        throw ('Media test for {0} failed.' -f $media)
                    }
                }

                $formatAnthropicMessageSplat = @{
                    Role             = 'user'
                    Message          = $Message
                    ModelID          = $ModelID
                    MediaPath        = $MediaPath
                    NoContextPersist = $NoContextPersist
                }
                $formattedMessages = Format-AnthropicMessage @formatAnthropicMessageSplat
            }
            elseif ($Message) {
                Write-Verbose -Message 'Standard message provided.'
                $formatAnthropicMessageSplat = @{
                    Role             = 'user'
                    Message          = $Message
                    ModelID          = $ModelID
                    NoContextPersist = $NoContextPersist
                }
                $formattedMessages = Format-AnthropicMessage @formatAnthropicMessageSplat
            }
            else {
                throw 'You must provide either a message or media path.'
            }
        }
        'PreCraftedMessages' {
            Write-Verbose -Message 'Custom conversation provided'
            $conversationEval = Test-AnthropicCustomConversation -CustomConversation $CustomConversation
            if ($conversationEval -ne $true) {
                throw 'Custom conversation validation failed.'
            }
            else {
                $formattedMessages = $CustomConversation
            }
        }
        'ToolsResultsSet' {
            Write-Verbose -Message 'Tools results provided'

            if (-not $Tools) {
                throw 'Tools must be provided when ToolsResults are provided.'
            }

            # ToolsResults - must be formed properly
            $toolsResultsEval = Test-AnthropicToolResult -ToolResults $ToolsResults
            if ($toolsResultsEval -ne $true) {
                throw 'Tools results validation failed.'
            }
            $formatAnthropicMessageSplat = @{
                Role             = 'user'
                ToolsResults     = $ToolsResults
                ModelID          = $ModelID
                NoContextPersist = $NoContextPersist
            }
            $formattedMessages += Format-AnthropicMessage @formatAnthropicMessageSplat
        }
    }

    #region cmdletParams

    $bodyObj = @{
        'anthropic_version' = 'bedrock-2023-05-31'
        'max_tokens'        = $MaxTokens
        messages            = @(
            $formattedMessages
        )
    }
    if ($SystemPrompt) {
        $bodyObj.Add('system', $SystemPrompt)
    }
    if ($StopSequences) {
        $bodyObj.Add('stop_sequences', $StopSequences)
    }
    if ($Temperature) {
        $bodyObj.Add('temperature', $Temperature)
    }
    if ($TopP) {
        $bodyObj.Add('top_p', $TopP)
    }
    if ($TopK) {
        $bodyObj.Add('top_k', $TopK)
    }
    if ($Tools) {
        $toolsEval = Test-AnthropicTool -Tools $Tools
        if ($toolsEval -ne $true) {
            throw 'Tools validation failed.'
        }
        $bodyObj.Add('tools', $Tools)
    }
    if ($ToolChoice) {
        $toolChoiceObj = @{
            type = $ToolChoice
        }
        if ($ToolName) {
            $toolChoiceObj.Add('name', $ToolName)
        }
        $bodyObj.Add('tool_choice', $toolChoiceObj)
    }
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
        Write-Debug -Message ($context | Out-String)
        Write-Debug -Message ('Context count: {0}' -f $context.Context.Count)
        if ($context.Context.Count -le 1) {
            $context.Context = New-Object System.Collections.Generic.List[object]
        }
        else {
            $context.Context.RemoveAt($context.Context.Count - 1)
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

    Write-Verbose -Message'Processing response.'
    try {
        $jsonBody = ConvertFrom-MemoryStreamToString -MemoryStream $rawResponse.body -ErrorAction Stop
    }
    catch {
        # we need to remove the user context from the global variable if the model is not successfully engaged
        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message ($context | Out-String)
        Write-Debug -Message ('Context count: {0}' -f $context.Context.Count)
        if ($context.Context.Count -le 1) {
            $context.Context = New-Object System.Collections.Generic.List[object]
        }
        else {
            $context.Context.RemoveAt($context.Context.Count - 1)
        }

        Write-Error $_
        throw
    }

    Write-Debug -Message 'Response JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    Write-Verbose -Message 'Converting response from JSON.'
    $response = $jsonBody | ConvertFrom-Json

    Write-Verbose -Message 'Calculating cost estimate.'
    Add-ModelCostEstimate -Usage $response.usage -ModelID $ModelID

    Write-Verbose -Message 'Adding response to model context history.'

    if ($response.stop_reason -eq 'tool_use') {
        Write-Debug -Message 'Tool use detected.'
        $formatAnthropicMessageSplat = @{
            Role             = 'assistant'
            ToolCall         = $response.content
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        Format-AnthropicMessage @formatAnthropicMessageSplat | Out-Null
    }
    else {
        Write-Debug -Message ('Stop Reason: {0}' -f $response.stop_reason)

        if ([string]::IsNullOrWhiteSpace($response.content.text)) {
            if ($MaxTokens -lt 150) {
                Write-Warning -Message 'In some cases, the model may return an empty response when the max tokens is set to a low value.'
                Write-Warning -Message ('MaxTokens on this call was set to {0}.' -f $MaxTokens)
                Write-Warning -Message 'Try increasing the MaxTokens value and try again.'
            }
            throw ('No response text was returned from model API: {0}' -f $ModelID)
        }

        $content = $response.content.text
        $formatAnthropicMessageSplat = @{
            Role             = 'assistant'
            Message          = $content
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        Format-AnthropicMessage @formatAnthropicMessageSplat | Out-Null
    }

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $content
    }

} #Invoke-AnthropicModel
