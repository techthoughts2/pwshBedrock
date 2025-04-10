---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJambaModel/
schema: 2.0.0
---

# Invoke-AI21LabsJambaModel

## SYNOPSIS

Sends message(s) to the AI21 Labs Jamba model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

```powershell
Invoke-AI21LabsJambaModel [-Message] <String> [[-SystemPrompt] <String>] [-ModelID] <String>
 [-ReturnFullObject] [-NoContextPersist] [[-MaxTokens] <Int32>] [[-Temperature] <Single>] [[-TopP] <Single>]
 [[-StopSequences] <String[]>] [[-ResponseNumber] <Int32>] [[-AccessKey] <String>]
 [[-Credential] <AWSCredentials>] [[-EndpointUrl] <String>] [[-NetworkCredential] <PSCredential>]
 [[-ProfileLocation] <String>] [[-ProfileName] <String>] [[-Region] <Object>] [[-SecretKey] <String>]
 [[-SessionToken] <String>] [<CommonParameters>]
```

## DESCRIPTION

Sends a message to an AI21 Labs Jamba model on the Amazon Bedrock platform and returns the model's response.
By default, the conversation context history is persisted to maintain a continuous interaction with the model.
You can disable this by using the NoContextPersist parameter.
Additionally, the cmdlet estimates the cost of model usage
based on the provided input and output tokens and adds the estimate to the models tally information.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-AI21LabsJambaModel -Message 'Explain zero-point energy.' -ModelID 'ai21.jamba-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2'
```

Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the response.

### EXAMPLE 2

```powershell
Invoke-AI21LabsJambaModel -Message 'Explain zero-point energy.' -ModelID 'ai21.jamba-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the full response object.

### EXAMPLE 3

```powershell
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
```

Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the full response object.

## PARAMETERS

### -Message

The message to be sent to the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemPrompt

Sets the behavior and context for the model in the conversation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
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

### -MaxTokens

The maximum number of tokens to generate before stopping.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 4096
Accept pipeline input: False
Accept wildcard characters: False
```

### -Temperature

How much variation to provide in each answer.
Setting this value to 0 guarantees the same response to the same question every time.
Setting a higher value encourages more variation.

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
Position: 6
Default value: 0
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
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResponseNumber

Number of responses that the model should generate.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
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
Position: 9
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
Position: 10
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
Position: 11
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
Position: 12
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
Position: 13
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
Position: 14
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
Position: 15
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
Position: 16
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
Position: 17
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

If you request more than one response from the model:
    - The Temperature parameter must be set to a value greater than 0.
    - By default, only the first response is added to the context history.
    - By default, only the first response is returned.
    - It is recommended to use the ReturnFullObject parameter to get all responses.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJambaModel/](https://www.pwshbedrock.dev/en/latest/Invoke-AI21LabsJambaModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jamba.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jamba.html)

[https://docs.ai21.com/reference/jamba-instruct-api#response-details](https://docs.ai21.com/reference/jamba-instruct-api#response-details)

[https://docs.ai21.com/docs/migrating-from-jurassic-to-jamba](https://docs.ai21.com/docs/migrating-from-jurassic-to-jamba)

[https://docs.ai21.com/reference/jamba-15-api-ref](https://docs.ai21.com/reference/jamba-15-api-ref)
