<#
.SYNOPSIS
    Sends message(s) to the Cohere Command model on the Amazon Bedrock platform and retrieves the response.
.DESCRIPTION
    Sends a message to an Cohere Command model on the Amazon Bedrock platform and returns the model's response.
    The cmdlet estimates the cost of model usage based on the provided input and output tokens and adds the estimate to the models tally information.
    Conversation context is not supported by the model(s) payload. See the NOTES section for more information.
.EXAMPLE
    Invoke-CohereCommandModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-text-v14' -Credential $awsCredential -Region 'us-west-2'

    Sends a text message to the on-demand Cohere Command model in the specified AWS region and returns the response.
.EXAMPLE
    Invoke-CohereCommandModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-text-v14' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Sends a text message to the on-demand Cohere Command model in the specified AWS region and returns the full response object.
.EXAMPLE
    $invokeCohereCommandModelSplat = @{
        Message           = 'Explain zero-point energy.'
        ModelID           = 'cohere.command-light-text-v14'
        Temperature       = 0.5
        TopP              = 0.9
        TopK              = 50
        MaxTokens         = 4096
        StopSequences     = @('clouds')
        ReturnLikelihoods = 'ALL'
        Generations       = 2
        Truncate          = 'END'
        AccessKey         = 'ak'
        SecretKey         = 'sk'
        Region            = 'us-west-2'
    }
    Invoke-CohereCommandModel @invokeCohereCommandModelSplat

    Sends a text message to the on-demand Cohere Command model in the specified AWS region with custom parameters and returns the response.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned instead of just the message reply.
.PARAMETER Temperature
    The amount of randomness injected into the response.
    Defaults to 0.9 Ranges from 0.0 to 5.0.
    Use a lower value to decrease randomness in responses.
.PARAMETER TopP
    Use a lower value to ignore less probable options. Set to 0 or 1.0 to disable. If both p and k are enabled, p acts after k
.PARAMETER TopK
    Specify the number of token choices the model uses to generate the next token. If both p and k are enabled, p acts after k.
.PARAMETER MaxTokens
    The maximum number of tokens to generate before stopping.
    Defaults to 4096. Ranges from 1 to 4096.
    Note that Anthropic Claude models might stop generating tokens before reaching the value of max_tokens.
.PARAMETER StopSequences
    Custom text sequences that cause the model to stop generating.
.PARAMETER ReturnLikelihoods
    Specify how and if the token likelihoods are returned with the response.
    GENERATION – Only return likelihoods for generated tokens.
    ALL – Return likelihoods for all tokens.
    NONE – (Default) Don't return any likelihoods.
.PARAMETER Generations
    The maximum number of generations that the model should return.
.PARAMETER Truncate
    Specifies how the API handles inputs longer than the maximum token length.
    NONE – Returns an error when the input exceeds the maximum input token length.
    START – Discard the start of the input.
    END – (Default) Discards the end of the input.
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

    Cohere Command model(s) through bedrock do not currently support persistent context.
    The model(s) payload does not support context or state information.
    So, it is not possible to construct, for example, a user/bot payload that maintains a conversation.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command.html
.LINK
    https://docs.cohere.com/docs/command-beta
.LINK
    https://docs.cohere.com/docs/models
.LINK
    https://docs.cohere.com/docs/the-cohere-platform
#>
function Invoke-CohereCommandModel {
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
            'cohere.command-text-v14',
            'cohere.command-light-text-v14'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned instead of just the message reply.')]
        [switch]$ReturnFullObject,

        # model parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The amount of randomness injected into the response.')]
        [ValidateRange(0.0, 5.0)]
        [float]$Temperature,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a lower value to ignore less probable options and decrease the diversity of responses.')]
        [ValidateRange(0.0, 1.0)]
        [float]$TopP,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify the number of token choices the model uses to generate the next token.')]
        [ValidateRange(0, 500)]
        [int]$TopK,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to generate before stopping.')]
        [ValidateRange(1, 4096)]
        [int]$MaxTokens = 4096,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom text sequences that cause the model to stop generating.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$StopSequences,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify how and if the token likelihoods are returned with the response.')]
        [ValidateSet('GENERATION', 'ALL', 'NONE')]
        [string]$ReturnLikelihoods,

        # * not supporting stream responses in pwshBedrock - maybe in the future
        # [Parameter(Mandatory = $false,
        #     HelpMessage = 'Specify true to return the response piece-by-piece in real-time and false to return the complete response after the process finishes.')]
        # [bool]$Stream,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum number of generations that the model should return.')]
        [ValidateRange(1, 5)]
        [int]$Generations,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies how the API handles inputs longer than the maximum token length.')]
        [ValidateSet('NONE', 'START', 'END')]
        [string]$Truncate,

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
        $bodyObj.Add('p', $TopP)
    }
    if ($TopK) {
        $bodyObj.Add('k', $TopK)
    }
    if ($MaxTokens) {
        $bodyObj.Add('max_tokens', $MaxTokens)
    }
    if ($StopSequences) {
        $bodyObj.Add('stop_sequences', $StopSequences)
    }
    if ($ReturnLikelihoods) {
        $bodyObj.Add('return_likelihoods', $ReturnLikelihoods)
    }
    if ($Generations) {
        $bodyObj.Add('num_generations', $Generations)
    }
    if ($Truncate) {
        $bodyObj.Add('truncate', $Truncate)
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

    # this model supports creating multiple generations of text
    foreach ($textGeneration in $response.generations.text) {
        $completion += $textGeneration
    }

    Write-Verbose -Message 'Calculating cost estimate.'
    Add-ModelCostEstimate -Usage $response -ModelID $ModelID

    if ($ReturnFullObject) {
        return $response
    }
    else {
        return $completion
    }

} #Invoke-CohereCommandModel
