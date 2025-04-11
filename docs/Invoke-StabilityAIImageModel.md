---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIImageModel/
schema: 2.0.0
---

# Invoke-StabilityAIImageModel

## SYNOPSIS

Sends message(s) to an Stability AI Image Core model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local folder.

## SYNTAX

```powershell
Invoke-StabilityAIImageModel [-ImagesSavePath] <Object> [-ImagePrompt] <String> [[-InitImagePath] <String>]
 [[-ImageStrength] <Single>] [[-AspectRatio] <String>] [[-OutputFormat] <String>] [[-Seed] <Int32>]
 [[-NegativePrompt] <String>] [[-ModelID] <String>] [-ReturnFullObject] [[-AccessKey] <String>]
 [[-Credential] <AWSCredentials>] [[-EndpointUrl] <String>] [[-NetworkCredential] <PSCredential>]
 [[-ProfileLocation] <String>] [[-ProfileName] <String>] [[-Region] <Object>] [[-SecretKey] <String>]
 [[-SessionToken] <String>] [<CommonParameters>]
```

## DESCRIPTION

Sends a message to an Stability AI Image Core model on the Amazon Bedrock platform and returns the model's response.
The response from this model is an image or images generated based on the input parameters.
The generated image(s) are decoded from base64 and saved to a local folder.
This function supports the following Stability AI Image Core image use cases:
    Text-to-image - Generation - Generate an image using a text prompt.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-StabilityAIImageModel -ImagesSavePath 'C:\images' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-image-core-v1:0' -Credential $awsCredential -Region 'us-west-2'
```

Generates an image and saves the image to the C:\images folder.

### EXAMPLE 2

```powershell
Invoke-StabilityAIImageModel -ImagesSavePath 'C:\images' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-image-ultra-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject
```

Generates an image and saves the image to the C:\images folder.
Returns the full object from the model.

### EXAMPLE 3

```powershell
$invokeStabilityAIImageModelSplat = @{
    ImagesSavePath     = 'C:\images'
    ImagePrompt        = 'Create a starship emerging from a nebula.'
    AspectRatio        = '1:1'
    OutputFormat       = 'jpeg'
    Seed               = 1234
    NegativePrompt     = 'stars'
    ModelID            = 'stability.stable-image-core-v1:0'
    ReturnFullObject   = $true
    Credential         = $awsCredential
    Region             = 'us-west-2'
}
Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
```

This command generates an image based on the provided prompt and saves the image to the specified folder ('C:\images\image.png').
This image will have a 1:1 aspect ratio and be in JPEG format.
The seed is set to 1234, and the model is told to avoid the concept of stars.

### EXAMPLE 4

```powershell
$invokeStabilityAIImageModelSplat = @{
    ImagesSavePath = 'C:\images'
    ImagePrompt    = 'Create a starship emerging from a nebula.'
    InitImagePath  = 'C:\images\init.jpg'
    ImageStrength  = 0.5
    ModelID        = 'stability.sd3-large-v1:0'
    Credential     = $awsCredential
    Region         = 'us-west-2'
}
Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
```

This command generates an image based on the provided prompt and initial image and saves the image to the specified folder ('C:\images\image.png').
The image strength is set to 0.5.
The provided init image is used as a starting point for the generation.

## PARAMETERS

### -ImagesSavePath

The local file path to save the generated images.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImagePrompt

A text prompt used to generate the image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InitImagePath

File path to image to use as the starting point for the generation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImageStrength

Sometimes referred to as denoising, this parameter controls how much influence the image parameter has on the generated image.
A value of 0 would yield an image that is identical to the input.
A value of 1 would be as if you passed in no image at all.

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -AspectRatio

Controls the aspect ratio of the generated image.
Only valid for text-to-image requests.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 1:1
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFormat

Specifies the format of the output image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Png
Accept pipeline input: False
Accept wildcard characters: False
```

### -Seed

The seed determines the initial noise setting.
Use the same seed and the same settings as a previous run to allow inference to create a similar image.
If you don't set this value, or the value is 0, it is set as a random number.
If a seed is provided, the resulting generated image will be deterministic.
What this means is that as long as all generation parameters remain the same, you can always recall the same image simply by generating it again.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NegativePrompt

Use a negative prompt to tell the model to avoid certain concepts.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
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

Required: False
Position: 9
Default value: Stability.stable-image-core-v1:0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnFullObject

Specify if you want the full object returned from the model.
This will include the raw base64 image data and other information.

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

### -AccessKey

The AWS access key for the user account.
This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
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
Position: 11
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
Position: 12
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
Position: 13
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
Position: 14
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
Position: 15
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
Position: 16
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
Position: 17
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
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIImageModel/](https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIImageModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-stable-image-core-text-image-request-response.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-stable-image-core-text-image-request-response.html)

[https://platform.stability.ai/docs/api-reference#tag/Generate/paths/~1v2beta~1stable-image~1generate~1core/post](https://platform.stability.ai/docs/api-reference#tag/Generate/paths/~1v2beta~1stable-image~1generate~1core/post)
