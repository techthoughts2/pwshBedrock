<#
.SYNOPSIS
    Sends message(s) to an Amazon Nova model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an Amazon Nova model on the Amazon Bedrock platform and returns the model's response.
    You can send both text and media messages to the model. If a media file is specified, it is converted to base64 according to the model's requirements.
    By default, the conversation context history is persisted to maintain a continuous interaction with the model.
    You can disable this by using the NoContextPersist parameter. Additionally, the cmdlet estimates the cost of model usage
    based on the provided input and output tokens and adds the estimate to the models tally information.
    This model supports Function Calling, which allows the Amazon Nova model to connect to external tools.
    You can provide the Tools parameter to specify the tools that the model may use and how.
    If you are providing Tools to enable Function Calling, it is recommended that you use the ReturnFullObject parameter to capture the full response object.
    See the pwshBedrock documentation for more information on Function Calling and the Amazon Nova model.
.EXAMPLE
    Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-east-1'

    Sends a text message to the on-demand Amazon Nova model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand Amazon Nova model in the specified AWS region and returns the full response object.
.EXAMPLE
    Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-west-2' -NoContextPersist

    Sends a text message to the on-demand Amazon Nova model in the specified AWS region without persisting the conversation context history. This is useful for one-off interactions.
.EXAMPLE
    $invokeAmazonNovaTextModelSplat = @{
        Message          = 'Can you name all of the Star Fleet captains featured in the various shows over the years?'
        ModelID          = 'amazon.nova-pro-v1:0'
        SystemPrompt     = 'You are an expert on all things Star Trek, having studied the show for decades. You often win Star Trek Trivia contests and enjoy sharing your vast knowledge of Star Trek with others.'
        Tools            = $starTrekTriviaFunctionTool
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $objReturn = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat

    Sends a text message to the on-demand Amazon Nova model in the specified AWS region with a system prompt and returns the response. A system prompt is provided to give additional context to the model on how to respond. A tool is provided to the model to use if needed. The tool choice is set to auto, allowing the model to decide if it should use the tool. The tool is a function that provides Star Trek trivia information.
.EXAMPLE
    $invokeAmazonNovaTextModelSplat = @{
        Message          = 'What do you see in this photo?'
        MediaPath        = 'C:\path\to\image.jpg'
        ModelID          = 'amazon.nova-pro-v1:0'
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $response = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
    $response.output.message.content.text

    Sends a text message with a image media file to the on-demand Amazon Nova model in the specified AWS region and returns the response.
    .EXAMPLE
    $invokeAmazonNovaTextModelSplat = @{
        Message          = 'What do you see in this video?'
        MediaPath        = 'C:\path\to\video.mp4'
        ModelID          = 'amazon.nova-pro-v1:0'
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $response = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
    $response.output.message.content.text

    Sends a text message with a video media file to the on-demand Amazon Nova model in the specified AWS region and returns the response.
    .EXAMPLE
    $invokeAmazonNovaTextModelSplat = @{
        Message          = 'Summarize the document in three sentences'
        MediaPath        = 'C:\path\to\document.pdf'
        ModelID          = 'amazon.nova-pro-v1:0'
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $response = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
    $response.output.message.content.text

    Sends a text message with a document media file to the on-demand Amazon Nova model in the specified AWS region and returns the response.
.EXAMPLE
    $customMessage = @(
        [PSCustomObject]@{
            role    = 'user'
            content = @(
                [PSCustomObject]@{
                    text = 'Explain zero-point energy.'
                }
            )
        }
        [PSCustomObject]@{
            role    = 'assistant'
            content = @(
                [PSCustomObject]@{
                    text = 'It is when someone in basketball is having a really bad game.'
                }
            )
        }
        [PSCustomObject]@{
            role    = 'user'
            content = @(
                [PSCustomObject]@{
                    text = 'No, as it relates to physics.'
                }
            )
        }
    )
    $invokeAmazonNovaTextModelSplat = @{
        CustomConversation = $customMessage
        ModelID            = 'amazon.nova-pro-v1:0'
        Credential         = $credential
        Region             = 'us-east-1'
    }
    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat

    Sends a custom conversation to the on-demand Amazon Nova model in the specified AWS region and returns the response.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER MediaPath
    File path to local media file.
    The media files must adhere to the model's media requirements.
.PARAMETER S3Location
    The S3 location of the media file.
    This parameter is only supported if providing a video file to the model.
    The video file must adhere to the model's media requirements.
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
.PARAMETER SystemPrompt
    The system prompt for the request.
.PARAMETER Temperature
    The amount of randomness injected into the response.
    Defaults to 1.0. Ranges from 0.0 to 1.0.
    Use a lower value to decrease randomness in responses.
.PARAMETER TopP
    Use a lower value to ignore less probable options and decrease the diversity of responses.
.PARAMETER TopK
    Only sample from the top K options for each subsequent token.
    Use top_k to remove long tail low probability responses.
    Recommended for advanced use cases only. You usually only need to use temperature.
.PARAMETER StopSequences
    Custom text sequences that cause the model to stop generating.
.PARAMETER Tools
    Definitions of tools that the model may use.
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
    https://www.pwshbedrock.dev/en/latest/Invoke-AmazonNovaTextModel/
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/complete-request-schema.html
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/tool-use-results.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/modalities-image.html
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/modalities-document.html
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/modalities-video.html
#>
function Invoke-AmazonNovaTextModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $true,
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

        # TODO: Implement S3Location for video files
        # [Parameter(Mandatory = $false,
        #     HelpMessage = 'The S3 location of the media file.',
        #     ParameterSetName = 'Standard')]
        # [ValidateNotNull()]
        # [ValidateNotNullOrEmpty()]
        # [string]$S3Location,

        [Parameter(Mandatory = $true,
            HelpMessage = 'An array of custom conversation objects.',
            ParameterSetName = 'PreCraftedMessages')]
        [ValidateNotNull()]
        [PSCustomObject[]]$CustomConversation,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'amazon.nova-pro-v1:0',
            'amazon.nova-lite-v1:0',
            'amazon.nova-micro-v1:0'
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
        [ValidateRange(1, 5000)]
        [int]$MaxTokens = 5000,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system prompt for the request.')]
        [ValidateNotNullOrEmpty()]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.0, 1.0)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Only sample from the top K options for each subsequent token.')]
        [ValidateRange(0, 1.0)]
        [int]$TopK,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools,

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

    $modelInfo = $script:amazonModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if ($MediaPath -and $S3Location) {
        throw 'Both MediaPath and S3Location cannot be provided. Please provide only one.'
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Standard' {
            if ($MediaPath) {
                Write-Verbose -Message 'Vision message with media path provided.'
                if ($modelInfo.Vision -ne $true) {
                    Write-Warning -Message ('You provided a media path for model {0}. Vision is not supported for this model.' -f $ModelID)
                    throw 'Vision is not supported for this model.'
                }

                foreach ($media in $MediaPath) {
                    if (-not (Test-AmazonNovaMedia -MediaPath $media)) {
                        throw ('Media test for {0} failed.' -f $media)
                    }
                }

                $formatAmazonNovaMessageSplat = @{
                    Role             = 'user'
                    Message          = $Message
                    ModelID          = $ModelID
                    MediaPath        = $MediaPath
                    NoContextPersist = $NoContextPersist
                }
                $formattedMessages = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
            }
            elseif ($Message) {
                Write-Verbose -Message 'Standard message provided.'
                $formatAmazonNovaMessageSplat = @{
                    Role             = 'user'
                    Message          = $Message
                    ModelID          = $ModelID
                    NoContextPersist = $NoContextPersist
                }
                $formattedMessages = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
            }
            else {
                throw 'You must provide either a message or media path.'
            }
        } #Standard
        'PreCraftedMessages' {
            Write-Verbose -Message 'Custom conversation provided'
            $conversationEval = Test-AmazonNovaCustomConversation -CustomConversation $CustomConversation
            if ($conversationEval -ne $true) {
                throw 'Custom conversation validation failed.'
            }
            else {
                $formattedMessages = $CustomConversation
            }
        } #PreCraftedMessages
        'ToolsResultsSet' {
            Write-Verbose -Message 'Tools results provided'

            if (-not $Tools) {
                throw 'Tools must be provided when ToolsResults are provided.'
            }

            $toolsResultsEval = Test-AmazonNovaToolResult -ToolResults $ToolsResults
            if ($toolsResultsEval -ne $true) {
                throw 'Tools results validation failed.'
            }
            else {
                foreach ($toolResult in $ToolsResults) {
                    $formatAmazonNovaMessageSplat = @{
                        Role             = 'user'
                        ToolsResults     = $ToolsResults
                        ModelID          = $ModelID
                        NoContextPersist = $NoContextPersist
                    }
                    $formattedMessages = Format-AmazonNovaMessage @formatAmazonNovaMessageSplat
                }
            }
        } #ToolsResultsSet
    } #switch

    #region cmdletParams

    Write-Debug -Message 'Forming body object.'

    $bodyObj = @{
        messages = @(
            $formattedMessages
        )
    }

    if ($SystemPrompt) {
        $systemPromptObj = @(
            [PSCustomObject]@{
                text = $SystemPrompt
            }
        )
        $bodyObj.Add('system', $systemPromptObj)
    }
    if ($MaxTokens -or $Temperature -or $TopP -or $TopK -or $StopSequences) {
        $bodyObj.Add('inferenceConfig', @{})
    }
    if ($MaxTokens) {
        $bodyObj.inferenceConfig.Add('max_new_tokens', $MaxTokens)
    }
    if ($Temperature) {
        $bodyObj.inferenceConfig.Add('temperature', $Temperature)
    }
    if ($TopP) {
        $bodyObj.inferenceConfig.Add('top_p', $TopP)
    }
    if ($TopK) {
        $bodyObj.inferenceConfig.Add('top_k', $TopK)
    }
    if ($StopSequences) {
        $bodyObj.inferenceConfig.Add('stopSequences', $StopSequences)
    }
    if ($Tools) {
        Write-Debug -Message 'Tools provided.'

        $toolsEval = Test-AmazonNovaTool -Tools $Tools
        if ($toolsEval -ne $true) {
            throw 'Tools validation failed.'
        }
        $formattedToolsConfig = Format-AmazonNovaToolConfig -ToolsConfig $Tools
        $toolsObj = [PSCustomObject]@{
            tools      = @(
                $formattedToolsConfig
            )
            toolChoice = @{
                auto = @{}
            }
        }
        $bodyObj.Add('toolConfig', $toolsObj)
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

    if ($response.stopReason -eq 'tool_use') {
        Write-Debug -Message 'Tool use detected.'
        $formatAmazonNovaMessageSplat = @{
            Role             = 'assistant'
            ToolCall         = $response.output.message.content.toolUse
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        Format-AmazonNovaMessage @formatAmazonNovaMessageSplat | Out-Null
    }
    else {
        Write-Debug -Message ('Stop Reason: {0}' -f $response.stopReason)

        if ([string]::IsNullOrWhiteSpace($response.output.message.content.text)) {
            if ($MaxTokens -lt 150) {
                Write-Warning -Message 'In some cases, the model may return an empty response when the max tokens is set to a low value.'
                Write-Warning -Message ('MaxTokens on this call was set to {0}.' -f $MaxTokens)
                Write-Warning -Message 'Try increasing the MaxTokens value and try again.'
            }
            throw ('No response text was returned from model API: {0}' -f $ModelID)
        }

        $content = $response.output.message.content.text
        $formatAmazonNovaMessageSplat = @{
            Role             = 'assistant'
            Message          = $content
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        Format-AmazonNovaMessage @formatAmazonNovaMessageSplat | Out-Null
    }

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $content
    }

} #Invoke-AmazonNovaTextModel
