<#
.SYNOPSIS
    Sends message(s) to the AI21 Labs Jamba model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an AI21 Labs Jamba model on the Amazon Bedrock platform and returns the model's response.
    By default, the conversation context history is persisted to maintain a continuous interaction with the model.
    You can disable this by using the NoContextPersist parameter. Additionally, the cmdlet estimates the cost of model usage
    based on the provided input and output tokens and adds the estimate to the models tally information.
.EXAMPLE
    Invoke-AI21LabsJambaModel -Message 'Explain zero-point energy.' -ModelID 'ai21.jamba-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2'

    Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-AI21LabsJambaModel -Message 'Explain zero-point energy.' -ModelID 'ai21.jamba-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the full response object.
.EXAMPLE
    $invokeMistralAIChatModelSplat = @{
        SystemPrompt     = 'You are a Star Trek trivia expert.'
        Message          = 'What is the best episode of Star Trek?'
        ResponseNumber   = 3
        ReturnFullObject = $true
        ModelID          = 'ai21.jamba-instruct-v1:0'
        ReturnFullObject = $true
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    $result = Invoke-AI21LabsJambaModel @invokeMistralAIChatModelSplat

    Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the full response object.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER SystemPrompt
    Sets the behavior and context for the model in the conversation.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER NoContextPersist
    Do not persist the conversation context history.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
.PARAMETER Temperature
    How much variation to provide in each answer. Setting this value to 0 guarantees the same response to the same question every time. Setting a higher value encourages more variation.
.PARAMETER TopP
    Use a lower value to ignore less probable options and decrease the diversity of responses.
.PARAMETER StopSequences
    Custom text sequences that cause the model to stop generating.
.PARAMETER ResponseNumber
    Number of responses that the model should generate.
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

    If you request more than one response from the model:
        - The Temperature parameter must be set to a value greater than 0.
        - By default, only the first response is added to the context history.
        - By default, only the first response is returned.
        - It is recommended to use the ReturnFullObject parameter to get all responses.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJambaModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jamba.html
.LINK
    https://docs.ai21.com/reference/jamba-instruct-api#response-details
.LINK
    https://docs.ai21.com/docs/migrating-from-jurassic-to-jamba
.LINK
    https://docs.ai21.com/reference/jamba-15-api-ref
#>
function Invoke-AI21LabsJambaModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Sets the behavior and context for the model in the conversation.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'ai21.jamba-instruct-v1:0',
            'ai21.jamba-1-5-mini-v1:0',
            'ai21.jamba-1-5-large-v1:0'
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

        [Parameter(Mandatory = $false,
            HelpMessage = 'How much variation to provide in each answer. Setting this value to 0 guarantees the same response to the same question every time. Setting a higher value encourages more variation.')]
        [ValidateRange(0, 2.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0, 1.0)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Number of responses that the model should generate.')]
        [ValidateRange(1, 16)]
        [int]$ResponseNumber,

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

    $modelInfo = $script:ai21ModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if ($ResponseNumber -gt 1 -and $Temperature -eq 0) {
        throw 'When generating multiple responses, the Temperature parameter must be set to a value greater than 0.'
    }

    # the system prompt must always be the first message in the context, otherwise the model will fail validation
    #  *Note: on subsequent calls, the system prompt will be updated instead of replaced, ensuring the system prompt is always the first message in the context
    if ($SystemPrompt) {
        $formatAI21LabsJambaModelSplat = @{
            Role             = 'system'
            Message          = $SystemPrompt
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        $formattedMessages = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
    }

    if ($Message) {
        $formatAI21LabsJambaModelSplat = @{
            Role             = 'user'
            Message          = $Message
            ModelID          = $ModelID
            NoContextPersist = $NoContextPersist
        }
        $formattedMessages = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
    }

    #region cmdletParams

    $bodyObj = @{
        messages = @(
            $formattedMessages
        )
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

    if ($StopSequences) {
        $bodyObj.Add('stop', $StopSequences)
    }

    if ($ResponseNumber) {
        $bodyObj.Add('n', $ResponseNumber)
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
        # we need to remove the user context from the global variable if the model is not successfully engaged
        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug -Message 'Catch Block. Context:'
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
        # *Note: this model supports multiple responses. By default, only the first response is added to the context.
        $formatMistralAIChatModelSplat = @{
            Role    = 'assistant'
            Message = $response.choices[0].message.content
            ModelID = $ModelID
        }
        Format-AI21LabsJambaModel @formatMistralAIChatModelSplat | Out-Null
    }

    Write-Verbose -Message 'Calculating cost estimate.'
    $message = $formattedMessages | ConvertTo-Json -Depth 10 | Out-String
    Add-ModelCostEstimate -Usage $response.usage -Message $Message -ModelID $ModelID

    if ($ReturnFullObject) {
        return $response
    }
    else {
        # *Note: this model supports multiple responses. By default, only the first response is returned.
        return $response.choices[0].message.content
    }

} #Invoke-AI21LabsJambaModel
