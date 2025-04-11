---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-AmazonNovaTextModel/
schema: 2.0.0
---

# Invoke-AmazonNovaTextModel

## SYNOPSIS

Sends message(s) to an Amazon Nova model on the Amazon Bedrock platform and retrieves the response.

## SYNTAX

### Standard

```powershell
Invoke-AmazonNovaTextModel -Message <String> [-MediaPath <String[]>] -ModelID <String> [-ReturnFullObject]
 [-NoContextPersist] [-MaxTokens <Int32>] [-SystemPrompt <String>] [-Temperature <Single>] [-TopP <Single>]
 [-TopK <Int32>] [-StopSequences <String[]>] [-Tools <PSObject[]>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### PreCraftedMessages

```powershell
Invoke-AmazonNovaTextModel -CustomConversation <PSObject[]> -ModelID <String> [-ReturnFullObject]
 [-NoContextPersist] [-MaxTokens <Int32>] [-SystemPrompt <String>] [-Temperature <Single>] [-TopP <Single>]
 [-TopK <Int32>] [-StopSequences <String[]>] [-Tools <PSObject[]>] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### ToolsResultsSet

```powershell
Invoke-AmazonNovaTextModel -ModelID <String> [-ReturnFullObject] [-NoContextPersist] [-MaxTokens <Int32>]
 [-SystemPrompt <String>] [-Temperature <Single>] [-TopP <Single>] [-TopK <Int32>] [-StopSequences <String[]>]
 [-Tools <PSObject[]>] -ToolsResults <PSObject[]> [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Sends a message to an Amazon Nova model on the Amazon Bedrock platform and returns the model's response.
You can send both text and media messages to the model.
If a media file is specified, it is converted to base64 according to the model's requirements.
By default, the conversation context history is persisted to maintain a continuous interaction with the model.
You can disable this by using the NoContextPersist parameter.
Additionally, the cmdlet estimates the cost of model usage
based on the provided input and output tokens and adds the estimate to the models tally information.
This model supports Function Calling, which allows the Amazon Nova model to connect to external tools.
You can provide the Tools parameter to specify the tools that the model may use and how.
If you are providing Tools to enable Function Calling, it is recommended that you use the ReturnFullObject parameter to capture the full response object.
See the pwshBedrock documentation for more information on Function Calling and the Amazon Nova model.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-east-1'
```

Sends a text message to the on-demand Amazon Nova model in the specified AWS region and returns the response.

### EXAMPLE 2

```powershell
Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Sends a text message to the on-demand Amazon Nova model in the specified AWS region and returns the full response object.

### EXAMPLE 3

```powershell
Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-west-2' -NoContextPersist
```

Sends a text message to the on-demand Amazon Nova model in the specified AWS region without persisting the conversation context history.
This is useful for one-off interactions.

### EXAMPLE 4

```powershell
$invokeAmazonNovaTextModelSplat = @{
    Message          = 'Can you name all of the Star Fleet captains featured in the various shows over the years?'
    ModelID          = 'amazon.nova-pro-v1:0'
    SystemPrompt     = 'You are an expert on all things Star Trek, having studied the show for decades. You often win Star Trek Trivia contests and enjoy sharing your vast knowledge of Star Trek with others.'
    Tools            = $starTrekTriviaFunctionTool
    Credential       = $credential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$objReturn = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
```

Sends a text message to the on-demand Amazon Nova model in the specified AWS region with a system prompt and returns the response.
A system prompt is provided to give additional context to the model on how to respond.
A tool is provided to the model to use if needed.
The tool choice is set to auto, allowing the model to decide if it should use the tool.
The tool is a function that provides Star Trek trivia information.

### EXAMPLE 5

```powershell
$invokeAmazonNovaTextModelSplat = @{
    Message          = 'What do you see in this photo?'
    MediaPath        = 'C:\path\to\image.jpg'
    ModelID          = 'amazon.nova-pro-v1:0'
    Credential       = $credential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$response = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
$response.output.message.content.text
```

Sends a text message with a image media file to the on-demand Amazon Nova model in the specified AWS region and returns the response.

### EXAMPLE 6

```powershell
$invokeAmazonNovaTextModelSplat = @{
    Message          = 'What do you see in this video?'
    MediaPath        = 'C:\path\to\video.mp4'
    ModelID          = 'amazon.nova-pro-v1:0'
    Credential       = $credential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$response = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
$response.output.message.content.text
```

Sends a text message with a video media file to the on-demand Amazon Nova model in the specified AWS region and returns the response.

### EXAMPLE 7

```powershell
$invokeAmazonNovaTextModelSplat = @{
    Message          = 'Summarize the document in three sentences'
    MediaPath        = 'C:\path\to\document.pdf'
    ModelID          = 'amazon.nova-pro-v1:0'
    Credential       = $credential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$response = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
$response.output.message.content.text
```

Sends a text message with a document media file to the on-demand Amazon Nova model in the specified AWS region and returns the response.

### EXAMPLE 8

```powershell
$customMessage = @(
    [PSCustomObject]@{
        role    = 'user'
        content = @(
            [PSCustomObject]@{
                text = 'Explain zero-point energy.'
            }
        )
    }
    [PSCustomObject]@{
        role    = 'assistant'
        content = @(
            [PSCustomObject]@{
                text = 'It is when someone in basketball is having a really bad game.'
            }
        )
    }
    [PSCustomObject]@{
        role    = 'user'
        content = @(
            [PSCustomObject]@{
                text = 'No, as it relates to physics.'
            }
        )
    }
)
$invokeAmazonNovaTextModelSplat = @{
    CustomConversation = $customMessage
    ModelID            = 'amazon.nova-pro-v1:0'
    Credential         = $credential
    Region             = 'us-east-1'
}
Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
```

Sends a custom conversation to the on-demand Amazon Nova model in the specified AWS region and returns the response.

## PARAMETERS

### -Message

The message to be sent to the model.

```yaml
Type: String
Parameter Sets: Standard
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaPath

File path to local media file.
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

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 5000
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemPrompt

The system prompt for the request.

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

[https://www.pwshbedrock.dev/en/latest/Invoke-AmazonNovaTextModel/](https://www.pwshbedrock.dev/en/latest/Invoke-AmazonNovaTextModel/)

[https://pwshbedrock.readthedocs.io/en/latest/pwshBedrock-Advanced/](https://pwshbedrock.readthedocs.io/en/latest/pwshBedrock-Advanced/)

[https://docs.aws.amazon.com/nova/latest/userguide/complete-request-schema.html](https://docs.aws.amazon.com/nova/latest/userguide/complete-request-schema.html)

[https://docs.aws.amazon.com/nova/latest/userguide/tool-use-results.html](https://docs.aws.amazon.com/nova/latest/userguide/tool-use-results.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html](https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html)

[https://docs.aws.amazon.com/nova/latest/userguide/modalities-image.html](https://docs.aws.amazon.com/nova/latest/userguide/modalities-image.html)

[https://docs.aws.amazon.com/nova/latest/userguide/modalities-document.html](https://docs.aws.amazon.com/nova/latest/userguide/modalities-document.html)

[https://docs.aws.amazon.com/nova/latest/userguide/modalities-video.html](https://docs.aws.amazon.com/nova/latest/userguide/modalities-video.html)
