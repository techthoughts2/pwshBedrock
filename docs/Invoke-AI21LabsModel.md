---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJurassic2Model/
schema: 2.0.0
---

# Invoke-AI21LabsJurassic2Model

## SYNOPSIS
Sends message(s) to an AI21 Labs model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

```
Invoke-AI21LabsJurassic2Model -Message <String> -ModelID <String> [-ReturnFullObject] [-Temperature <Single>]
 [-TopP <Single>] [-MaxTokens <Int32>] [-StopSequences <String[]>] [-CountPenaltyScale <Single>]
 [-CountPenaltyApplyToWhiteSpaces <Boolean>] [-CountPenaltyApplyToPunctuations <Boolean>]
 [-CountPenaltyApplyToNumbers <Boolean>] [-CountPenaltyApplyToStopWords <Boolean>]
 [-CountPenaltyApplyToEmojis <Boolean>] [-PresencePenaltyScale <Single>]
 [-PresencePenaltyApplyToWhiteSpaces <Boolean>] [-PresencePenaltyApplyToPunctuations <Boolean>]
 [-PresencePenaltyApplyToNumbers <Boolean>] [-PresencePenaltyApplyToStopWords <Boolean>]
 [-PresencePenaltyApplyToEmojis <Boolean>] [-FrequencyPenaltyScale <Int32>]
 [-FrequencyPenaltyApplyToWhiteSpaces <Boolean>] [-FrequencyPenaltyApplyToPunctuations <Boolean>]
 [-FrequencyPenaltyApplyToNumbers <Boolean>] [-FrequencyPenaltyApplyToStopWords <Boolean>]
 [-FrequencyPenaltyApplyToEmojis <Boolean>] [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends a message to an AI21 Labs model on the Amazon Bedrock platform and returns the model's response.
The cmdlet estimates the cost of model usage based on the provided input and output tokens and adds the estimate to the models tally information.
Conversation context is not supported by the model(s) payload.
See the NOTES section for more information.

## EXAMPLES

### EXAMPLE 1
```
Invoke-AI21LabsJurassic2Model -Messages 'Explain zero-point energy.' -ModelID 'ai21.j2-ultra-v1' -Credential $awsCredential -Region 'us-west-2'
```

Sends a text message to the on-demand AI21 Labs model in the specified AWS region and returns the response.

### EXAMPLE 2
```
Invoke-AI21LabsJurassic2Model -Messages 'Explain zero-point energy.' -ModelID 'ai21.j2-ultra-v1' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Sends a text message to the on-demand AI21 Labs model in the specified AWS region and returns the full response object.

### EXAMPLE 3
```
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
```

Sends a text message to the on-demand AI21 Labs model in the specified AWS region with custom parameters and returns the response.

## PARAMETERS

### -Message
The message to be sent to the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModelID
The unique identifier of the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnFullObject
Specify if you want the full object returned instead of just the message reply.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Temperature
The amount of randomness injected into the response.
Defaults to 1.0.
Ranges from 0.0 to 1.0.
Use a lower value to decrease randomness in responses.

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TopP
Use a lower value to ignore less probable options and decrease the diversity of responses.

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxTokens
The maximum number of tokens to generate before stopping.
Defaults to 4096.
Ranges from 1 to 4096.
Note that Anthropic Claude models might stop generating tokens before reaching the value of max_tokens.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 512
Accept pipeline input: False
Accept wildcard characters: False
```

### -StopSequences
Custom text sequences that cause the model to stop generating.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountPenaltyScale
A true value applies the penalty to whitespaces and new lines.
Proportional to the number of appearances.

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountPenaltyApplyToWhiteSpaces
A true value applies the penalty to whitespaces.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountPenaltyApplyToPunctuations
A true value applies the penalty to punctuation.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountPenaltyApplyToNumbers
A true value applies the penalty to numbers.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountPenaltyApplyToStopWords
A true value applies the penalty to stop words.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountPenaltyApplyToEmojis
A true value excludes emojis from the penalty.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresencePenaltyScale
A positive penalty value implies reducing the probability of repetition.
Larger values correspond to a stronger bias against repetition.

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresencePenaltyApplyToWhiteSpaces
A true value applies the penalty to whitespaces and new lines.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresencePenaltyApplyToPunctuations
A true value applies the penalty to punctuation.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresencePenaltyApplyToNumbers
A true value applies the penalty to numbers.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresencePenaltyApplyToStopWords
A true value applies the penalty to stop words.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PresencePenaltyApplyToEmojis
A true value excludes emojis from the penalty.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyPenaltyScale
A positive penalty value implies reducing the probability of repetition.
Larger values correspond to a stronger bias against repetition.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyPenaltyApplyToWhiteSpaces
A true value applies the penalty to whitespaces and new lines.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyPenaltyApplyToPunctuations
A true value applies the penalty to punctuation.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyPenaltyApplyToNumbers
A true value applies the penalty to numbers.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyPenaltyApplyToStopWords
A true value applies the penalty to stop words.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyPenaltyApplyToEmojis
A true value excludes emojis from the penalty.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessKey
The AWS access key for the user account.
This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.

```yaml
Type: AWSCredentials
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndpointUrl
The endpoint to make the call against.
Note: This parameter is primarily for internal AWS use and is not required/should not be specified for  normal usage.
The cmdlets normally determine which endpoint to call based on the region specified to the -Region parameter or set as default in the shell (via Set-DefaultAWSRegion).
Only specify this parameter if you must direct the call to a specific custom endpoint.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkCredential
Used with SAML-based authentication when ProfileName references a SAML role profile.
Contains the network credentials to be supplied during authentication with the  configured identity provider's endpoint.
This parameter is not required if the user's default network identity can or should be used during authentication.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileLocation
Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs)
If this optional parameter is omitted this cmdlet will search the encrypted credential file used by the AWS SDK for .NET and AWS Toolkit for Visual Studio first.
If the profile is not found then the cmdlet will search in the ini-format credential file at the default location: (user's home directory)\.aws\credentials.
If this parameter is specified then this cmdlet will only search the ini-format credential file at the location given.
As the current folder can vary in a shell or during script execution it is advised that you use specify a fully qualified path instead of a relative path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
The user-defined name of an AWS credentials or SAML-based role profile containing credential information.
The profile is expected to be found in the secure credential file shared with the AWS SDK for .NET and AWS Toolkit for Visual Studio.
You can also specify the name of a profile stored in the .ini-format credential file used with  the AWS CLI and other AWS SDKs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
The system name of an AWS region or an AWSRegion instance.
This governs the endpoint that will be used when calling service operations.
Note that  the AWS resources referenced in a call are usually region-specific.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretKey
The AWS secret key for the user account.
This can be a temporary secret key if the corresponding session token is supplied to the -SessionToken parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionToken
The session token if the access and secret keys are temporary session-based credentials.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
### or
### System.Management.Automation.PSCustomObject
## NOTES
Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

AI21 Labs Model(s) through bedrock do not currently support persistent context.
The model(s) payload does not support context or state information.
So, it is not possible to construct, for example, a user/bot payload that maintains a conversation.

Presence penalty (presencePenalty) - Use a higher value to lower the probability of generating new tokens that already appear at least once in the prompt or in the completion.
Count penalty (countPenalty) - Use a higher value to lower the probability of generating new tokens that already appear at least once in the prompt or in the completion.
Proportional to the number of appearances.
Frequency penalty (frequencyPenalty) - Use a high value to lower the probability of generating new tokens that already appear at least once in the prompt or in the completion.
The value is proportional to the frequency of the token appearances (normalized to text length).

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJurassic2Model/](https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJurassic2Model/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jurassic2.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jurassic2.html)

[https://docs.ai21.com/docs/jurassic-2-models](https://docs.ai21.com/docs/jurassic-2-models)

[https://docs.ai21.com/docs/instruct-models](https://docs.ai21.com/docs/instruct-models)

[https://docs.ai21.com/reference/j2-complete-ref](https://docs.ai21.com/reference/j2-complete-ref)
