﻿<#
.SYNOPSIS
    Sends message(s) to an Amazon Titan model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an Amazon Titan model on the Amazon Bedrock platform and returns the model's response.
    By default, a conversation prompt style is used and the conversation context history is persisted to maintain a continuous interaction with the model.
    You can disable this by using the NoContextPersist parameter.
    Alternatively, you can use the PromptOnly parameter to have a less conversational response.
    Additionally, the cmdlet estimates the cost of model usage based on the provided
    input and output tokens and adds the estimate to the models tally information.
.EXAMPLE
    Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -Credential $awsCredential -Region 'us-west-2'

    Sends a text message to the on-demand Amazon Titan model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -ProfileName default -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand Amazon Titan model in the specified AWS region and returns the full response object.
.EXAMPLE
    Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -ProfileName default -Region 'us-west-2' -NoContextPersist

    Sends a text message to the on-demand Amazon Titan model in the specified AWS region without persisting the conversation context history. This is useful for one-off interactions.
.EXAMPLE
    Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -ProfileName default -Region 'us-west-2' -PromptOnly

    Sends a text message to the on-demand Amazon Titan model in the specified AWS region with a less conversational response. No conversation context history is persisted.
.EXAMPLE
    $customConversation = @'
User: How are you?
Bot: I am doing well, thank you. How can I help you today?
User: Tell me about Klingon culture.
Bot: Worf is the son of Mogh.
User: No, don't tell me about Worf. Tell me about Klingon culture.
'@
    Invoke-AmazonTextModel -CustomConversation $customConversation -ModelID amazon.titan-text-lite-v1 -ProfileName default -Region 'us-west-2'

    Sends a custom conversation to the on-demand Amazon Titan model in the specified AWS region and returns the response.
.EXAMPLE
    $invokeAmazonTextModelSplat = @{
        Message          = 'Explain zero-point energy.'
        ModelID          = 'amazon.titan-text-lite-v1'
        Temperature      = 0.5
        MaxTokens        = 256
        Credential       = $credential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    Invoke-AmazonTextModel @invokeAmazonTextModelSplat

    Sends a text message to the on-demand Amazon Titan model in the specified AWS region with a temperature of 0.5 and a maximum of 256 tokens generated. The full response object is returned.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER CustomConversation
    A properly formatted string that represents a custom conversation.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER PromptOnly
    When specified, the model will have a less conversational response. It will also not persist the conversation context history.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model. Has no effect if -PromptOnly is specified.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
.PARAMETER Temperature
    The amount of randomness injected into the response.
    Defaults to 1.0. Ranges from 0.0 to 1.0.
    Use a lower value to decrease randomness in responses.
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
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-AmazonTextModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-text.html
#>
function Invoke-AmazonTextModel {
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

        [Parameter(Mandatory = $true,
            HelpMessage = 'A properly formatted string that represents a custom conversation.',
            ParameterSetName = 'PreCraftedMessages')]
        [ValidateNotNull()]
        [string]$CustomConversation,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'amazon.titan-text-lite-v1',
            'amazon.titan-text-express-v1',
            'amazon.titan-text-premier-v1:0',
            'amazon.titan-tg1-large'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned instead of just the message reply.')]
        [switch]$ReturnFullObject,

        [Parameter(Mandatory = $false,
            HelpMessage = 'When specified, the model will have a less conversational response. It will also not persist the conversation context history.')]
        [switch]$PromptOnly,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [switch]$NoContextPersist,

        # model parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 8192)]
        [int]$MaxTokens = 8192,

        # ! Open issue preventing use of StopSequences parameter
        # https://github.com/aws/aws-sdk/issues/692
        # [Parameter(Mandatory = $false,
        #     HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        # [ValidateNotNullOrEmpty()]
        # [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.0, 1.0)]
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

    $modelInfo = $script:amazonModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    switch ($PSCmdlet.ParameterSetName) {
        'Standard' {
            Write-Verbose -Message 'Standard message provided.'
            $formatAmazonTextMessageSplat = @{
                Role             = 'User'
                Message          = $Message
                ModelID          = $ModelID
                NoContextPersist = $NoContextPersist
            }
            if (-not $PromptOnly) {
                $formattedMessages = Format-AmazonTextMessage @formatAmazonTextMessageSplat
            }
            else {
                $formattedMessages = $Message
            }
        }
        'PreCraftedMessages' {
            Write-Verbose -Message 'Custom conversation provided'
            $conversationEval = Test-AmazonCustomConversation -CustomConversation $CustomConversation
            if ($conversationEval -ne $true) {
                throw 'Custom conversation validation failed.'
            }
            else {
                $formattedMessages = $CustomConversation
            }
        }
    }

    #region cmdletParams

    $bodyObj = @{
        inputText = $formattedMessages
    }
    if ($Temperature -or $TopP -or $MaxTokens -ne 512) {
        $bodyObj.Add('textGenerationConfig', @{})
    }
    # TODO: Add support for StopSequences parameter when AWS SDK issue is resolved
    if ($Temperature) {
        $bodyObj.textGenerationConfig.Add('temperature', $Temperature)
    }
    if ($TopP) {
        $bodyObj.textGenerationConfig.Add('topP', $TopP)
    }
    if ($MaxTokens -ne 512) {
        $bodyObj.textGenerationConfig.Add('maxTokenCount', $MaxTokens)
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
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message ($contextObj | Out-String)
        # Remove the last line of the Context
        $lastNewlineIndex = $contextObj.Context.LastIndexOf("`n", $contextObj.Context.Length - 2)
        if ($lastNewlineIndex -eq -1) {
            # If there's no newline, it means there was only one line
            $contextObj.Context = ''
        }
        else {
            $contextObj.Context = $contextObj.Context.Substring(0, $lastNewlineIndex + 1)
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
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message ($contextObj | Out-String)
        # Remove the last line of the Context
        $lastNewlineIndex = $contextObj.Context.LastIndexOf("`n", $contextObj.Context.Length - 2)
        if ($lastNewlineIndex -eq -1) {
            # If there's no newline, it means there was only one line
            $contextObj.Context = ''
        }
        else {
            $contextObj.Context = $contextObj.Context.Substring(0, $lastNewlineIndex + 1)
        }

        Write-Error $_
        throw
    }

    Write-Debug -Message 'Response JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    Write-Verbose -Message 'Converting response from JSON.'
    $response = $jsonBody | ConvertFrom-Json

    if ([string]::IsNullOrWhiteSpace($response.results.outputText)) {
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
    $content = $response.results.outputText
    $formatAmazonMessageSplat = @{
        Role             = 'Bot'
        Message          = $content
        ModelID          = $ModelID
        NoContextPersist = $NoContextPersist
    }
    Format-AmazonTextMessage @formatAmazonMessageSplat | Out-Null

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $content
    }

} #Invoke-AmazonTextModel
