---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-AnthropicModel/
schema: 2.0.0
---

# Invoke-AnthropicModel

## SYNOPSIS

Sends message(s) or media files to an Anthropic model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

### Standard (Default)

```powershell
Invoke-AnthropicModel [-Message <String>] [-MediaPath <String[]>] -ModelID <String> [-ReturnFullObject]
 [-NoContextPersist] [-MaxTokens <Int32>] [-SystemPrompt <String>] [-StopSequences <String[]>]
 [-Temperature <Single>] [-TopP <Single>] [-TopK <Int32>] [-Tools <PSObject[]>] [-ToolChoice <String>]
 [-ToolName <String>] [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### PreCraftedMessages

```powershell
Invoke-AnthropicModel -CustomConversation <PSObject[]> -ModelID <String> [-ReturnFullObject]
 [-NoContextPersist] [-MaxTokens <Int32>] [-SystemPrompt <String>] [-StopSequences <String[]>]
 [-Temperature <Single>] [-TopP <Single>] [-TopK <Int32>] [-Tools <PSObject[]>] [-ToolChoice <String>]
 [-ToolName <String>] [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### ToolsResultsSet

```powershell
Invoke-AnthropicModel -ModelID <String> [-ReturnFullObject] [-NoContextPersist] [-MaxTokens <Int32>]
 [-SystemPrompt <String>] [-StopSequences <String[]>] [-Temperature <Single>] [-TopP <Single>] [-TopK <Int32>]
 [-Tools <PSObject[]>] [-ToolChoice <String>] [-ToolName <String>] -ToolsResults <PSObject[]>
 [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

## DESCRIPTION

Sends a message to an Anthropic model on the Amazon Bedrock platform and returns the model's response.
The message can be either text or a media file.
If a media file is specified, it is converted to base64 according to the model's requirements.
By default, the conversation context history is persisted to maintain a continuous interaction with the model.
You can disable this by using the NoContextPersist parameter.
Additionally, the cmdlet estimates the cost of model usage
based on the provided input and output tokens and adds the estimate to the models tally information.
This model supports Function Calling, which allows the Anthropic model to connect to external tools.
This is only supported
for Anthropic 3 models.
You can provide the Tools and ToolChoice parameters to specify the tools that the model may use and how.
If you are providing Tools to enable Function Calling, it is recommended that you use the ReturnFullObject parameter to capture the full response object.
See the pwshBedrock documentation for more information on Function Calling and the Anthropic model.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -Credential $awsCredential -Region 'us-west-2'
```

Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the response.

### EXAMPLE 2

```powershell
Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -ProfileName default -Region 'us-west-2' -ReturnFullObject
```

Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the full response object.

### EXAMPLE 3

```powershell
Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -ProfileName default -Region 'us-west-2' -NoContextPersist
```

Sends a text message to the on-demand Anthropic model in the specified AWS region without persisting the conversation context history.
This is useful for one-off interactions.

### EXAMPLE 4

```powershell
$invokeAnthropicModelSplat = @{
    Message    = 'What can you tell me about this picture? Is it referencing something?'
    ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
    MediaPath  = 'C:\images\tanagra.jpg'
    AccessKey  = 'xxxxxxxxxxxxxxxxxxxx'
    SecretKey  = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    Region     = 'us-west-2'
}
Invoke-AnthropicModel @invokeAnthropicModelSplat
```

Sends a text message with a media file to the on-demand Anthropic model in the specified AWS region and returns the response.

### EXAMPLE 5

```powershell
$invokeAnthropicModelSplat = @{
    Message          = 'Give a brief synopsis to your class of students of what this picture represented a hundreds years ago.'
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    MediaPath        = 'C:\images\tanagra.jpg'
    Temperature      = 1
    SystemPrompt     = 'You are a historian from the future who has studied the provided photo for many years.'
    Credential       = $credential
    Region           = 'us-west-2'
}
Invoke-AnthropicModel @invokeAnthropicModelSplat
```

Sends a text message with a media file to the on-demand Anthropic model in the specified AWS region and returns the response.
A system prompt is provided to give additional context to the model on how to respond.
Temperature is set to 1 for creative responses.

### EXAMPLE 6

```powershell
$invokeAnthropicModelSplat = @{
    Message          = 'Can you name all of the Star Fleet captains featured in the various shows over the years?'
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    SystemPrompt     = 'You are an expert on all things Star Trek, having studied the show for decades. You often win Star Trek Trivia contests and enjoy sharing your vast knowledge of Star Trek with others.'
    Temperature      = 1
    StopSequences    = 'Picard'
    Credential       = $credential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$objReturn = Invoke-AnthropicModel @invokeAnthropicModelSplat
```

Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the full response object.
A system prompt is provided to give additional context to the model on how to respond.
Temperature is set to 1 for creative responses.
Stop sequences are provided to stop the model from generating more text when it encounters the word 'Picard'.

### EXAMPLE 7

```powershell
Invoke-AnthropicModel -CustomConversation $customConversation -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -ProfileName default -Region 'us-west-2'
```

Sends a custom conversation to the on-demand Anthropic model in the specified AWS region and returns the response.
The custom conversation must adhere to the Anthropic model conversation format.
Reference the pwshBedrock documentation for more information on the custom conversation format.

### EXAMPLE 8

```powershell
$invokeAnthropicModelSplat = @{
    Message          = 'Can you name all of the Star Fleet captains featured in the various shows over the years?'
    ModelID          = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
    SystemPrompt     = 'You are an expert on all things Star Trek, having studied the show for decades. You often win Star Trek Trivia contests and enjoy sharing your vast knowledge of Star Trek with others.'
    Tools            = $starTrekTriviaFunctionTool
    ToolChoice       = 'auto'
    Credential       = $credential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$objReturn = Invoke-AnthropicModel @invokeAnthropicModelSplat
```

Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the full response object.
A system prompt is provided to give additional context to the model on how to respond.
A tool is provided to the model to use if needed.
The tool choice is set to auto, allowing the model to decide if it should use the tool.
The tool is a function that provides Star Trek trivia information.

### EXAMPLE 9

```powershell
$invokeAnthropicModelSplat = @{
    ToolsResults = $standardToolResult
    ModelID      = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
    Credential   = $credential
    Region       = 'us-west-2'
}
Invoke-AnthropicModel @invokeAnthropicModelSplat
```

Sends the results of a tool invocation to the on-demand Anthropic model in the specified AWS region and returns the response.
The tool results must adhere to the Anthropic model tool result format.
Reference the pwshBedrock documentation for more information on the tool result format.

## PARAMETERS

### -Message

The message to be sent to the model.

```yaml
Type: String
Parameter Sets: Standard
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaPath

File path to local media file.
Up to 20 media files can be sent in a single request.
The media files must adhere to the model's media requirements.

```yaml
Type: String[]
Parameter Sets: Standard
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomConversation

An array of custom conversation objects.

```yaml
Type: PSObject[]
Parameter Sets: PreCraftedMessages
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

### -SystemPrompt

The system prompt for the request.
System prompt is a way of providing context and instructions to Anthropic Claude, such as specifying a particular goal or role.

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

### -StopSequences

Custom text sequences that cause the model to stop generating.
Anthropic Claude models normally stop when they have naturally completed their turn, in this case the value of the stop_reason response field is end_turn.
If you want the model to stop generating when it encounters custom strings of text, you can use the stop_sequences parameter.
If the model encounters one of the custom text strings, the value of the stop_reason response field is stop_sequence and the value of stop_sequence contains the matched stop sequence.

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

### -Temperature

The amount of randomness injected into the response.
Defaults to 1.0.
Ranges from 0.0 to 1.0.
Use temperature closer to 0.0 for analytical / multiple choice, and closer to 1.0 for creative and generative tasks.

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

Use nucleus sampling.
In nucleus sampling, Anthropic Claude computes the cumulative distribution over all the options for each subsequent token in decreasing probability order and cuts it off once it reaches a particular probability specified by top_p.
You should alter either temperature or top_p, but not both.
Recommended for advanced use cases only.
You usually only need to use temperature.

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

Only sample from the top K options for each subsequent token.
Use top_k to remove long tail low probability responses.
Recommended for advanced use cases only.
You usually only need to use temperature.

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

### -Tools

Definitions of tools that the model may use.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ToolChoice

In some cases, you may want Claude to use a specific tool to answer the user's question, even if Claude thinks it can provide an answer without using a tool.
auto - allows Claude to decide whether to call any provided tools or not.
This is the default value.
any - tells Claude that it must use one of the provided tools, but doesn't force a particular tool.
tool -allows us to force Claude to always use a particular tool.
    if you specify tool, you must also provide the ToolName of the tool you want Claude to use.

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

### -ToolName

Optional parameter - The name of the tool that Claude should use to answer the user's question.
This parameter is only required if you set the ToolChoice parameter to tool.

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

### -ToolsResults

A list of results from invoking tools recommended by the model in the previous chat turn.

```yaml
Type: PSObject[]
Parameter Sets: ToolsResultsSet
Aliases:

Required: True
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

* For a full tools example, see the advanced documentation on the pwshBedrock website.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-AnthropicModel/](https://www.pwshbedrock.dev/en/latest/Invoke-AnthropicModel/)

[https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/](https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude-messages.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude-messages.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude-37.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude-37.html)

[https://docs.anthropic.com/en/docs/models-overview](https://docs.anthropic.com/en/docs/models-overview)

[https://docs.anthropic.com/en/api/messages](https://docs.anthropic.com/en/api/messages)

[https://docs.anthropic.com/en/api/messages-examples](https://docs.anthropic.com/en/api/messages-examples)

[https://docs.anthropic.com/en/docs/system-prompts](https://docs.anthropic.com/en/docs/system-prompts)

[https://docs.anthropic.com/en/docs/vision](https://docs.anthropic.com/en/docs/vision)

[https://docs.anthropic.com/en/docs/build-with-claude/tool-use](https://docs.anthropic.com/en/docs/build-with-claude/tool-use)

[https://docs.anthropic.com/en/docs/agents-and-tools/computer-use](https://docs.anthropic.com/en/docs/agents-and-tools/computer-use)
