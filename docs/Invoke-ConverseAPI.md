---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-ConverseAPI/
schema: 2.0.0
---

# Invoke-ConverseAPI

## SYNOPSIS

Sends messages, media, or documents to a model via the Converse API and returns the response.

## SYNTAX

### MessageSet (Default)

```powershell
Invoke-ConverseAPI -ModelID <String> [-Message <String>] [-ImagePath <String[]>] [-DocumentPath <String[]>]
 [-ReturnFullObject] [-NoContextPersist] [-MaxTokens <Int32>] [-StopSequences <String[]>]
 [-Temperature <Single>] [-TopP <Single>] [-SystemPrompt <String>] [-Tools <PSObject[]>] [-ToolChoice <String>]
 [-ToolName <String>] [-GuardrailID <String>] [-GuardrailVersion <String>] [-GuardrailTrace <String>]
 [-AdditionalModelRequestField <PSObject>] [-AdditionalModelResponseFieldPath <String[]>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### ToolsResultsSet

```powershell
Invoke-ConverseAPI -ModelID <String> [-ReturnFullObject] [-NoContextPersist] [-MaxTokens <Int32>]
 [-StopSequences <String[]>] [-Temperature <Single>] [-TopP <Single>] [-SystemPrompt <String>]
 [-Tools <PSObject[]>] [-ToolChoice <String>] [-ToolName <String>] -ToolsResults <PSObject[]>
 [-GuardrailID <String>] [-GuardrailVersion <String>] [-GuardrailTrace <String>]
 [-AdditionalModelRequestField <PSObject>] [-AdditionalModelResponseFieldPath <String[]>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

## DESCRIPTION

Uses the Converse API to send messages, media, or documents to a model and returns the response.
Converse provides a consistent interface that works with most models that support messages.
This allows you to write code once and use it with different models.
It also provides a consistent response format for each model.
This function supports a base set of inference parameters that are common to all models.
If you need to pass additional parameters that the model supports, use the AdditionalModelRequestField parameter.
Not all models support all capabilities.
Consult the Converse API documentation to determine what is supported by the model you are using.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1
```

Sends a message to the on-demand specified model via the Converse API in the specified AWS region and returns the response.

### EXAMPLE 2

```powershell
Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1 -ReturnFullObject
```

Sends a message to the on-demand specified model via the Converse API in the specified AWS region and returns the full response object.

### EXAMPLE 3

```powershell
$additionalParams = [PSObject]@{
    top_k = 200
}
Invoke-ConverseAPI -ModelID anthropic.claude-3-sonnet-20240229-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -AdditionalModelRequestField $additionalParams -Region us-west-2
```

Sends a message to the on-demand specified model via the Converse API.
Additional parameters not natively supported by Converse API are passed in that are supported by the model.

### EXAMPLE 4

```powershell
$invokeConverseAPISplat = @{
    Message      = 'Explain zero-point energy.'
    ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
    SystemPrompt = 'You are a physicist explaining zero-point energy to a layperson.'
    Credential   = $awsCredential
    Region       = 'us-west-2'
}
Invoke-ConverseAPI @invokeConverseAPISplat
```

Sends a message to the on-demand specified model via the Converse API.
A system prompt is provided to set the context for the model.

### EXAMPLE 5

```powershell
$invokeConverseAPISplat = @{
    Message          = 'Explain zero-point energy.'
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    SystemPrompt     = 'You are a physicist explaining zero-point energy to a layperson.'
    StopSequences    = @('Finished')
    MaxTokens        = 200
    Temperature      = 0.5
    TopP             = 0.9
    Credential       = $awsCredential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
Invoke-ConverseAPI @invokeConverseAPISplat
```

Sends a message to the on-demand specified model via the Converse API.
Additional parameters are provided to control the response generation.

### EXAMPLE 6

```powershell
$invokeConverseAPISplat = @{
    Message          = 'Please describe the painting in the attached image.'
    ImagePath        = $pathToImageFile
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    ReturnFullObject = $true
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
Invoke-ConverseAPI @invokeConverseAPISplat
```

Sends an image vision message to the on-demand specified model via the Converse API.
The model will describe the image in the image file.

### EXAMPLE 7

```powershell
$invokeConverseAPISplat = @{
    Message          = 'Provide a one sentence summary of the document.'
    DocumentPath     = $pathToDocumentFile
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
Invoke-ConverseAPI @invokeConverseAPISplat
```

Sends a document message to the on-demand specified model via the Converse API.
The model will provide a one sentence summary of the document.

### EXAMPLE 8

```powershell
$tools = [PSCustomObject]@{
    Name        = 'restaurant'
    Description = 'This tool will look up restaurant information in a provided geographic area.'
    Properties  = @{
        location = [PSCustomObject]@{
            type        = 'string'
            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
        }
    }
    required    = @(
        'location'
    )
}
$invokeConverseAPISplat = @{
    Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    SystemPrompt     = 'You are a savvy foodie who loves giving restaurant recommendations.'
    ReturnFullObject = $true
    Tools            = $tools
    ToolChoice       = 'tool'
    ToolName         = 'restaurant'
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$response = Invoke-ConverseAPI @invokeConverseAPISplat
```

Sends a message to the on-demand specified model via the Converse API.
A tool is provided to answer the user's question.
Additional parameters are provided to require the use of the tool and to specify the tool to use.
This will prompt the model to return a tool-based response.

### EXAMPLE 9

```powershell
$tools = [PSCustomObject]@{
    Name        = 'restaurant'
    Description = 'This tool will look up restaurant information in a provided geographic area.'
    Properties  = @{
        location = [PSCustomObject]@{
            type        = 'string'
            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
        }
    }
    required    = @(
        'location'
    )
}
$toolsResults = [PSCustomObject]@{
    ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
    Content   = [PSCustomObject]@{
        restaurant = [PSCustomObject]@{
            name    = 'Gristmill River Restaurant & Bar'
            address = '1287 Gruene Rd, New Braunfels, TX 78130'
            rating  = '4.5'
            cuisine = 'American'
            budget  = '2'
        }
    }
    status    = 'success'
}
$invokeConverseAPISplat = @{
    ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
    Tools        = $tools
    ToolsResults = $toolsResults
    Credential   = $awsCredential
    Region       = 'us-west-2'
}
Invoke-ConverseAPI @invokeConverseAPISplat
```

Sends a message to the on-demand specified model via the Converse API.
A tool result is provided to the model to answer the user's question.

## PARAMETERS

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

### -Message

The message to be sent to the model.

```yaml
Type: String
Parameter Sets: MessageSet
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImagePath

File path to local image file.
Up to 20 image files can be sent in a single request.
The image files must adhere to the model's image requirements.

```yaml
Type: String[]
Parameter Sets: MessageSet
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentPath

File path to local document.
You can include up to five documents.
The document(s) must adhere to the model's document requirements.

```yaml
Type: String[]
Parameter Sets: MessageSet
Aliases:

Required: False
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

### -MaxTokens

The maximum number of tokens to allow in the generated response.

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

### -StopSequences

A list of stop sequences.
A stop sequence is a sequence of characters that causes the model to stop generating the response.

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

The likelihood of the model selecting higher-probability options while generating a response.

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

The percentage of most-likely candidates that the model considers for the next token.

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

### -SystemPrompt

Sets the behavior and context for the model in the conversation.
This field is not supported by all models.

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

### -Tools

Definitions of tools that the model may use.
This field is not supported by all models.

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

In some cases, you may want to use a specific tool to answer the user's question, even if the model thinks it can provide an answer without using a tool.
auto - allows model to decide whether to call any provided tools or not.
This is the default value.
any - tells model that it must use one of the provided tools, but doesn't force a particular tool.
tool - force model to always use a particular tool.
    if you specify tool, you must also provide the ToolName of the tool you want model to use.
This field is not supported by all models.

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

Optional parameter - The name of the tool that model should use to answer the user's question.
This parameter is only required if you set the ToolChoice parameter to tool.
This field is not supported by all models.

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

### -GuardrailID

The identifier for the guardrail.
This is the id for the guardrail you have created in the Amazon Bedrock console.
Note: Guardrails are specific to the region in which they are created.
If you specify a guardrail, you must also specify the GuardrailVersion and GuardrailTrace parameters.

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

### -GuardrailVersion

The version of the guardrail.
This is the version of the guardrail you have created in the Amazon Bedrock console.
Acceptable values are a positive integer or the string 'DRAFT'.
If you specify a GuardrailVersion, you must also specify the GuardrailID and GuardrailTrace parameters

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

### -GuardrailTrace

The trace behavior for the guardrail.
If you specify a GuardrailTrace, you must also specify the GuardrailID and GuardrailVersion parameters.

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

### -AdditionalModelRequestField

Additional inference parameters that the model supports, beyond the base set of inference parameters that Converse supports.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdditionalModelResponseFieldPath

Additional model parameters field paths to return in the response.

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

### Amazon.BedrockRuntime.Model.ConverseResponse

## NOTES

Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

This was incredibly hard to make.

* Note: parameter value ranges such as TopP, Temperature, and MaxTokens are model-specific.
This function does not validate the values provided against the model's requirements.

* For a full tools example, see the advanced documentation on the pwshBedrock website.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-ConverseAPI/](https://www.pwshbedrock.dev/en/latest/Invoke-ConverseAPI/)

[https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/](https://www.pwshbedrock.dev/en/latest/pwshBedrock-Advanced/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html)

[https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html)

[https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InferenceConfiguration.html](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InferenceConfiguration.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-converse-api.html](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-converse-api.html)
