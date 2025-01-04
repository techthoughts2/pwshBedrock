<#
.SYNOPSIS
    Sends message(s) to a Meta model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to a Meta model on the Amazon Bedrock platform and returns the model's response.
    By default the conversation context history is persisted to maintain a continuous interaction with the model.
    You can disable this by using the NoContextPersist parameter.
    The cmdlet also estimates the cost of model usage based on the provided
    input and output tokens and adds the estimate to the models tally information.
.EXAMPLE
    Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama3-2-90b-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2'

    Sends a text message to the on-demand Meta model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama3-2-90b-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand Meta model in the specified AWS region and returns the full response object.
.EXAMPLE
    Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama3-8b-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2' -NoContextPersist

    Sends a text message to the on-demand Meta model in the specified AWS region and returns the response without persisting the conversation context history.
.EXAMPLE
    $invokeMetaModelSplat = @{
        Message          = 'Explain zero-point energy.'
        ModelID          = 'meta.llama3-2-90b-instruct-v1:0'
        MaxTokens        = 2000
        SystemPrompt     = 'You are a deep thinking model with a galactic perspective'
        Credential       = $awsCredential
        Region           = 'us-west-2'
        NoContextPersist = $true
        Verbose          = $false
    }
    Invoke-MetaModel @invokeMetaModelSplat

    Sends a text message to the on-demand Meta model in the specified AWS region with a system prompt and a maximum token limit of 2000.
.EXAMPLE
    Invoke-MetaModel -ImagePrompt 'Describe this image in two sentences.' -ModelID 'meta.llama3-2-11b-instruct-v1:0' -MediaPath 'C:\path\to\image.jpg' -Credential $awsCredential -Region 'us-west-2'

    Sends an image prompt to the Vision-Instruct Meta model in the specified AWS region and returns the response.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ImagePrompt
    The prompt to the Vision-Instruct model.
.PARAMETER MediaPath
    File path to local media file.
    The media files must adhere to the model's media requirements.
    Only large 3.2 vision models support media files.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model. Has no effect if -PromptOnly is specified.
.PARAMETER SystemPrompt
    The system prompt for the request.
    If you do not provide a system prompt, the default Llama system prompt will be used.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
    Defaults to 2048. Ranges from 1 to 2048.
.PARAMETER Temperature
    The amount of randomness injected into the response.
    Defaults to 1.0. Ranges from 0.0 to 1.0.
    Use a lower value to decrease randomness in responses.
.PARAMETER TopP
    Use a lower value to ignore less probable options and decrease the diversity of responses.
.PARAMETER Tools
    A list of available tools (functions) that the model may suggest invoking before producing a text response.
    This must be in a properly formatted PSObject array with all required Tools properties.
    For more information, see the Meta documentation.
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

    If Tools are provided for a 3.1+ model, a new system prompt will be generated with the tools included.
    This means that the context will be RESET when tools are provided. This is because system prompts are created at the beginning of the conversation.
    Start a conversation with tools by providing them in the first message.
    Adding tools to a conversation after the first message will not work as a reset will occur.

    Note: The Meta models require the system prompt to be set at the beginning of the conversation.
    When using the Format-MetaTextMessage and Invoke-MetaModel functions, the system prompt is inserted
    at the start of the conversation context stored in memory. If you modify the system prompt after the
    conversation has begun, the functions will replace the original system prompt in the in-memory context.
    This action does not affect previous exchanges but may influence subsequent interactions.

    Be aware that changing the system prompt mid-conversation can lead to instability or confusion in the model's responses.
    This is particularly significant if you initially used a specialized system prompt to enable tool usage within the conversation.
    Overwriting the system prompt in such cases can disrupt the intended functionality and cause the model to behave unpredictably.

    For consistent and reliable interactions, it is recommended to set your desired system prompt at the onset of the conversation and avoid altering it later.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-MetaModel/
.LINK
    https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html
.LINK
    https://huggingface.co/blog/llama2#how-to-prompt-llama-2
.LINK
    https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-2/
.LINK
    https://github.com/meta-llama/llama/blob/main/MODEL_CARD.md
.LINK
    https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/
.LINK
    https://github.com/meta-llama/llama3/blob/main/MODEL_CARD.md
.LINK
    https://www.llama.com/docs/model-cards-and-prompt-formats/llama3_1
.LINK
    https://github.com/meta-llama/llama-models/blob/main/models/llama3_1/MODEL_CARD.md
.LINK
    https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD.md
.LINK
    https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD_VISION.md
.LINK
    https://www.llama.com/docs/model-cards-and-prompt-formats/llama3_2/
.LINK
    https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/vision_prompt_format.md
.LINK
    https://www.llama.com/docs/how-to-guides/vision-capabilities/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html
#>
function Invoke-MetaModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The message to be sent to the model.',
            ParameterSetName = 'MessageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The prompt to the Vision-Instruct model.',
            ParameterSetName = 'ImageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePrompt,

        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to local media file.',
            ParameterSetName = 'ImageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'meta.llama3-2-90b-instruct-v1:0',
            'meta.llama3-8b-instruct-v1:0',
            'meta.llama3-70b-instruct-v1:0',
            'meta.llama3-1-8b-instruct-v1:0',
            'meta.llama3-1-70b-instruct-v1:0',
            'meta.llama3-1-405b-instruct-v1:0',
            'meta.llama3-2-1b-instruct-v1:0',
            'meta.llama3-2-3b-instruct-v1:0',
            'meta.llama3-2-11b-instruct-v1:0',
            'meta.llama3-2-90b-instruct-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned instead of just the message reply.')]
        [switch]$ReturnFullObject,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [switch]$NoContextPersist,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system prompt for the request.',
            ParameterSetName = 'MessageSet')]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 2048)]
        [int]$MaxTokens = 2048,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.0, 1.0)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'MessageSet',
            HelpMessage = 'A list of available tools (functions) that the model may suggest invoking before producing a text response.')]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $true,
            ParameterSetName = 'ToolsResultsSet',
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject]$ToolsResults,

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

    # if ($ModelID -like 'meta.llama3-2-*') {
    #     Write-Debug -Message '3.2 Model provided. This requires region inference.'
    #     if ($Region -like 'us*') {
    #         Write-Debug -Message 'Region is US. Adding us. to ModelID.'
    #         $processedModelID = 'us.' + $ModelID
    #     }
    #     elseif ($Region -like 'eu*') {
    #         Write-Debug -Message 'Region is EU. Adding eu. to ModelID.'
    #         $processedModelID = 'eu.' + $ModelID
    #     }
    #     else {
    #         Write-Warning -Message 'Only US and EU regions are supported for 3.2 models.'
    #         throw 'Only US and EU regions are supported for 3.2 models.'
    #     }
    # }
    # else {
    #     $processedModelID = $ModelID
    # }

    $modelInfo = $script:metaModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    $bodyObj = @{}

    if ($MediaPath) {
        Write-Verbose -Message 'Vision message with media path provided.'
        if ($modelInfo.Vision -ne $true) {
            Write-Warning -Message ('You provided a media path for model {0}. Vision is not supported for this model.' -f $ModelID)
            throw 'Vision is not supported for this model.'
        }

        foreach ($media in $MediaPath) {
            if (-not (Test-MetaMedia -MediaPath $media)) {
                throw ('Media test for {0} failed.' -f $media)
            }

            Write-Verbose -Message ('Converting media to base64: {0}' -f $media)
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $media
            }
            catch {
                throw ('Unable to convert media to base64: {0}' -f $media)
            }
        }

        $formatMetaTextMessageSplat = @{
            Role             = 'User'
            ImagePrompt      = $ImagePrompt
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        $formattedMessages = Format-MetaTextMessage @formatMetaTextMessageSplat

        $bodyObj.Add('images', @($base64))

    } #MediaPath
    elseif ($Tools) {
        Write-Verbose -Message 'Tools provided.'
        # tools is only supported for models 3.1 and above
        if ($ModelID -like 'meta.llama3-1-*' -or $ModelID -like 'meta.llama3-2-*') {
            Write-Debug -Message 'Model supports tools.'
        }
        else {
            Write-Warning -Message 'Tools are not supported for this model.'
            throw 'Tools are not supported for this model.'
        }
        # Tools - must be formed properly
        $toolsEval = Test-MetaTool -Tools $Tools
        if ($toolsEval -ne $true) {
            throw 'Tools validation failed.'
        }
        else {
            Write-Debug -Message 'Tools validation passed.'
            Write-Debug -Message 'Resetting context due to tools.'
            Reset-ModelContext -ModelID $ModelID
        }

        $formatMetaTextMessageSplat = @{
            Message          = $Message
            Role             = 'ipython'
            Tools            = $Tools
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        $formattedMessages = Format-MetaTextMessage @formatMetaTextMessageSplat
    }
    elseif ($ToolsResults) {
        Write-Verbose -Message 'Tools results provided.'
        # tools is only supported for models 3.1 and above
        if ($ModelID -like 'meta.llama3-1-*' -or $ModelID -like 'meta.llama3-2-*') {
            Write-Debug -Message 'Model supports tools.'
        }
        else {
            Write-Warning -Message 'Tools are not supported for this model.'
            throw 'Tools are not supported for this model.'
        }
        # ToolsResults - must be formed properly
        $toolsResultsEval = Test-MetaToolResult -ToolResults $ToolsResults
        if ($toolsResultsEval -ne $true) {
            throw 'Tools results validation failed.'
        }
        else {
            Write-Debug -Message 'Tools results validation passed.'
            Write-Debug -Message 'Resetting context due to tools results.'
            Reset-ModelContext -ModelID $ModelID
        }

        $formatMetaTextMessageSplat = @{
            Role             = 'ipython'
            ToolsResults     = $ToolsResults
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        $formattedMessages = Format-MetaTextMessage @formatMetaTextMessageSplat
    }
    else {
        Write-Verbose -Message 'Standard Text provided.'
        # before we format the message (which creates context), we need to store the current context
        # this can be used to restore the context if the model fails to respond

        $originalContext = Get-ModelContext -ModelID $ModelID
        if ([string]::IsNullOrEmpty($originalContext)) {
            Write-Debug -Message 'No original context'
            $originalContext = ''
        }

        $formatMetaTextMessageSplat = @{
            Role             = 'User'
            Message          = $Message
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        if ($SystemPrompt) {
            $formatMetaTextMessageSplat.Add('SystemPrompt', $SystemPrompt)
        }
        $formattedMessages = Format-MetaTextMessage @formatMetaTextMessageSplat
    } #Standard_Text

    $bodyObj.Add('prompt', $formattedMessages)

    #region cmdletParams

    if ($Temperature) {
        $bodyObj.Add('temperature', $Temperature)
    }
    if ($TopP) {
        $bodyObj.Add('top_p', $TopP)
    }
    if ($MaxTokens -ne 512) {
        $bodyObj.Add('max_gen_len', $MaxTokens)
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
        # we need to reset the user context if the model fails to respond
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message ($contextObj | Out-String)
        $contextObj.Context = $originalContext

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
        # we need to reset the user context if the model fails to respond
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message ($contextObj | Out-String)
        $contextObj.Context = $originalContext

        Write-Error $_
        throw
    }

    Write-Debug -Message 'Response JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    Write-Verbose -Message 'Converting response from JSON.'
    $response = $jsonBody | ConvertFrom-Json

    if ([string]::IsNullOrWhiteSpace($response.generation)) {
        if ($MaxTokens -lt 150) {
            Write-Warning -Message 'In some cases, the model may return an empty response when the max tokens is set to a low value.'
            Write-Warning -Message ('MaxTokens on this call was set to {0}.' -f $MaxTokens)
            Write-Warning -Message 'Try increasing the MaxTokens value and try again.'
        }
        throw ('No response text was returned from model API: {0}' -f $ModelID)
    }

    Write-Verbose -Message 'Calculating cost estimate.'
    Add-ModelCostEstimate -Usage $response -ModelID $ModelID

    Write-Verbose -Message 'Adding response to model context history.'
    $content = $response.generation

    if ($content -like '*<function=*</function>*') {
        $functionReturn = $true
        Write-Debug -Message 'Function detected in response.'
        $role = 'ipython'
        # we need to retrieve just the json from the function return like: <function=spotify_trending_songs>{"n": 5}</function>
        $jsonFunctionContent = [regex]::Match($content, '<function=.*?>(.*?)</function>').Groups[1].Value
        $response.generation = $jsonFunctionContent
    }
    else {
        Write-Debug -Message 'No function detected in response.'
        $functionReturn = $false
        $role = 'Model'
    }
    $formatMetaTextMessageSplat = @{
        Role             = $role
        Message          = $content
        ModelID          = $ModelID
        NoContextPersist = $NoContextPersist
    }
    if ($SystemPrompt) {
        $formatMetaTextMessageSplat.Add('SystemPrompt', $SystemPrompt)
    }
    Format-MetaTextMessage @formatMetaTextMessageSplat | Out-Null

    if ($ReturnFullObject) {
        return $response
    }
    else {
        if ($functionReturn -eq $true) {
            return $jsonFunctionContent
        }
        else {
            return $content
        }
    }

} #Invoke-MetaModel
