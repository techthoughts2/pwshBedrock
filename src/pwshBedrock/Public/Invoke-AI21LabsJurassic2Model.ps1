<#
.SYNOPSIS
    Sends message(s) to an AI21 Labs Jurassic 2 model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an AI21 Labs Jurassic 2 model on the Amazon Bedrock platform and returns the model's response.
    The cmdlet estimates the cost of model usage based on the provided input and output tokens and adds the estimate to the models tally information.
    Conversation context is not supported by the model(s) payload. See the NOTES section for more information.
.EXAMPLE
    Invoke-AI21LabsJurassic2Model -Messages 'Explain zero-point energy.' -ModelID 'ai21.j2-ultra-v1' -Credential $awsCredential -Region 'us-west-2'

    Sends a text message to the on-demand AI21 Labs Jurassic 2 model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-AI21LabsJurassic2Model -Messages 'Explain zero-point energy.' -ModelID 'ai21.j2-ultra-v1' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand AI21 Labs Jurassic 2 model in the specified AWS region and returns the full response object.
.EXAMPLE
    $invokeAI21LabsModelSplat = @{
        Message                             = 'Shaka, when the walls fell.'
        ModelID                             = 'ai21.j2-jumbo-instruct'
        Temperature                         = 0.5
        TopP                                = 0.9
        MaxTokens                           = 4096
        StopSequences                       = @('clouds')
        CountPenaltyScale                   = 0.5
        CountPenaltyApplyToWhiteSpaces      = $true
        CountPenaltyApplyToPunctuations     = $true
        CountPenaltyApplyToNumbers          = $true
        CountPenaltyApplyToStopWords        = $true
        CountPenaltyApplyToEmojis           = $true
        PresencePenaltyScale                = 0.5
        PresencePenaltyApplyToWhiteSpaces   = $true
        PresencePenaltyApplyToPunctuations  = $true
        PresencePenaltyApplyToNumbers       = $true
        PresencePenaltyApplyToStopWords     = $true
        PresencePenaltyApplyToEmojis        = $true
        FrequencyPenaltyScale               = 100
        FrequencyPenaltyApplyToWhiteSpaces  = $true
        FrequencyPenaltyApplyToPunctuations = $true
        FrequencyPenaltyApplyToNumbers      = $true
        FrequencyPenaltyApplyToStopWords    = $true
        FrequencyPenaltyApplyToEmojis       = $true
        AccessKey                           = 'ak'
        SecretKey                           = 'sk'
        Region                              = 'us-west-2'
    }
    Invoke-AI21LabsJurassic2Model @invokeAI21LabsModelSplat

    Sends a text message to the on-demand AI21 Labs Jurassic 2 model in the specified AWS region with custom parameters and returns the response.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER Temperature
    The amount of randomness injected into the response.
    Defaults to 1.0. Ranges from 0.0 to 1.0.
    Use a lower value to decrease randomness in responses.
.PARAMETER TopP
    Use a lower value to ignore less probable options and decrease the diversity of responses.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
    Defaults to 4096. Ranges from 1 to 4096.
    Note that Anthropic Claude models might stop generating tokens before reaching the value of max_tokens.
.PARAMETER StopSequences
    Custom text sequences that cause the model to stop generating.
.PARAMETER CountPenaltyScale
    A true value applies the penalty to whitespaces and new lines. Proportional to the number of appearances.
.PARAMETER CountPenaltyApplyToWhiteSpaces
    A true value applies the penalty to whitespaces.
.PARAMETER CountPenaltyApplyToPunctuations
    A true value applies the penalty to punctuation.
.PARAMETER CountPenaltyApplyToNumbers
    A true value applies the penalty to numbers.
.PARAMETER CountPenaltyApplyToStopWords
    A true value applies the penalty to stop words.
.PARAMETER CountPenaltyApplyToEmojis
    A true value excludes emojis from the penalty.
.PARAMETER PresencePenaltyScale
    A positive penalty value implies reducing the probability of repetition. Larger values correspond to a stronger bias against repetition.
.PARAMETER PresencePenaltyApplyToWhiteSpaces
    A true value applies the penalty to whitespaces and new lines.
.PARAMETER PresencePenaltyApplyToPunctuations
    A true value applies the penalty to punctuation.
.PARAMETER PresencePenaltyApplyToNumbers
    A true value applies the penalty to numbers.
.PARAMETER PresencePenaltyApplyToStopWords
    A true value applies the penalty to stop words.
.PARAMETER PresencePenaltyApplyToEmojis
    A true value excludes emojis from the penalty.
.PARAMETER FrequencyPenaltyScale
    A positive penalty value implies reducing the probability of repetition. Larger values correspond to a stronger bias against repetition.
.PARAMETER FrequencyPenaltyApplyToWhiteSpaces
    A true value applies the penalty to whitespaces and new lines.
.PARAMETER FrequencyPenaltyApplyToPunctuations
    A true value applies the penalty to punctuation.
.PARAMETER FrequencyPenaltyApplyToNumbers
    A true value applies the penalty to numbers.
.PARAMETER FrequencyPenaltyApplyToStopWords
    A true value applies the penalty to stop words.
.PARAMETER FrequencyPenaltyApplyToEmojis
    A true value excludes emojis from the penalty.
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

    AI21 Labs Jurassic 2 model(s) through bedrock do not currently support persistent context.
    The model(s) payload does not support context or state information.
    So, it is not possible to construct, for example, a user/bot payload that maintains a conversation.

    Presence penalty (presencePenalty) – Use a higher value to lower the probability of generating new tokens that already appear at least once in the prompt or in the completion.
    Count penalty (countPenalty) – Use a higher value to lower the probability of generating new tokens that already appear at least once in the prompt or in the completion. Proportional to the number of appearances.
    Frequency penalty (frequencyPenalty) – Use a high value to lower the probability of generating new tokens that already appear at least once in the prompt or in the completion. The value is proportional to the frequency of the token appearances (normalized to text length).

.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJurassic2Model/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jurassic2.html
.LINK
    https://docs.ai21.com/docs/jurassic-2-models
.LINK
    https://docs.ai21.com/docs/instruct-models
.LINK
    https://docs.ai21.com/reference/j2-complete-ref
#>
function Invoke-AI21LabsJurassic2Model {
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
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'ai21.j2-grande-instruct',
            'ai21.j2-jumbo-instruct',
            'ai21.j2-mid-v1',
            'ai21.j2-ultra-v1'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned instead of just the message reply.')]
        [switch]$ReturnFullObject,

        # model parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 1.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.0, 1.0)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 8192)]
        [int]$MaxTokens = 512,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        # penalize parameters

        # Count Penalty

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to whitespaces and new lines. Proportional to the number of appearances.')]
        [ValidateRange(0.0, 1.0)]
        [float]$CountPenaltyScale,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to punctuation. Proportional to the number of appearances.')]
        [bool]$CountPenaltyApplyToWhiteSpaces,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to punctuation. Proportional to the number of appearances.')]
        [bool]$CountPenaltyApplyToPunctuations,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to numbers. Proportional to the number of appearances.')]
        [bool]$CountPenaltyApplyToNumbers,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to stop words. Proportional to the number of appearances.')]
        [bool]$CountPenaltyApplyToStopWords,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value excludes emojis from the penalty. Proportional to the number of appearances.')]
        [bool]$CountPenaltyApplyToEmojis,

        # Presence Penalty

        [Parameter(Mandatory = $false,
            HelpMessage = 'A positive penalty value implies reducing the probability of repetition. Larger values correspond to a stronger bias against repetition.')]
        [ValidateRange(0.0, 5.0)]
        [float]$PresencePenaltyScale,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to whitespaces and new lines.')]
        [bool]$PresencePenaltyApplyToWhiteSpaces,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to punctuation.')]
        [bool]$PresencePenaltyApplyToPunctuations,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to numbers.')]
        [bool]$PresencePenaltyApplyToNumbers,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to stop words.')]
        [bool]$PresencePenaltyApplyToStopWords,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value excludes emojis from the penalty.')]
        [bool]$PresencePenaltyApplyToEmojis,

        # Frequency Penalty
        [Parameter(Mandatory = $false,
            HelpMessage = 'A positive penalty value implies reducing the probability of repetition. Larger values correspond to a stronger bias against repetition.')]
        [ValidateRange(0, 500)]
        [int]$FrequencyPenaltyScale,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to whitespaces and new lines.')]
        [bool]$FrequencyPenaltyApplyToWhiteSpaces,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to punctuation.')]
        [bool]$FrequencyPenaltyApplyToPunctuations,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to numbers.')]
        [bool]$FrequencyPenaltyApplyToNumbers,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value applies the penalty to stop words.')]
        [bool]$FrequencyPenaltyApplyToStopWords,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A true value excludes emojis from the penalty.')]
        [bool]$FrequencyPenaltyApplyToEmojis,

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

    Write-Verbose -Message 'Formatting message for model.'

    $formattedMessages = $Message

    #region cmdletParams

    $bodyObj = @{
        prompt = $formattedMessages
    }

    if ($Temperature) {
        $bodyObj.Add('temperature', $Temperature)
    }
    if ($TopP) {
        $bodyObj.Add('topP', $TopP)
    }
    if ($MaxTokens) {
        $bodyObj.Add('maxTokens', $MaxTokens)
    }
    if ($StopSequences) {
        $bodyObj.Add('stopSequences', $StopSequences)
    }

    # special case for penalty objects
    # countPenalty
    if (
        $CountPenaltyScale -or
        $CountPenaltyApplyToWhiteSpaces -or
        $CountPenaltyApplyToPunctuations -or
        $CountPenaltyApplyToNumbers -or
        $CountPenaltyApplyToStopWords -or
        $CountPenaltyApplyToEmojis
    ) {
        $bodyObj.Add('countPenalty', @{})
    }
    if ($CountPenaltyScale) {
        $bodyObj.countPenalty.Add('scale', $CountPenaltyScale)
    }
    if ($CountPenaltyApplyToWhiteSpaces) {
        $bodyObj.countPenalty.Add('applyToWhiteSpaces', $CountPenaltyApplyToWhiteSpaces)
    }
    if ($CountPenaltyApplyToPunctuations) {
        $bodyObj.countPenalty.Add('applyToPunctuations', $CountPenaltyApplyToPunctuations)
    }
    if ($CountPenaltyApplyToNumbers) {
        $bodyObj.countPenalty.Add('applyToNumbers', $CountPenaltyApplyToNumbers)
    }
    if ($CountPenaltyApplyToStopWords) {
        $bodyObj.countPenalty.Add('applyToStopWords', $CountPenaltyApplyToStopWords)
    }
    if ($CountPenaltyApplyToEmojis) {
        $bodyObj.countPenalty.Add('applyToEmojis', $CountPenaltyApplyToEmojis)
    }
    # presencePenalty
    if (
        $PresencePenaltyScale -or
        $PresencePenaltyApplyToWhiteSpaces -or
        $PresencePenaltyApplyToPunctuations -or
        $PresencePenaltyApplyToNumbers -or
        $PresencePenaltyApplyToStopWords -or
        $PresencePenaltyApplyToEmojis
    ) {
        $bodyObj.Add('presencePenalty', @{})
    }
    if ($PresencePenaltyScale) {
        $bodyObj.presencePenalty.Add('scale', $PresencePenaltyScale)
    }
    if ($PresencePenaltyApplyToWhiteSpaces) {
        $bodyObj.presencePenalty.Add('applyToWhiteSpaces', $PresencePenaltyApplyToWhiteSpaces)
    }
    if ($PresencePenaltyApplyToPunctuations) {
        $bodyObj.presencePenalty.Add('applyToPunctuations', $PresencePenaltyApplyToPunctuations)
    }
    if ($PresencePenaltyApplyToNumbers) {
        $bodyObj.presencePenalty.Add('applyToNumbers', $PresencePenaltyApplyToNumbers)
    }
    if ($PresencePenaltyApplyToStopWords) {
        $bodyObj.presencePenalty.Add('applyToStopWords', $PresencePenaltyApplyToStopWords)
    }
    if ($PresencePenaltyApplyToEmojis) {
        $bodyObj.presencePenalty.Add('applyToEmojis', $PresencePenaltyApplyToEmojis)
    }

    # frequencyPenalty
    if (
        $FrequencyPenaltyScale -or
        $FrequencyPenaltyApplyToWhiteSpaces -or
        $FrequencyPenaltyApplyToPunctuations -or
        $FrequencyPenaltyApplyToNumbers -or
        $FrequencyPenaltyApplyToStopWords -or
        $FrequencyPenaltyApplyToEmojis
    ) {
        $bodyObj.Add('frequencyPenalty', @{})
    }
    if ($FrequencyPenaltyScale) {
        $bodyObj.frequencyPenalty.Add('scale', $FrequencyPenaltyScale)
    }
    if ($FrequencyPenaltyApplyToWhiteSpaces) {
        $bodyObj.frequencyPenalty.Add('applyToWhiteSpaces', $FrequencyPenaltyApplyToWhiteSpaces)
    }
    if ($FrequencyPenaltyApplyToPunctuations) {
        $bodyObj.frequencyPenalty.Add('applyToPunctuations', $FrequencyPenaltyApplyToPunctuations)
    }
    if ($FrequencyPenaltyApplyToNumbers) {
        $bodyObj.frequencyPenalty.Add('applyToNumbers', $FrequencyPenaltyApplyToNumbers)
    }
    if ($FrequencyPenaltyApplyToStopWords) {
        $bodyObj.frequencyPenalty.Add('applyToStopWords', $FrequencyPenaltyApplyToStopWords)
    }
    if ($FrequencyPenaltyApplyToEmojis) {
        $bodyObj.frequencyPenalty.Add('applyToEmojis', $FrequencyPenaltyApplyToEmojis)
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
    $completion = $response.completions[0].data.text

    Write-Verbose -Message 'Calculating cost estimate.'
    Add-ModelCostEstimate -Usage $response -ModelID $ModelID

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $completion
    }

} #Invoke-AI21LabsJurassic2Model
