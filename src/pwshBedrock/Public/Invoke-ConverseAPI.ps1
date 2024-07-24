<#
.SYNOPSIS
    Sends messages, media, or documents to a model via the Converse API and returns the response.
.DESCRIPTION
    Uses the Converse API to send messages, media, or documents to a model and returns the response.
    Converse provides a consistent interface that works with most models that support messages.
    This allows you to write code once and use it with different models. It also provides a consistent response format for each model.
    This function supports a base set of inference parameters that are common to all models.
    If you need to pass additional parameters that the model supports, use the AdditionalModelRequestField parameter.
    Not all models support all capabilities. Consult the Converse API documentation to determine what is supported by the model you are using.
.EXAMPLE
    Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1

    Sends a message to the on-demand specified model via the Converse API in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1 -ReturnFullObject

    Sends a message to the on-demand specified model via the Converse API in the specified AWS region and returns the full response object.
.EXAMPLE
    $additionalParams = [PSObject]@{
        top_k = 200
    }
    Invoke-ConverseAPI -ModelID anthropic.claude-3-sonnet-20240229-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -AdditionalModelRequestField $additionalParams -Region us-west-2

    Sends a message to the on-demand specified model via the Converse API. Additional parameters not natively supported by Converse API are passed in that are supported by the model.
.EXAMPLE
    $invokeConverseAPISplat = @{
        Message      = 'Explain zero-point energy.'
        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
        SystemPrompt = 'You are a physicist explaining zero-point energy to a layperson.'
        Credential   = $awsCredential
        Region       = 'us-west-2'
    }
    Invoke-ConverseAPI @invokeConverseAPISplat

    Sends a message to the on-demand specified model via the Converse API. A system prompt is provided to set the context for the model.
.EXAMPLE
    $invokeConverseAPISplat = @{
        Message          = 'Explain zero-point energy.'
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        SystemPrompt     = 'You are a physicist explaining zero-point energy to a layperson.'
        StopSequences    = @('Finished')
        MaxTokens        = 200
        Temperature      = 0.5
        TopP             = 0.9
        Credential       = $awsCredential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    Invoke-ConverseAPI @invokeConverseAPISplat

    Sends a message to the on-demand specified model via the Converse API. Additional parameters are provided to control the response generation.
.EXAMPLE
    $invokeConverseAPISplat = @{
        Message          = 'Please describe the painting in the attached image.'
        MediaPath        = $pathToMediaFile
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        ReturnFullObject = $true
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    Invoke-ConverseAPI @invokeConverseAPISplat

    Sends a media vision message to the on-demand specified model via the Converse API. The model will describe the image in the media file.
.EXAMPLE
    $invokeConverseAPISplat = @{
        Message          = 'Provide a one sentence summary of the document.'
        DocumentPath     = $pathToDocumentFile
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    Invoke-ConverseAPI @invokeConverseAPISplat

    Sends a document message to the on-demand specified model via the Converse API. The model will provide a one sentence summary of the document.
.EXAMPLE
    $tools = [PSCustomObject]@{
        Name        = 'restaurant'
        Description = 'This tool will look up restaurant information in a provided geographic area.'
        Properties  = @{
            location = [PSCustomObject]@{
                type        = 'string'
                description = 'The geographic location or locale. This could be a city, state, country, or full address.'
            }
        }
        required    = @(
            'location'
        )
    }
    $invokeConverseAPISplat = @{
        Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        SystemPrompt     = 'You are a savvy foodie who loves giving restaurant recommendations.'
        ReturnFullObject = $true
        Tools            = $tools
        ToolChoice       = 'tool'
        ToolName         = 'restaurant'
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    $response = Invoke-ConverseAPI @invokeConverseAPISplat

    Sends a message to the on-demand specified model via the Converse API. A tool is provided to answer the user's question.
    Additional parameters are provided to require the use of the tool and to specify the tool to use.
    This will prompt the model to return a tool-based response.
.EXAMPLE
    $tools = [PSCustomObject]@{
        Name        = 'restaurant'
        Description = 'This tool will look up restaurant information in a provided geographic area.'
        Properties  = @{
            location = [PSCustomObject]@{
                type        = 'string'
                description = 'The geographic location or locale. This could be a city, state, country, or full address.'
            }
        }
        required    = @(
            'location'
        )
    }
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
    $invokeConverseAPISplat = @{
        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
        Tools        = $tools
        ToolsResults = $toolsResults
        Credential   = $awsCredential
        Region       = 'us-west-2'
    }
    Invoke-ConverseAPI @invokeConverseAPISplat

    Sends a message to the on-demand specified model via the Converse API. A tool result is provided to the model to answer the user's question.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER MediaPath
    File path to local media file.
    Up to 20 media files can be sent in a single request. The media files must adhere to the model's media requirements.
.PARAMETER DocumentPath
    File path to local document.
    You can include up to five documents. The document(s) must adhere to the model's document requirements.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER NoContextPersist
    Do not persist the conversation context history.
.PARAMETER MaxTokens
    The maximum number of tokens to allow in the generated response.
.PARAMETER StopSequences
    A list of stop sequences. A stop sequence is a sequence of characters that causes the model to stop generating the response.
.PARAMETER Temperature
    The likelihood of the model selecting higher-probability options while generating a response.
.PARAMETER TopP
    The percentage of most-likely candidates that the model considers for the next token.
.PARAMETER SystemPrompt
    Sets the behavior and context for the model in the conversation.
    This field is not supported by all models.
.PARAMETER Tools
    Definitions of tools that the model may use.
    This field is not supported by all models.
.PARAMETER ToolChoice
    In some cases, you may want to use a specific tool to answer the user’s question, even if the model thinks it can provide an answer without using a tool.
    auto - allows model to decide whether to call any provided tools or not. This is the default value.
    any - tells model that it must use one of the provided tools, but doesn’t force a particular tool.
    tool - force model to always use a particular tool.
        if you specify tool, you must also provide the ToolName of the tool you want model to use.
    This field is not supported by all models.
.PARAMETER ToolName
    Optional parameter - The name of the tool that model should use to answer the user’s question.
    This parameter is only required if you set the ToolChoice parameter to tool.
    This field is not supported by all models.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.PARAMETER GuardrailID
    The identifier for the guardrail. This is the id for the guardrail you have created in the Amazon Bedrock console.
    Note: Guardrails are specific to the region in which they are created.
    If you specify a guardrail, you must also specify the GuardrailVersion and GuardrailTrace parameters.
.PARAMETER GuardrailVersion
    The version of the guardrail. This is the version of the guardrail you have created in the Amazon Bedrock console.
    Acceptable values are a positive integer or the string 'DRAFT'.
    If you specify a GuardrailVersion, you must also specify the GuardrailID and GuardrailTrace parameters
.PARAMETER GuardrailTrace
    The trace behavior for the guardrail.
    If you specify a GuardrailTrace, you must also specify the GuardrailID and GuardrailVersion parameters.
.PARAMETER AdditionalModelRequestField
    Additional inference parameters that the model supports, beyond the base set of inference parameters that Converse supports.
.PARAMETER AdditionalModelResponseFieldPath
    Additional model parameters field paths to return in the response.
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
    Amazon.BedrockRuntime.Model.ConverseResponse
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    This was incredibly hard to make.

    * Note: parameter value ranges such as TopP, Temperature, and MaxTokens are model-specific. This function does not validate the values provided against the model's requirements.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-ConverseAPI/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InferenceConfiguration.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-converse-api.html
#>
function Invoke-ConverseAPI {
    [CmdletBinding(
        DefaultParameterSetName = 'MessageSet'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            # 'ai21.j2-grande-instruct', # *note: not supported by Converse API
            # 'ai21.j2-jumbo-instruct', # *note: not supported by Converse API
            'ai21.jamba-instruct-v1:0',
            # 'ai21.j2-mid-v1', # *note: not supported by Converse API
            # 'ai21.j2-ultra-v1', # *note: not supported by Converse API
            # 'amazon.titan-image-generator-v1', # *note: not supported by Converse API
            'amazon.titan-text-express-v1',
            'amazon.titan-text-lite-v1',
            'amazon.titan-text-premier-v1:0',
            'amazon.titan-tg1-large',
            'anthropic.claude-v2:1',
            'anthropic.claude-3-haiku-20240307-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0',
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0',
            # 'cohere.command-text-v14', # *note: not supported by Converse API
            # 'cohere.command-light-text-v14', # *note: not supported by Converse API
            'cohere.command-r-v1:0',
            'cohere.command-r-plus-v1:0',
            'meta.llama2-13b-chat-v1',
            'meta.llama2-70b-chat-v1',
            'meta.llama3-70b-instruct-v1:0',
            'meta.llama3-8b-instruct-v1:0',
            'mistral.mistral-7b-instruct-v0:2',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mixtral-8x7b-instruct-v0:1'
            # 'stability.stable-diffusion-xl-v1' # *note: not supported by Converse API
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false, ParameterSetName = 'MessageSet',
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.',
            ParameterSetName = 'MessageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$MediaPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local document.',
            ParameterSetName = 'MessageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$DocumentPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned instead of just the message reply.')]
        [switch]$ReturnFullObject,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [switch]$NoContextPersist,

        #_____________________________________________________________________________________
        # base set of inference parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to allow in the generated response.')]
        [int]$MaxTokens,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of stop sequences. A stop sequence is a sequence of characters that causes the model to stop generating the response.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The likelihood of the model selecting higher-probability options while generating a response.')]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The percentage of most-likely candidates that the model considers for the next token.')]
        [float]$TopP,
        #_____________________________________________________________________________________
        # model parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'Sets the behavior and context for the model in the conversation.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies how tool functions are called.')]
        [ValidateSet('auto', 'any', 'tool')]
        [string]$ToolChoice,

        [Parameter(Mandatory = $false,
            HelpMessage = "The name of the tool that model should use to answer the user's question.")]
        [string]$ToolName,

        [Parameter(Mandatory = $true, ParameterSetName = 'ToolsResultsSet',
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [ValidateNotNull()]
        [PSCustomObject[]]$ToolsResults,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The identifier for the guardrail.')]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string]$GuardrailID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The version of the guardrail. ')]
        [ValidatePattern('^([1-9][0-9]{0,7})|(DRAFT)$')]
        [string]$GuardrailVersion,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The trace behavior for the guardrail.')]
        [ValidateSet('enabled', 'disabled')]
        [string]$GuardrailTrace,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Additional inference parameters that the model supports, beyond the base set of inference parameters that Converse supports.')]
        [PSObject]$AdditionalModelRequestField,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Additional model parameters field paths to return in the response.')]
        [string[]]$AdditionalModelResponseFieldPath,
        #_____________________________________________________________________________________
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

    $modelInfo = Get-ModelInfo -ModelID $ModelID
    Write-Debug -Message 'Using Converse API to call model.'
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if ($SystemPrompt -and $modelInfo.SystemPrompt -eq $false) {
        throw ('Model {0} does not support system prompts.' -f $ModelID)
    }

    if ($Tools -and $modelInfo.ToolUse -eq $false) {
        throw ('Model {0} does not support tools use.' -f $ModelID)
    }

    if ($ToolChoice -eq 'tool' -and [string]::IsNullOrWhiteSpace($ToolName)) {
        throw 'ToolName must be specified when ToolChoice is set to tool.'
    }

    if ($PSBoundParameters.ContainsKey('GuardrailID') -or
        $PSBoundParameters.ContainsKey('GuardrailVersion') -or
        $PSBoundParameters.ContainsKey('GuardrailTrace')) {
        # Ensure that all three specific parameters are provided
        Write-Debug -Message ($PSBoundParameters | Out-String)
        if (-not ($PSBoundParameters.ContainsKey('GuardrailID')) -or
            -not ($PSBoundParameters.ContainsKey('GuardrailVersion')) -or
            -not ($PSBoundParameters.ContainsKey('GuardrailTrace'))) {
            throw 'If any of the GuardrailID, GuardrailVersion, or GuardrailTrace parameters are provided, all three must be provided.'
        }
        $guardrailUse = $true
    }

    Write-Debug -Message ('Parameter Set: {0}' -f $PSCmdlet.ParameterSetName)
    if ($PSCmdlet.ParameterSetName -eq 'MessageSet') {

        if ($MediaPath) {
            Write-Debug -Message 'Media path provided.'

            if ($modelInfo.Vision -ne $true) {
                Write-Warning -Message ('You provided a media path for model {0}. Vision is not supported for this model.' -f $ModelID)
                throw 'Vision is not supported for this model.'
            }

            Write-Debug -Message ('Media Path Count: {0}' -f $MediaPath.Count)
            if ($MediaPath.Count -gt 20) {
                throw ('You provided {0} media files. You can only provide up to 20 media files.' -f $MediaPath.Count)
            }

            foreach ($media in $MediaPath) {
                if (-not (Test-ConverseAPIMedia -MediaPath $media)) {
                    throw ('Media test for {0} failed.' -f $media)
                }
            }

            $formatConverseAPISplat = @{
                Role             = 'user'
                ModelID          = 'Converse'
                MediaPath        = $MediaPath
                NoContextPersist = $NoContextPersist
            }
            if ($Message) {
                $formatConverseAPISplat.Add('Message', $Message)
            }
            $formattedUserMessage = Format-ConverseAPI @formatConverseAPISplat
        }
        elseif ($DocumentPath) {
            Write-Debug -Message 'Document path provided.'

            if ($modelInfo.Document -ne $true) {
                Write-Warning -Message ('You provided a document path for model {0}. Document is not supported for this model.' -f $ModelID)
                throw 'Document is not supported for this model.'
            }

            if ($DocumentPath.Count -gt 5) {
                throw ('You provided {0} documents. You can only provide up to 5 documents.' -f $DocumentPath.Count)
            }

            foreach ($document in $DocumentPath) {
                if (-not (Test-ConverseAPIDocument -DocumentPath $document)) {
                    throw ('Document test for {0} failed.' -f $document)
                }
            }

            $formatConverseAPISplat = @{
                Role             = 'user'
                ModelID          = 'Converse'
                DocumentPath     = $DocumentPath
                NoContextPersist = $NoContextPersist
            }
            if ($Message) {
                $formatConverseAPISplat.Add('Message', $Message)
            }
            $formattedUserMessage = Format-ConverseAPI @formatConverseAPISplat
        }
        elseif ($Message) {
            Write-Debug -Message 'Message provided.'

            $formatConverseAPISplat = @{
                Role             = 'user'
                Message          = $Message
                ModelID          = 'Converse'
                NoContextPersist = $NoContextPersist
            }
            $formattedUserMessage = Format-ConverseAPI @formatConverseAPISplat
        }
        else {
            throw 'You must provide either a message, media path, or document path.'
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ToolsResultsSet') {
        Write-Debug -Message 'ToolsResultsSet'

        # ToolsResults - must be formed properly
        $toolsResultsEval = Test-ConverseAPIToolResult -ToolResults $ToolsResults
        if ($toolsResultsEval -ne $true) {
            throw 'Tool results validation failed.'
        }
        foreach ($toolResult in $ToolsResults) {
            $formatConverseAPISplat = @{
                Role             = 'user'
                ToolsResults     = $ToolsResults
                ModelID          = 'Converse'
                NoContextPersist = $NoContextPersist
            }
            $formattedToolsResults += Format-ConverseAPI @formatConverseAPISplat
        }
    }

    if ($NoContextPersist -eq $true) {
        $formattedMessages = @(
            $formattedUserMessage
            $formattedToolsResults
        )
    }
    else {
        $formattedMessages = Get-ModelContext -ModelID 'Converse'
    }

    #region cmdletParams

    <#
    https://docs.aws.amazon.com/powershell/latest/reference/items/Invoke-BDRRConverse.html
    -ModelId <String>
    -AdditionalModelRequestField <PSObject>
    -AdditionalModelResponseFieldPath <String[]>
    -ToolChoice_Any <AnyToolChoice>
    -ToolChoice_Auto <AutoToolChoice>
    -GuardrailConfig_GuardrailIdentifier <String>
    -GuardrailConfig_GuardrailVersion <String>
    -InferenceConfig_MaxToken <Int32>
    -Message <Message[]>
    -Tool_Name <String>
    -InferenceConfig_StopSequence <String[]>
    -System <SystemContentBlock[]>
    -InferenceConfig_Temperature <Single>
    -ToolConfig_Tool <Tool[]>
    -InferenceConfig_TopP <Single>
    -GuardrailConfig_Trace <GuardrailTrace>
    -Select <String>
    -PassThru <SwitchParameter>
    -Force <SwitchParameter>
    -ClientConfig <AmazonBedrockRuntimeConfig>
    #>

    $invokeBDRRConverseSplat = @{
        ModelId = $ModelID
    }
    if ($formattedMessages) {
        $invokeBDRRConverseSplat.Add('Message', $formattedMessages)
    }

    if ($Tools) {
        Write-Debug -Message 'Tools provided.'

        # Tools - must be formed properly
        $toolsEval = Test-ConverseAPITool -Tools $Tools
        if ($toolsEval -ne $true) {
            throw 'Tools validation failed.'
        }

        $allTools = Format-ConverseAPIToolConfig -ToolsConfig $Tools

        $invokeBDRRConverseSplat.Add('ToolConfig_Tool', $allTools)
    }

    <#
    ToolChoice is only supported by Anthropic Claude 3 models and by Mistral AI Mistral Large.
    Error example: Invoke-BDRRConverse: This model doesn't support the toolConfig.toolChoice.any field. Remove toolConfig.toolChoice.any and try again.
    #>
    if ($ToolChoice) {
        switch ($ToolChoice) {
            'any' {
                Write-Debug -Message 'ToolChoice: Any'
                $anyTool = [Amazon.BedrockRuntime.Model.AnyToolChoice]::new()
                $invokeBDRRConverseSplat.Add('ToolChoice_Any', $anyTool)
            }
            'auto' {
                Write-Debug -Message 'ToolChoice: Auto'
                $autoTool = [Amazon.BedrockRuntime.Model.AutoToolChoice]::new()
                $invokeBDRRConverseSplat.Add('ToolChoice_Auto', $autoTool)
            }
            'tool' {
                Write-Debug -Message 'ToolChoice: Tool'
                $invokeBDRRConverseSplat.Add('Tool_Name', $ToolName)
            }
        }
    }

    if ($guardrailUse -eq $true) {
        $invokeBDRRConverseSplat.Add('GuardrailConfig_GuardrailIdentifier', $GuardrailID)
        $invokeBDRRConverseSplat.Add('GuardrailConfig_GuardrailVersion', $GuardrailVersion)
        $guardRailTrace = [Amazon.BedrockRuntime.GuardrailTrace]::new($GuardrailTrace)
        $invokeBDRRConverseSplat.Add('GuardrailConfig_Trace', $guardRailTrace)
    }

    #_____________________________________

    if ($MaxTokens) {
        $invokeBDRRConverseSplat.Add('InferenceConfig_MaxToken', $MaxTokens)
    }

    if ($StopSequences) {
        $invokeBDRRConverseSplat.Add('InferenceConfig_StopSequence', $StopSequences)
    }

    if ($Temperature) {
        $invokeBDRRConverseSplat.Add('InferenceConfig_Temperature', $Temperature)
    }

    if ($TopP) {
        $invokeBDRRConverseSplat.Add('InferenceConfig_TopP', $TopP)
    }

    #_____________________________________

    if ($SystemPrompt) {
        # TODO: Add support for https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/TGuardrailConverseContentBlock.html
        # https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/TSystemContentBlock.html
        $systemContentBlock = [Amazon.BedrockRuntime.Model.SystemContentBlock]::new()
        $systemContentBlock.Text = $SystemPrompt
        $invokeBDRRConverseSplat.Add('System', $systemContentBlock)
    }

    if ($AdditionalModelRequestField) {
        $invokeBDRRConverseSplat.Add('AdditionalModelRequestField', $AdditionalModelRequestField)
    }

    if ($AdditionalModelResponseFieldPath) {
        $invokeBDRRConverseSplat.Add('AdditionalModelResponseFieldPath', $AdditionalModelResponseFieldPath)
    }

    Write-Debug -Message 'Cmdlet Params:'
    Write-Debug -Message ($invokeBDRRConverseSplat | Out-String)

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
        $rawResponse = Invoke-BDRRConverse @invokeBDRRConverseSplat @commonParams -ErrorAction Stop
    }
    catch {
        # we need to remove the user context from the global variable if the model is not successfully engaged
        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'Converse' }
        Write-Debug -Message 'Catch Block. Context:'
        Write-Debug -Message ($context | Out-String)
        Write-Debug -Message ('Context count: {0}' -f $context.Context.Count)
        if ($context.Context.Count -le 1) {
            Write-Debug -Message 'Resetting context.'
            $context.Context = New-Object System.Collections.Generic.List[object]
        }
        else {
            Write-Debug -Message 'Removing context entry.'
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
        elseif ($exceptionMessage -like "*doesn't support the model*") {
            # This action doesn't support the model that you provided. Try again with a supported text or chat model.
            Write-Debug -Message 'Specific Error'
            Write-Warning -Message 'The Converse API does not support all foundational models.'
            throw ('Converse API does not support {0} for this action. Try again with a supported text or chat model.' -f $ModelID)
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

    $response = $rawResponse

    # end_turn | tool_use | max_tokens | stop_sequence | guardrail_intervened | content_filtered
    Write-Debug -Message ('Stop Reason: {0}' -f $response.StopReason)
    # $toolUse = $false
    switch ($response.StopReason) {
        'end_turn' {
            Write-Debug -Message 'End of turn detected.'
        }
        'tool_use' {
            Write-Debug -Message 'Tool calls detected.'
            # $toolUse = $true
        }
        'max_tokens' {
            Write-Debug -Message 'Max tokens reached.'
            Write-Warning -Message ('The model reached the maximum token limit of {0}.' -f $MaxTokens)
        }
        'stop_sequence' {
            Write-Debug -Message 'Stop sequence detected.'
            Write-Warning -Message 'The model stopped generating the response due to a stop sequence.'
        }
        'guardrail_intervened' {
            Write-Debug -Message 'Guardrail intervened.'
            Write-Warning -Message 'The model stopped generating the response due to a guardrail.'
        }
        'content_filtered' {
            Write-Debug -Message 'Content filtered.'
            Write-Warning -Message 'The model stopped generating the response due to content filtering.'
        }
    }

    if ($NoContextPersist -eq $false ) {
        Write-Verbose -Message 'Adding response to model context history.'
        $formatConverseAPISplat = @{
            Role          = 'assistant'
            ReturnMessage = $response.Output.Message
            ModelID       = 'Converse'
        }
        Format-ConverseAPI @formatConverseAPISplat | Out-Null
    }

    Write-Verbose -Message 'Calculating cost estimate.'
    Add-ModelCostEstimate -Usage $response.Usage -ModelID $ModelID -Converse

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $response.Output.Message.Content.Text
    }

} #Invoke-ConverseAPI
