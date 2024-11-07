---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-MetaModel/
schema: 2.0.0
---

# Invoke-MetaModel

## SYNOPSIS
Sends message(s) to a Meta model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

```
Invoke-MetaModel -Message <String> -ModelID <String> [-ReturnFullObject] [-NoContextPersist]
 [-SystemPrompt <String>] [-MaxTokens <Int32>] [-Temperature <Single>] [-TopP <Single>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Sends a message to a Meta model on the Amazon Bedrock platform and returns the model's response.
By default the conversation context history is persisted to maintain a continuous interaction with the model.
You can disable this by using the NoContextPersist parameter.
The cmdlet also estimates the cost of model usage based on the provided
input and output tokens and adds the estimate to the models tally information.

## EXAMPLES

### EXAMPLE 1
```
Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama2-13b-chat-v1' -Credential $awsCredential -Region 'us-west-2'
```

Sends a text message to the on-demand Meta model in the specified AWS region and returns the response.

### EXAMPLE 2
```
Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama2-13b-chat-v1' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Sends a text message to the on-demand Meta model in the specified AWS region and returns the full response object.

### EXAMPLE 3
```
Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama3-8b-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2' -NoContextPersist
```

Sends a text message to the on-demand Meta model in the specified AWS region and returns the response without persisting the conversation context history.

### EXAMPLE 4
```
$invokeMetaModelSplat = @{
    Message          = 'Explain zero-point energy.'
    ModelID          = 'meta.llama2-13b-chat-v1'
    MaxTokens        = 2000
    SystemPrompt     = 'You are a deep thinking model with a galactic perspective'
    Credential       = $awsCredential
    Region           = 'us-west-2'
    NoContextPersist = $true
    Verbose          = $false
}
Invoke-MetaModel @invokeMetaModelSplat
```

Sends a text message to the on-demand Meta model in the specified AWS region with a system prompt and a maximum token limit of 2000.

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

### -NoContextPersist
Do not persist the conversation context history.
If this parameter is specified, you will not be able to have a continuous conversation with the model.
Has no effect if -PromptOnly is specified.

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

### -SystemPrompt
The system prompt for the request.
If you do not provide a system prompt, the default Llama system prompt will be used.

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

### -MaxTokens
The maximum number of tokens to generate before stopping.
Defaults to 2048.
Ranges from 1 to 2048.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 2048
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

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-MetaModel/](https://www.pwshbedrock.dev/en/latest/Invoke-MetaModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html)

[https://huggingface.co/blog/llama2#how-to-prompt-llama-2](https://huggingface.co/blog/llama2#how-to-prompt-llama-2)

[https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-2/](https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-2/)

[https://github.com/meta-llama/llama/blob/main/MODEL_CARD.md](https://github.com/meta-llama/llama/blob/main/MODEL_CARD.md)

[https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/](https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/)

[https://github.com/meta-llama/llama3/blob/main/MODEL_CARD.md](https://github.com/meta-llama/llama3/blob/main/MODEL_CARD.md)

[https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD.md](https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD.md)

[https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD_VISION.md](https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD_VISION.md)

[https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/vision_prompt_format.md](https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/vision_prompt_format.md)

[https://www.llama.com/docs/how-to-guides/vision-capabilities/](https://www.llama.com/docs/how-to-guides/vision-capabilities/)
