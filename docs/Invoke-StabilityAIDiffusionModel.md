---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIDiffusionModel/
schema: 2.0.0
---

# Invoke-StabilityAIDiffusionModel

## SYNOPSIS
Sends message(s) to an Stability AI Diffusion model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local folder.

## SYNTAX

### SimplePromptTextToImage (Default)
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -ImagePrompt <String[]> [-NegativePrompt <String[]>]
 [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>] [-ClipGuidancePreset <String>] [-Sampler <String>]
 [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>] [-StylePreset <String>] [-ModelID <String>]
 [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### SimplePromptImageToImageMask
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -ImagePrompt <String[]> [-NegativePrompt <String[]>]
 -InitMaskImagePath <String> -MaskSource <String> -MaskImagePath <String> [-CfgScale <Single>]
 [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>]
 [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### SimplePromptImageToImage
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -ImagePrompt <String[]> [-NegativePrompt <String[]>]
 -InitImagePath <String> [-InitImageMode <String>] [-ImageStrength <Single>] [-CfgScale <Single>]
 [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>]
 [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### SimplePrompt
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -ImagePrompt <String[]> [-NegativePrompt <String[]>]
 [-CfgScale <Single>] [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>]
 [-Steps <Int32>] [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### CustomPromptImageToImageMask
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -CustomPrompt <Object[]> -InitMaskImagePath <String>
 -MaskSource <String> -MaskImagePath <String> [-CfgScale <Single>] [-ClipGuidancePreset <String>]
 [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>] [-StylePreset <String>]
 [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

### CustomPromptImageToImage
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -CustomPrompt <Object[]> -InitImagePath <String>
 [-InitImageMode <String>] [-ImageStrength <Single>] [-CfgScale <Single>] [-ClipGuidancePreset <String>]
 [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>] [-StylePreset <String>]
 [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

### CustomPromptTextToImage
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -CustomPrompt <Object[]> [-Width <Int32>]
 [-Height <Int32>] [-CfgScale <Single>] [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>]
 [-Seed <Int32>] [-Steps <Int32>] [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject]
 [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### CustomPrompt
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -CustomPrompt <Object[]> [-CfgScale <Single>]
 [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>]
 [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### TextToImage
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> [-Width <Int32>] [-Height <Int32>]
 [-CfgScale <Single>] [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>]
 [-Steps <Int32>] [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### ImageToImage
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -InitImagePath <String> [-InitImageMode <String>]
 [-ImageStrength <Single>] -InitMaskImagePath <String> [-CfgScale <Single>] [-ClipGuidancePreset <String>]
 [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>] [-Steps <Int32>] [-StylePreset <String>]
 [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

### ImageToImageMask
```
Invoke-StabilityAIDiffusionModel -ImagesSavePath <Object> -MaskSource <String> -MaskImagePath <String>
 [-CfgScale <Single>] [-ClipGuidancePreset <String>] [-Sampler <String>] [-Samples <Int32>] [-Seed <Int32>]
 [-Steps <Int32>] [-StylePreset <String>] [-ModelID <String>] [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

## DESCRIPTION
Sends a message to an Stability AI Diffusion model on the Amazon Bedrock platform and returns the model's response.
The response from this model is an image or images generated based on the input parameters.
The generated image(s) are decoded from base64 and saved to a local folder.
This function supports the following Stability AI Diffusion image use cases:
    Text-to-image - Generation - Generate an image using a text prompt.
    Image-to-image - modifying new images based on a starting point image.
    Image-to-image-masking - masking out a specific area of an image, and then generating new details based on a provided prompt.
You can use ImagePrompt / NegativePrompt for providing quick string prompts, or CustomPrompt for more advanced prompt generation.
Prompts supplied via ImagePrompt will always be given a weight of 1, while prompts supplied via NegativePrompt will always be given a weight of -1.
If you wish to provide a custom prompt with a specific weight, use the CustomPrompt parameter.

## EXAMPLES

### EXAMPLE 1
```
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2'
```

Generates an image and saves the image to the C:\temp folder.

### EXAMPLE 2
```
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Make the nebula more purple' -InitImagePath 'C:\temp\nebula.png' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2'
```

Generates an image and saves the image to the C:\temp folder.
Returns the full object from the model.

### EXAMPLE 3
```
$invokeStabilityAIDiffusionModelSplat = @{
    ImagesSavePath    = 'C:\temp'
    ImagePrompt       = 'Make it darker.'
    InitMaskImagePath = 'C:\temp\image.png'
    MaskSource        = 'MASK_IMAGE_WHITE'
    MaskImagePath     = 'C:\images\mask_image.png'
    ModelID           = 'stability.stable-diffusion-xl-v1'
    ProfileName       = 'default'
    Region            = 'us-west-2'
}
Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
```

This command uses the Stability AI Diffusion Model to generate an image based on the provided prompt and mask.
Masking is a technique used to selectively apply changes to specific parts of an image.
In this example, the mask image ('C:\images\mask_image.png') contains a white cut-out area that indicates the region to be edited.
The model will use this white area to focus its modifications, leaving the rest of the image unchanged.
The generated image will be saved in the specified folder ('C:\temp').

### EXAMPLE 4
```
$invokeStabilityAIDiffusionModelSplat = @{
    ImagesSavePath     = 'C:\temp'
    ImagePrompt        = 'Create a starship emerging from a nebula.'
    CfgScale           = 7.0
    ClipGuidancePreset = 'SLOWEST'
    Sampler            = 'K_DPMPP_2S_ANCESTRAL'
    Steps              = 50
    StylePreset        = 'cinematic'
    ModelID            = 'stability.stable-diffusion-xl-v1'
    ReturnFullObject   = $true
    ProfileName        = 'default'
    Region             = 'us-west-2'
}
Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
```

This command generates an image based on the provided prompt and saves the image to the specified folder ('C:\images\image.png').
The image generation process is influenced by the CfgScale, ClipGuidancePreset, Sampler, Steps, and StylePreset parameters.

### EXAMPLE 5
```
$invokeStabilityAIDiffusionModelSplat = @{
    ImagesSavePath = 'C:\temp'
    ImagePrompt    = 'Replace the captain with a different crew member.'
    InitImagePath  = 'C:\temp\image.png'
    InitImageMode  = 'IMAGE_STRENGTH'
    ImageStrength  = 1.0
    ModelID        = 'stability.stable-diffusion-xl-v1'
    ProfileName    = 'default'
    Region         = 'us-west-2'
}
Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
```

This command generates an image based on the provided prompt and starting image.

### EXAMPLE 6
```
$invokeStabilityAIDiffusionModelSplat = @{
    ImagesSavePath = 'C:\images\image.jpeg'
    CustomPrompt   = @(
        [PSCustomObject]@{
            text   = 'Create a starship emerging from a nebula.'
            weight = 100
        }
        [PSCustomObject]@{
            text   = 'Do not include stars in the image.'
            weight = 5
        }
        [PSCustomObject]@{
            text   = 'star'
            weight = -1
        }
        [PSCustomObject]@{
            text   = 'stars'
            weight = -1
        }
    )
    Width          = 1024
    Height         = 1024
    ModelID        = $ModelID
    Credential     = $awsCredential
    Region         = 'us-west-2'
    Verbose        = $false
}
Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
```

This command generates an image based on the provided custom prompt.

## PARAMETERS

### -ImagesSavePath
The local file path to save the generated images.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImagePrompt
A text prompt used to generate the image.

```yaml
Type: String[]
Parameter Sets: SimplePromptTextToImage, SimplePromptImageToImageMask, SimplePromptImageToImage, SimplePrompt
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NegativePrompt
Use a negative prompt to tell the model to avoid certain concepts.

```yaml
Type: String[]
Parameter Sets: SimplePromptTextToImage, SimplePromptImageToImageMask, SimplePromptImageToImage, SimplePrompt
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomPrompt
Provide a set of weighted custom prompts to guide the generation of the image.
The custom prompt object should contain a text and weight property.
The weight property is a number that determines the importance of the prompt.
The higher the number, the more important the prompt.

```yaml
Type: Object[]
Parameter Sets: CustomPromptImageToImageMask, CustomPromptImageToImage, CustomPromptTextToImage, CustomPrompt
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Width
The width of the image in pixels.
Only precise image sizes are supported.
See the Stability AI Diffusion mode Parameters documentation for a list of supported image sizes.

```yaml
Type: Int32
Parameter Sets: SimplePromptTextToImage, CustomPromptTextToImage, TextToImage
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Height
The height of the image in pixels.
Only precise image sizes are supported.
See the Stability AI Diffusion mode Parameters documentation for a list of supported image sizes.

```yaml
Type: Int32
Parameter Sets: SimplePromptTextToImage, CustomPromptTextToImage, TextToImage
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -InitImagePath
File path to image that you want to use to initialize the diffusion process.

```yaml
Type: String
Parameter Sets: SimplePromptImageToImage, CustomPromptImageToImage, ImageToImage
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InitImageMode
Determines whether to use image_strength or step_schedule_* to control how much influence the image in init_image has on the result.

```yaml
Type: String
Parameter Sets: SimplePromptImageToImage, CustomPromptImageToImage, ImageToImage
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImageStrength
Determines how much influence the source image in init_image has on the diffusion process.
Values close to 1 yield images very similar to the source image.
Values close to 0 yield images very different than the source image.

```yaml
Type: Single
Parameter Sets: SimplePromptImageToImage, CustomPromptImageToImage, ImageToImage
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -InitMaskImagePath
File path to image that you want to use to initialize the mask diffusion process.

```yaml
Type: String
Parameter Sets: SimplePromptImageToImageMask, CustomPromptImageToImageMask, ImageToImage
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaskSource
Determines where to source the mask from.
MASK_IMAGE_WHITE - Use the white pixels of the mask image in mask_image as the mask.
White pixels are replaced and black pixels are left unchanged.
MASK_IMAGE_BLACK - Use the black pixels of the mask image in mask_image as the mask.
Black pixels are replaced and white pixels are left unchanged.
INIT_IMAGE_ALPHA - Use the alpha channel of the image in init_image as the mask, Fully transparent pixels are replaced and fully opaque pixels are left unchanged.

```yaml
Type: String
Parameter Sets: SimplePromptImageToImageMask, CustomPromptImageToImageMask, ImageToImageMask
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaskImagePath
File path to image that you want to use as a mask for the source image in init_image.
Must be the same dimensions as the source image.

```yaml
Type: String
Parameter Sets: SimplePromptImageToImageMask, CustomPromptImageToImageMask, ImageToImageMask
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CfgScale
Determines how much the final image portrays the prompt.
Use a lower number to increase randomness in the generation.

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

### -ClipGuidancePreset
CLIP Guidance is a technique that uses the CLIP neural network to guide the generation of images to be more in-line with your included prompt, which often results in improved coherency.

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

### -Sampler
The sampler to use for the diffusion process.
If this value is omitted, the model automatically selects an appropriate sampler for you.
If CLIP guidance is used, the sampler must be an ancestral sampler.

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

### -Samples
The number of image to generate.
Currently Amazon Bedrock supports generating one image.
If you supply a value for samples, the value must be one.

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
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Steps
Generation step determines how many times the image is sampled.
More steps can result in a more accurate result.

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

### -StylePreset
A style preset that guides the image model towards a particular style.
This list of style presets is subject to change.

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

### -ModelID
The unique identifier of the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Stability.stable-diffusion-xl-v1
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

### System.Management.Automation.PSCustomObject
## NOTES
Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

This was really hard to make.

A minimum of 262k pixels and a maximum of 1.04m pixels are recommended when generating images with 512px models, and a minimum of 589k pixels and a maximum of 1.04m pixels for 768px models.
The true pixel limit is 1048576.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIDiffusionModel/](https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIDiffusionModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-text-image.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-text-image.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-image-image.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-image-image.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-image-image-mask.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-image-image-mask.html)

[https://platform.stability.ai/docs/legacy/grpc-api/features/text-to-image](https://platform.stability.ai/docs/legacy/grpc-api/features/text-to-image)

[https://platform.stability.ai/docs/legacy/grpc-api/features/image-to-image](https://platform.stability.ai/docs/legacy/grpc-api/features/image-to-image)

[https://platform.stability.ai/docs/legacy/grpc-api/features/inpainting](https://platform.stability.ai/docs/legacy/grpc-api/features/inpainting)

[https://platform.stability.ai/docs/legacy/grpc-api/features/clip-guidance](https://platform.stability.ai/docs/legacy/grpc-api/features/clip-guidance)

[https://platform.stability.ai/docs/legacy/grpc-api/features/api-parameters#about-dimensions](https://platform.stability.ai/docs/legacy/grpc-api/features/api-parameters#about-dimensions)
