---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandModel/
schema: 2.0.0
---

# Invoke-CohereCommandModel

## SYNOPSIS
Sends message(s) to the Cohere Command model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

```
Invoke-CohereCommandModel -Message <String> -ModelID <String> [-ReturnFullObject] [-Temperature <Single>]
 [-TopP <Single>] [-TopK <Int32>] [-MaxTokens <Int32>] [-StopSequences <String[]>]
 [-ReturnLikelihoods <String>] [-Generations <Int32>] [-Truncate <String>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Sends a message to an Cohere Command model on the Amazon Bedrock platform and returns the model's response.
The cmdlet estimates the cost of model usage based on the provided input and output tokens and adds the estimate to the models tally information.
Conversation context is not supported by the model(s) payload.
See the NOTES section for more information.

## EXAMPLES

### EXAMPLE 1
```
Invoke-CohereCommandModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-text-v14' -Credential $awsCredential -Region 'us-west-2'
```

Sends a text message to the on-demand Cohere Command model in the specified AWS region and returns the response.

### EXAMPLE 2
```
Invoke-CohereCommandModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-text-v14' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Sends a text message to the on-demand Cohere Command model in the specified AWS region and returns the full response object.

### EXAMPLE 3
```
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
```

Sends a text message to the on-demand Cohere Command model in the specified AWS region with custom parameters and returns the response.

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
Defaults to 0.9 Ranges from 0.0 to 5.0.
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
Use a lower value to ignore less probable options.
Set to 0 or 1.0 to disable.
If both p and k are enabled, p acts after k

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

### -TopK
Specify the number of token choices the model uses to generate the next token.
If both p and k are enabled, p acts after k.

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
Default value: 4096
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

### -ReturnLikelihoods
Specify how and if the token likelihoods are returned with the response.
GENERATION - Only return likelihoods for generated tokens.
ALL - Return likelihoods for all tokens.
NONE - (Default) Don't return any likelihoods.

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

### -Generations
The maximum number of generations that the model should return.

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

### -Truncate
Specifies how the API handles inputs longer than the maximum token length.
NONE - Returns an error when the input exceeds the maximum input token length.
START - Discard the start of the input.
END - (Default) Discards the end of the input.

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

Cohere Command model(s) through bedrock do not currently support persistent context.
The model(s) payload does not support context or state information.
So, it is not possible to construct, for example, a user/bot payload that maintains a conversation.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandModel/](https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command.html)

[https://docs.cohere.com/docs/command-beta](https://docs.cohere.com/docs/command-beta)

[https://docs.cohere.com/docs/models](https://docs.cohere.com/docs/models)

[https://docs.cohere.com/docs/the-cohere-platform](https://docs.cohere.com/docs/the-cohere-platform)
