<#
.SYNOPSIS
    Sends message(s) to the Cohere Command R/R+ model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an Cohere Command R/R+ model on the Amazon Bedrock platform and returns the model's response.
    The cmdlet estimates the cost of model usage based on the provided input and output tokens and adds the estimate to the models tally information.
    Conversation context is supported by these models. See the notes section for more information.
.EXAMPLE
    Invoke-CohereCommandRModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-r-v1:0' -Credential $awsCredential -Region 'us-west-2'

    Sends a text message to the on-demand Cohere Command R model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-CohereCommandRModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-r-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand Cohere Command R model in the specified AWS region and returns the full response object.
.EXAMPLE
    $chatHistory = @(
        [PSCustomObject]@{ role = 'USER'; message = 'Who is the best Starfleet captain?' },
        [PSCustomObject]@{ role = 'CHATBOT'; message = 'Captain Kirk.' },
        [PSCustomObject]@{ role = 'USER'; message = 'Are you sure about that?' },
        [PSCustomObject]@{ role = 'CHATBOT'; message = 'Quite sure, why?' }
    )
    $standardTools = @(
        [PSCustomObject]@{
            name                  = "string"
            description           = "string"
            parameter_definitions = @{
                "parameter name" = [PSCustomObject]@{
                    description = "string"
                    type        = "string"
                    required    = $true
                }
            }
        }
    )
    $standardToolsResults = @(
        [PSCustomObject]@{
            call    = [PSCustomObject]@{
                name       = "string"
                parameters = [PSCustomObject]@{
                    "parameter name" = "string"
                }
            }
            outputs = @(
                [PSCustomObject]@{
                    text = "string"
                }
            )
        }
    )
    $documents = @(
        [PSCustomObject]@{
            title   = 'Making it so.'
            snippet = 'The line must be drawn here! This far, no further!'
        }
    )
    $invokeCohereCommandRModelSplat = @{
        Message           = 'Shaka, when the walls fell.'
        ModelID           = 'cohere.command-r-plus-v1:0'
        NoContextPersist  = $true
        ChatHistory       = $chatHistory
        Documents         = $documents
        Preamble          = 'You are a StarTrek trivia master.'
        MaxTokens         = 3000
        Temperature       = 0.5
        ReturnPrompt      = $true
        Tools             = $standardTools
        ToolsResults      = $standardToolsResults
        StopSequences     = @('Kirk')
        RawPrompting      = $true
        AccessKey         = 'ak'
        SecretKey         = 'sk'
        Region            = 'us-west-2'
    }
    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat

    Sends a message to the on-demand Cohere Command R+ model in the specified AWS region with custom parameters and returns the response.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER NoContextPersist
    Do not persist the conversation context history.
.PARAMETER ChatHistory
    Previous messages between the user and the model, meant to give the model conversational context for responding to the user's message.
    This must be in a properly formatted PSObject array with role and message properties.
.PARAMETER Documents
    A list of texts that the model can cite to generate a more accurate reply. Each document contains a title and snippet.
    The resulting generation includes citations that reference some of these documents.
    We recommend that you keep the total word count of the strings in the dictionary to under 300 words.
.PARAMETER SearchQueriesOnly
    Defaults to false. When true, the response will only contain a list of generated search queries, but no search will take place, and no reply from the model to the user's message will be generated.
.PARAMETER Preamble
    A preamble is a system message that is provided to a model at the beginning of a conversation which dictates how the model should behave throughout.
    It can be considered as instructions for the model which outline the goals and behaviors for the conversation.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
.PARAMETER Temperature
    The amount of randomness injected into the response.
.PARAMETER TopP
    Use a lower value to ignore less probable options and decrease the diversity of responses.
.PARAMETER TopK
    Specify the number of token choices the model uses to generate the next token.
.PARAMETER PromptTruncation
    AUTO_PRESERVE_ORDER, some elements from chat_history and documents will be dropped to construct a prompt that fits within the model's context length limit.
    During this process the order of the documents and chat history will be preserved. With prompt_truncation` set to OFF, no elements will be dropped.
.PARAMETER FrequencyPenalty
    Used to reduce repetitiveness of generated tokens. The higher the value, the stronger a penalty is applied to previously present tokens, proportional to how many times they have already appeared in the prompt or prior generation.
.PARAMETER PresencePenalty
    Used to reduce repetitiveness of generated tokens. Similar to frequency_penalty, except that this penalty is applied equally to all tokens that have already appeared, regardless of their exact frequencies.
.PARAMETER Seed
    If specified, the backend will make a best effort to sample tokens deterministically, such that repeated requests with the same seed and parameters should return the same result. However, determinism cannot be totally guaranteed.
.PARAMETER ReturnPrompt
    Specify true to return the full prompt that was sent to the model. The default value is false. In the response, the prompt in the prompt field.
.PARAMETER Tools
    A list of available tools (functions) that the model may suggest invoking before producing a text response.
    When tools is passed (without tool_results), the text field in the response will be "" and the tool_calls field in the response
    will be populated with a list of tool calls that need to be made. If no calls need to be made, the tool_calls array will be empty.
    This must be in a properly formatted PSObject array with all required Tools properties.
    For more information, see the Cohere documentation.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
    Results are used to produce a text response and are referenced in citations. When using tool_results, tools must be passed as well.
    Each tool_result contains information about how it was invoked, as well as a list of outputs in the form of dictionaries.
    Cohere’s unique fine-grained citation logic requires the output to be a list.
    This must be in a properly formatted PSObject array with all required ToolsResults properties.
    For more information, see the Cohere documentation.
.PARAMETER StopSequences
    Custom text sequences that cause the model to stop generating.
    This must be in a properly formatted string array.
    For more information, see the Cohere documentation.
.PARAMETER RawPrompting
    Specify true, to send the user’s message to the model without any preprocessing, otherwise false.
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

    The Cohere Command R/R+ models support a unique feature that allows you to directly pass conversation chat history as a dedicated parameter.
    This helps maintain context across multiple messages, useful for a conversational flow.

    By default, pwshBedrock automatically manages context history for models that support it, including the Cohere Command R/R+ models.
    This context history is stored in a global variable and is used to maintain conversation context across multiple messages.

    If you send messages to the model without using the -NoContextPersist parameter, pwshBedrock will keep track of the context for you.
    The context history will be automatically populated in the ChatHistory for subsequent messages.

    If you prefer to provide your own ChatHistory using the -ChatHistory parameter, pwshBedrock will discard its own context history and use the provided ChatHistory instead.
    This effectively resets pwshBedrock's context management for that model. You will need to manage the ChatHistory yourself if you use this parameter.

    In summary:
    - Without -NoContextPersist: pwshBedrock manages context automatically and populates ChatHistory for you.
    - With -ChatHistory: pwshBedrock discards its context history and uses the provided ChatHistory. You need to manage the context yourself.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandRModel/
.LINK
    https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command-r-plus.html
.LINK
    https://docs.cohere.com/docs/command-r
.LINK
    https://docs.cohere.com/docs/command-r-plus
.LINK
    https://docs.cohere.com/docs/tool-use
#>
function Invoke-CohereCommandRModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'MessageSet',
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'cohere.command-r-v1:0',
            'cohere.command-r-plus-v1:0'
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
            HelpMessage = "Previous messages between the user and the model, meant to give the model conversational context for responding to the user's message.")]
        [PSCustomObject[]]$ChatHistory,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of texts that the model can cite to generate a more accurate reply. Each document contains a title and snippet.')]
        [PSCustomObject[]]$Documents,

        [Parameter(Mandatory = $false,
            HelpMessage = "Defaults to false. When true, the response will only contain a list of generated search queries, but no search will take place, and no reply from the model to the user's message will be generated.")]
        [bool]$SearchQueriesOnly,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A preamble is a system message that is provided to a model at the beginning of a conversation which dictates how the model should behave throughout. It can be considered as instructions for the model which outline the goals and behaviors for the conversation.')]
        [string]$Preamble,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 4000)]
        [int]$MaxTokens = 4000,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.01, 0.99)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify the number of token choices the model uses to generate the next token.')]
        [ValidateRange(0, 500)]
        [int]$TopK,

        [Parameter(Mandatory = $false,
            HelpMessage = "AUTO_PRESERVE_ORDER, some elements from chat_history and documents will be dropped to construct a prompt that fits within the model's context length limit. During this process the order of the documents and chat history will be preserved. With prompt_truncation` set to OFF, no elements will be dropped.")]
        [ValidateSet(
            'OFF',
            'AUTO_PRESERVE_ORDER'
        )]
        [string]$PromptTruncation,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Used to reduce repetitiveness of generated tokens. The higher the value, the stronger a penalty is applied to previously present tokens, proportional to how many times they have already appeared in the prompt or prior generation.')]
        [ValidateRange(0.0, 1.0)]
        [float]$FrequencyPenalty,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Used to reduce repetitiveness of generated tokens. Similar to frequency_penalty, except that this penalty is applied equally to all tokens that have already appeared, regardless of their exact frequencies.')]
        [ValidateRange(0.0, 1.0)]
        [float]$PresencePenalty,

        [Parameter(Mandatory = $false,
            HelpMessage = 'If specified, the backend will make a best effort to sample tokens deterministically, such that repeated requests with the same seed and parameters should return the same result. However, determinism cannot be totally guaranteed.')]
        [int]$Seed,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify true to return the full prompt that was sent to the model. The default value is false. In the response, the prompt in the prompt field.')]
        [bool]$ReturnPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of available tools (functions) that the model may suggest invoking before producing a text response.')]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ToolsResultsSet',
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject[]]$ToolsResults,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = "Specify true, to send the user's message to the model without any preprocessing, otherwise false.")]
        [bool]$RawPrompting,

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

    $modelInfo = $script:cohereModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    # no matter what, message, or message + chat history, we will always pass the message to the model
    # the difference is that if chat history is provided, we will use that instead of the global context
    # if chat history is provided, we will not store the message in the global context
    # if chat history is not provided, we will store the message in the global context
    # if chat history is not provided, we will still pass ChatHistory to the model using the global context
    # if chat history is provided, we will pass ChatHistory to the model using the provided chat history

    #region cmdletParams

    # if ToolsResults is passed, Tools must also be passed
    if ($PSCmdlet.ParameterSetName -eq 'ToolsResultsSet' -and -not $Tools) {
        throw 'Tools must be passed if ToolsResults are passed.'
    }

    # we don't need to pass the message if we are only passing tools results
    if ($PSCmdlet.ParameterSetName -ne 'ToolsResultsSet') {
        $bodyObj = @{
            message = $Message
        }
    }
    else {
        $bodyObj = @{}
    }

    if ($Tools) {
        Write-Debug -Message 'Tools provided.'
        # Tools - must be formed properly
        $toolsEval = Test-CohereCommandRTool -Tools $Tools
        if ($toolsEval -ne $true) {
            throw 'Tools validation failed.'
        }
        $bodyObj.Add('tools', $Tools)
    }

    if ($ToolsResults) {
        Write-Debug -Message 'ToolsResults provided.'
        # ToolsResults - must be formed properly
        $toolsResultsEval = Test-CohereCommandRToolResult -ToolResults $ToolsResults
        if ($toolsResultsEval -ne $true) {
            throw 'Tool results validation failed.'
        }
        $bodyObj.Add('tool_results', $ToolsResults)
    }

    # if the user has provided a chat history, we will use that instead of the global context
    if ($ChatHistory) {

        # ChatHistory - must be formed properly
        $chatHistoryEval = Test-CohereCommandRChatHistory -ChatHistory $ChatHistory
        if ($chatHistoryEval -ne $true) {
            throw 'Chat history validation failed.'
        }

        # reset the global context
        Reset-ModelContext -ModelID $ModelID

        $bodyObj.Add('chat_history', $ChatHistory)
    }
    else {
        # this part is tricky. we only add the chat history if the global context is not empty
        # this is because if this is the first message to the model, we don't want to pass an empty chat history
        # also, the caller may be using the NoContextPersist parameter each time, so we need to account for that
        $contextEval = Get-ModelContext -ModelID $ModelID
        if ($contextEval) {
            $bodyObj.Add('chat_history', $contextEval)
        }

    }

    if ($Documents) {
        $bodyObj.Add('documents', $Documents)
    }

    if ($SearchQueriesOnly) {
        $bodyObj.Add('search_queries_only', $SearchQueriesOnly)
    }

    if ($Preamble) {
        $bodyObj.Add('preamble', $Preamble)
    }

    if ($MaxTokens) {
        $bodyObj.Add('max_tokens', $MaxTokens)
    }

    if ($Temperature) {
        $bodyObj.Add('temperature', $Temperature)
    }

    if ($TopP) {
        $bodyObj.Add('p', $TopP)
    }

    if ($TopK) {
        $bodyObj.Add('k', $TopK)
    }

    if ($PromptTruncation) {
        $bodyObj.Add('prompt_truncation', $PromptTruncation)
    }

    if ($FrequencyPenalty) {
        $bodyObj.Add('frequency_penalty', $FrequencyPenalty)
    }

    if ($PresencePenalty) {
        $bodyObj.Add('presence_penalty', $PresencePenalty)
    }

    if ($Seed) {
        $bodyObj.Add('seed', $Seed)
    }

    if ($ReturnPrompt) {
        $bodyObj.Add('return_prompt', $ReturnPrompt)
    }

    if ($StopSequences) {
        $bodyObj.Add('stop_sequences', $StopSequences)
    }

    if ($RawPrompting) {
        $bodyObj.Add('raw_prompting', $RawPrompting)
    }

    $jsonBody = $bodyObj | ConvertTo-Json -Depth 10
    [byte[]]$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

    $cmdletParams = @{
        ContentType = 'application/json'
        ModelId     = $ModelID
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
        Write-Error $_
        throw
    }

    Write-Debug -Message 'Response JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    Write-Verbose -Message 'Converting response from JSON.'
    $response = $jsonBody | ConvertFrom-Json

    if ([string]::IsNullOrWhiteSpace($response.text)) {
        if ($MaxTokens -lt 150) {
            Write-Warning -Message 'In some cases, the model may return an empty response when the max tokens is set to a low value.'
            Write-Warning -Message ('MaxTokens on this call was set to {0}.' -f $MaxTokens)
            Write-Warning -Message 'Try increasing the MaxTokens value and try again.'
        }
        throw ('No response text was returned from model API: {0}' -f $ModelID)
    }

    Write-Verbose -Message 'Calculating cost estimate.'
    if ($PSCmdlet.ParameterSetName -eq 'ToolsResultsSet') {
        # convert the tools results to a string for the cost estimate
        $Message = $ToolsResults | ConvertTo-Json -Depth 10
    }
    Add-ModelCostEstimate -Usage $response -Message $Message -ModelID $ModelID

    # in this model, the full chat history is returned in the response
    if ($NoContextPersist -eq $false -and -Not ([string]::IsNullOrWhiteSpace($response.text))) {
        Write-Verbose -Message 'Adding response to model context history.'
        Reset-ModelContext -ModelID $ModelID
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context.Add($response.chat_history)
    }

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $response.text
    }

} #Invoke-CohereCommandRModel
