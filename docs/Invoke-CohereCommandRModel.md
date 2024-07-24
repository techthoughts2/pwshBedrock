---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandRModel/
schema: 2.0.0
---

# Invoke-CohereCommandRModel

## SYNOPSIS
Sends message(s) to the Cohere Command R/R+ model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

### MessageSet
```
Invoke-CohereCommandRModel -Message <String> -ModelID <String> [-ReturnFullObject] [-NoContextPersist]
 [-ChatHistory <PSObject[]>] [-Documents <PSObject[]>] [-SearchQueriesOnly <Boolean>] [-Preamble <String>]
 [-MaxTokens <Int32>] [-Temperature <Single>] [-TopP <Single>] [-TopK <Int32>] [-PromptTruncation <String>]
 [-FrequencyPenalty <Single>] [-PresencePenalty <Single>] [-Seed <Int32>] [-ReturnPrompt <Boolean>]
 [-Tools <PSObject[]>] [-StopSequences <String[]>] [-RawPrompting <Boolean>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### ToolsResultsSet
```
Invoke-CohereCommandRModel -ModelID <String> [-ReturnFullObject] [-NoContextPersist]
 [-ChatHistory <PSObject[]>] [-Documents <PSObject[]>] [-SearchQueriesOnly <Boolean>] [-Preamble <String>]
 [-MaxTokens <Int32>] [-Temperature <Single>] [-TopP <Single>] [-TopK <Int32>] [-PromptTruncation <String>]
 [-FrequencyPenalty <Single>] [-PresencePenalty <Single>] [-Seed <Int32>] [-ReturnPrompt <Boolean>]
 [-Tools <PSObject[]>] [-ToolsResults <PSObject[]>] [-StopSequences <String[]>] [-RawPrompting <Boolean>]
 [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Sends a message to an Cohere Command R/R+ model on the Amazon Bedrock platform and returns the model's response.
The cmdlet estimates the cost of model usage based on the provided input and output tokens and adds the estimate to the models tally information.
Conversation context is supported by these models.
See the notes section for more information.

## EXAMPLES

### EXAMPLE 1
```
Invoke-CohereCommandRModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-r-v1:0' -Credential $awsCredential -Region 'us-west-2'
```

Sends a text message to the on-demand Cohere Command R model in the specified AWS region and returns the response.

### EXAMPLE 2
```
Invoke-CohereCommandRModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-r-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Sends a text message to the on-demand Cohere Command R model in the specified AWS region and returns the full response object.

### EXAMPLE 3
```
$chatHistory = @(
    [PSCustomObject]@{ role = 'USER'; message = 'Who is the best Starfleet captain?' },
    [PSCustomObject]@{ role = 'CHATBOT'; message = 'Captain Kirk.' },
    [PSCustomObject]@{ role = 'USER'; message = 'Are you sure about that?' },
    [PSCustomObject]@{ role = 'CHATBOT'; message = 'Quite sure, why?' }
)
$standardTools = @(
    [PSCustomObject]@{
        name                  = "string"
        description           = "string"
        parameter_definitions = @{
            "parameter name" = [PSCustomObject]@{
                description = "string"
                type        = "string"
                required    = $true
            }
        }
    }
)
$standardToolsResults = @(
    [PSCustomObject]@{
        call    = [PSCustomObject]@{
            name       = "string"
            parameters = [PSCustomObject]@{
                "parameter name" = "string"
            }
        }
        outputs = @(
            [PSCustomObject]@{
                text = "string"
            }
        )
    }
)
$documents = @(
    [PSCustomObject]@{
        title   = 'Making it so.'
        snippet = 'The line must be drawn here! This far, no further!'
    }
)
$invokeAmazonTextModelSplat = @{
    Message           = 'Shaka, when the walls fell.'
    ModelID           = 'cohere.command-r-plus-v1:0'
    NoContextPersist  = $true
    ChatHistory       = $chatHistory
    Documents         = $documents
    Preamble          = 'You are a StarTrek trivia master.'
    MaxTokens         = 3000
    Temperature       = 0.5
    ReturnPrompt      = $true
    Tools             = $standardTools
    ToolsResults      = $standardToolsResults
    StopSequences     = @('Kirk')
    RawPrompting      = $true
    AccessKey         = 'ak'
    SecretKey         = 'sk'
    Region            = 'us-west-2'
}
Invoke-CohereCommandRModel @invokeAmazonTextModelSplat
```

Sends a message to the on-demand Cohere Command R+ model in the specified AWS region with custom parameters and returns the response.

## PARAMETERS

### -Message
The message to be sent to the model.

```yaml
Type: String
Parameter Sets: MessageSet
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

### -ChatHistory
Previous messages between the user and the model, meant to give the model conversational context for responding to the user's message.
This must be in a properly formatted PSObject array with role and message properties.

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

### -Documents
A list of texts that the model can cite to generate a more accurate reply.
Each document contains a title and snippet.
The resulting generation includes citations that reference some of these documents.
We recommend that you keep the total word count of the strings in the dictionary to under 300 words.

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

### -SearchQueriesOnly
Defaults to false.
When true, the response will only contain a list of generated search queries, but no search will take place, and no reply from the model to the user's message will be generated.

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

### -Preamble
A preamble is a system message that is provided to a model at the beginning of a conversation which dictates how the model should behave throughout.
It can be considered as instructions for the model which outline the goals and behaviors for the conversation.

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

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 4000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Temperature
The amount of randomness injected into the response.

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

### -TopK
Specify the number of token choices the model uses to generate the next token.

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

### -PromptTruncation
AUTO_PRESERVE_ORDER, some elements from chat_history and documents will be dropped to construct a prompt that fits within the model's context length limit.
During this process the order of the documents and chat history will be preserved.
With prompt_truncation\` set to OFF, no elements will be dropped.

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

### -FrequencyPenalty
Used to reduce repetitiveness of generated tokens.
The higher the value, the stronger a penalty is applied to previously present tokens, proportional to how many times they have already appeared in the prompt or prior generation.

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

### -PresencePenalty
Used to reduce repetitiveness of generated tokens.
Similar to frequency_penalty, except that this penalty is applied equally to all tokens that have already appeared, regardless of their exact frequencies.

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

### -Seed
If specified, the backend will make a best effort to sample tokens deterministically, such that repeated requests with the same seed and parameters should return the same result.
However, determinism cannot be totally guaranteed.

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

### -ReturnPrompt
Specify true to return the full prompt that was sent to the model.
The default value is false.
In the response, the prompt in the prompt field.

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

### -Tools
A list of available tools (functions) that the model may suggest invoking before producing a text response.
When tools is passed (without tool_results), the text field in the response will be "" and the tool_calls field in the response
will be populated with a list of tool calls that need to be made.
If no calls need to be made, the tool_calls array will be empty.
This must be in a properly formatted PSObject array with all required Tools properties.
For more information, see the Cohere documentation.

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

### -ToolsResults
A list of results from invoking tools recommended by the model in the previous chat turn.
Results are used to produce a text response and are referenced in citations.
When using tool_results, tools must be passed as well.
Each tool_result contains information about how it was invoked, as well as a list of outputs in the form of dictionaries.
Cohere's unique fine-grained citation logic requires the output to be a list.
This must be in a properly formatted PSObject array with all required ToolsResults properties.
For more information, see the Cohere documentation.

```yaml
Type: PSObject[]
Parameter Sets: ToolsResultsSet
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StopSequences
Custom text sequences that cause the model to stop generating.
This must be in a properly formatted string array.
For more information, see the Cohere documentation.

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

### -RawPrompting
Specify true, to send the user's message to the model without any preprocessing, otherwise false.

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

The Cohere Command R/R+ models support a unique feature that allows you to directly pass conversation chat history as a dedicated parameter.
This helps maintain context across multiple messages, useful for a conversational flow.

By default, pwshBedrock automatically manages context history for models that support it, including the Cohere Command R/R+ models.
This context history is stored in a global variable and is used to maintain conversation context across multiple messages.

If you send messages to the model without using the -NoContextPersist parameter, pwshBedrock will keep track of the context for you.
The context history will be automatically populated in the ChatHistory for subsequent messages.

If you prefer to provide your own ChatHistory using the -ChatHistory parameter, pwshBedrock will discard its own context history and use the provided ChatHistory instead.
This effectively resets pwshBedrock's context management for that model.
You will need to manage the ChatHistory yourself if you use this parameter.

In summary:
- Without -NoContextPersist: pwshBedrock manages context automatically and populates ChatHistory for you.
- With -ChatHistory: pwshBedrock discards its context history and uses the provided ChatHistory.
You need to manage the context yourself.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandRModel/](https://www.pwshbedrock.dev/en/latest/Invoke-CohereCommandRModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command-r-plus.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-cohere-command-r-plus.html)

[https://docs.cohere.com/docs/command-r](https://docs.cohere.com/docs/command-r)

[https://docs.cohere.com/docs/command-r-plus](https://docs.cohere.com/docs/command-r-plus)

[https://docs.cohere.com/docs/tool-use](https://docs.cohere.com/docs/tool-use)
