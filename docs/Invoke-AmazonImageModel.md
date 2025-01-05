---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-AmazonImageModel/
schema: 2.0.0
---

# Invoke-AmazonImageModel

## SYNOPSIS
Sends message(s) to an Amazon Titan image model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local directory.

## SYNTAX

### Generation
```
Invoke-AmazonImageModel -ImagesSavePath <Object> -ImagePrompt <String> [-Seed <Int32>] [-NegativeText <String>]
 [-NumberOfImages <Int32>] [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>] -ModelID <String>
 [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### InPaint
```
Invoke-AmazonImageModel -ImagesSavePath <Object> -InPaintImagePath <String> [-InPaintTextPrompt <String>]
 [-InPaintMaskPrompt <String>] [-InPaintMaskImagePath <String>] [-NegativeText <String>]
 [-NumberOfImages <Int32>] [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>] -ModelID <String>
 [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### OutPaint
```
Invoke-AmazonImageModel -ImagesSavePath <Object> -OutPaintImagePath <String> -OutPaintTextPrompt <String>
 [-OutPaintMaskPrompt <String>] [-OutPaintMaskImagePath <String>] [-OutPaintMode <String>]
 [-NegativeText <String>] [-NumberOfImages <Int32>] [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>]
 -ModelID <String> [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

### Variation
```
Invoke-AmazonImageModel -ImagesSavePath <Object> -VariationImagePath <String[]> -VariationTextPrompt <String>
 [-SimilarityStrength <Single>] [-NegativeText <String>] [-NumberOfImages <Int32>] [-Width <Int32>]
 [-Height <Int32>] [-CfgScale <Single>] -ModelID <String> [-ReturnFullObject] [-AccessKey <String>]
 [-Credential <AWSCredentials>] [-EndpointUrl <String>] [-NetworkCredential <PSCredential>]
 [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>]
 [-SessionToken <String>] [<CommonParameters>]
```

### Condition
```
Invoke-AmazonImageModel -ImagesSavePath <Object> [-ConditionImagePath <String>] -ConditionTextPrompt <String>
 [-ControlMode <String>] [-ControlStrength <Single>] [-NegativeText <String>] [-NumberOfImages <Int32>]
 [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>] -ModelID <String> [-ReturnFullObject]
 [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### ColorGuided
```
Invoke-AmazonImageModel -ImagesSavePath <Object> [-ColorGuidedImagePath <String>]
 -ColorGuidedTextPrompt <String> -Colors <String[]> [-NegativeText <String>] [-NumberOfImages <Int32>]
 [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>] -ModelID <String> [-ReturnFullObject]
 [-AccessKey <String>] [-Credential <AWSCredentials>] [-EndpointUrl <String>]
 [-NetworkCredential <PSCredential>] [-ProfileLocation <String>] [-ProfileName <String>] [-Region <Object>]
 [-SecretKey <String>] [-SessionToken <String>] [<CommonParameters>]
```

### BackgroundRemoval
```
Invoke-AmazonImageModel -ImagesSavePath <Object> [-BackgroundRemovalImagePath <String>]
 [-NegativeText <String>] [-NumberOfImages <Int32>] [-Width <Int32>] [-Height <Int32>] [-CfgScale <Single>]
 -ModelID <String> [-ReturnFullObject] [-AccessKey <String>] [-Credential <AWSCredentials>]
 [-EndpointUrl <String>] [-NetworkCredential <PSCredential>] [-ProfileLocation <String>]
 [-ProfileName <String>] [-Region <Object>] [-SecretKey <String>] [-SessionToken <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends a message to an Amazon Titan on the Amazon Bedrock platform and returns the model's response.
The response from this model is an image or images generated based on the input parameters.
The generated image(s) are decoded from base64 and saved to a local directory.
This function supports the following Amazon Titan image use cases:
Text-to-image - Generation - Generate an image using a text prompt.
Inpainting - Editing - Modify an image by changing the inside of a mask to match the surrounding background.
Outpainting - Editing - Modify an image by seamlessly extending the region defined by the mask.
Image Variation - Editing - Modify an image by producing variations of the original image.
Conditioning - Generation - Generate an image based on the text prompt and by providing a 'condition image' to achieve more fine-grained control over the resulting generated image.
Color Guided Generation - Generation - Provide a list of hex color codes along with a text prompt to generate an image that follows the color palette.
Background Removal - Editing - Remove the background from an image.

## EXAMPLES

### EXAMPLE 1
```
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'amazon.titan-image-generator-v2:0' -Credential $awsCredential -Region 'us-west-2'
```

Generates an image and saves the image to the C:\temp folder.

### EXAMPLE 2
```
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -VariationImagePath 'C:\temp\image1.png' -VariationTextPrompt 'Add more stars and space debris.' -ModelID 'amazon.titan-image-generator-v2:0' -Credential $awsCredential -Region 'us-west-2'
```

Generates variations of the image located at C:\temp\image1.png and saves the images to the C:\temp folder.

### EXAMPLE 3
```
$invokeAmazonImageSplat = @{
    ImagesSavePath   = 'C:\temp'
    ImagePrompt      = 'Create a starship emerging from a nebula.'
    Seed             = 200
    NegativeText     = 'stars'
    NumberOfImages   = 1
    Width            = 1024
    Height           = 1024
    CfgScale         = 10
    ModelID          = 'amazon.titan-image-generator-v2:0'
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Generates an image and saves the image to the specified folder.

### EXAMPLE 4
```
$invokeAmazonImageSplat = @{
    ImagesSavePath       = 'C:\temp'
    InPaintImagePath     = $inpaintingMainImage
    InPaintTextPrompt    = 'Make it glow.'
    InPaintMaskImagePath = $inpaintingMaskImage
    ModelID              = $ModelID
    Credential           = $awsCredential
    Region               = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Modifies an image by changing the inside of a mask to match the surrounding background and saves the image to the specified folder.
You must provide a masked image identical and inside and use RGB value of (0 0 0) for pixels inside the mask, and (255 255 255) for pixels outside the mask.

### EXAMPLE 5
```
$invokeAmazonImageSplat = @{
    ImagesSavePath        = 'C:\temp'
    OutPaintImagePath     = $outpaintingMainImage
    OutPaintTextPrompt    = 'Add more stars.'
    OutPaintMaskImagePath = $outpaintingMaskImage
    ModelID               = $ModelID
    Credential            = $awsCredential
    Region                = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Modifies an image by seamlessly extending the region defined by the mask and saves the image to the specified folder.
You must provide a masked image identical and inside and use RGB value of (0 0 0) for pixels inside the mask, and (255 255 255) for pixels outside the mask.

### EXAMPLE 6
```
$invokeAmazonImageSplat = @{
    ImagesSavePath      = 'C:\temp'
    VariationImagePath  = $variationMainImage
    VariationTextPrompt = 'Replace the captain with a different crew member.'
    ModelID             = $ModelID
    ReturnFullObject    = $true
    Credential          = $awsCredential
    Region              = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Generates variations of the image located at $variationMainImage and saves the images to the specified folder.

### EXAMPLE 7
```
$invokeAmazonImageSplat = @{
    ImagesSavePath      = 'C:\temp'
    ConditionImagePath  = $conditioningMainImage
    ConditionTextPrompt = 'Create a starship emerging from a nebula.'
    ControlMode         = 'CANNY_EDGE'
    ControlStrength     = 0.5
    ModelID             = $ModelID
    Credential          = $awsCredential
    Region              = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Generates an image based on the text prompt and the conditioning image and saves the image to the specified folder.
The layout and composition of the generated image are guided by the conditioning image.
The control mode is set to CANNY_EDGE and the control strength is set to 0.5.

### EXAMPLE 8
```
$invokeAmazonImageSplat = @{
    ImagesSavePath        = 'C:\temp'
    ColorGuidedTextPrompt = 'Create a starship emerging from a nebula.'
    Colors                = @('#FF0000', '#00FF00', '#0000FF')
    ModelID               = $ModelID
    Credential            = $awsCredential
    Region                = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Generates an image based on the text prompt colored by the specified hex colors and saves the image to the specified folder.

### EXAMPLE 9
```
$invokeAmazonImageSplat = @{
    ImagesSavePath             = 'C:\temp'
    BackgroundRemovalImagePath = $backgroundRemovalImage
    ModelID                    = $ModelID
    Credential                 = $awsCredential
    Region                     = 'us-west-2'
}
Invoke-AmazonImageModel @invokeAmazonImageSplat
```

Removes the background from the image located at $backgroundRemovalImage and saves the image to the specified folder.

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
Type: String
Parameter Sets: Generation
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Seed
Use to control and reproduce results.
Determines the initial noise setting.
Use the same seed and the same settings as a previous run to allow inference to create a similar image.

```yaml
Type: Int32
Parameter Sets: Generation
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -InPaintImagePath
File path to local media to be modified.

```yaml
Type: String
Parameter Sets: InPaint
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InPaintTextPrompt
A text prompt to define what to change inside the mask.
If you don't include this field, the model tries to replace the entire mask area with the background.

```yaml
Type: String
Parameter Sets: InPaint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InPaintMaskPrompt
A text prompt that defines the mask.

```yaml
Type: String
Parameter Sets: InPaint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InPaintMaskImagePath
File path to local media containing the masked image.

```yaml
Type: String
Parameter Sets: InPaint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPaintImagePath
File path to local media to be modified.

```yaml
Type: String
Parameter Sets: OutPaint
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPaintTextPrompt
A text prompt to define what to change outside the mask.

```yaml
Type: String
Parameter Sets: OutPaint
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPaintMaskPrompt
A text prompt that defines the mask.

```yaml
Type: String
Parameter Sets: OutPaint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPaintMaskImagePath
File path to local media containing the masked image.

```yaml
Type: String
Parameter Sets: OutPaint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPaintMode
Specifies whether to allow modification of the pixels inside the mask or not.
DEFAULT - Use this option to allow modification of the image inside the mask in order to keep it consistent with the reconstructed background.
PRECISE - Use this option to prevent modification of the image inside the mask.

```yaml
Type: String
Parameter Sets: OutPaint
Aliases:

Required: False
Position: Named
Default value: DEFAULT
Accept pipeline input: False
Accept wildcard characters: False
```

### -VariationImagePath
File path to local media files for which to generate variations.
More than one file path can be provided.

```yaml
Type: String[]
Parameter Sets: Variation
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VariationTextPrompt
A text prompt that can define what to preserve and what to change in the image.

```yaml
Type: String
Parameter Sets: Variation
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SimilarityStrength
Specifies how similar the generated image should be to the input image. 
Use a lower value to introduce more randomness in the generation.
Accepted range is between 0.2 and 1.0 (both inclusive), while a default of 0.7 is used if this parameter is missing in the request.

```yaml
Type: Single
Parameter Sets: Variation
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConditionImagePath
File path to local media file conditioning image that guides the layout and composition of the generated image.
V2 only.
A single input conditioning image that guides the layout and composition of the generated image

```yaml
Type: String
Parameter Sets: Condition
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConditionTextPrompt
A text prompt to generate the image.
V2 only.

```yaml
Type: String
Parameter Sets: Condition
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ControlMode
Specifies that type of conditioning mode should be used.
V2 only.

```yaml
Type: String
Parameter Sets: Condition
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ControlStrength
Specifies how similar the layout and composition of the generated image should be to the conditioningImage.
Lower values used to introduce more randomness.
V2 only.

```yaml
Type: Single
Parameter Sets: Condition
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColorGuidedImagePath
File path to local media file conditioning image that guides the color palette of the generated image.
V2 only.

```yaml
Type: String
Parameter Sets: ColorGuided
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColorGuidedTextPrompt
A text prompt to generate the image.
V2 only.

```yaml
Type: String
Parameter Sets: ColorGuided
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Colors
A list of up to 10 hex color codes to specify colors in the generated image.
V2 only.

```yaml
Type: String[]
Parameter Sets: ColorGuided
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackgroundRemovalImagePath
File path to local media file that you want to have the background removed from.
V2 only.

```yaml
Type: String
Parameter Sets: BackgroundRemoval
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NegativeText
A text prompt to define what not to include in the image.
Don't use negative words in the negativeText prompt.
For example, if you don't want to include mirrors in an image, enter mirrors in the negativeText prompt.
Don't enter no mirrors.

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

### -NumberOfImages
The number of images to generate.
The maximum number of images that can be generated is 5.

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

### -Width
The width of the image in pixels.
Only precise image sizes are supported.
See the Titan Image Model Parameters documentation for a list of supported image sizes.

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

### -Height
The height of the image in pixels.
Only precise image sizes are supported.
See the Titan Image Model Parameters documentation for a list of supported image sizes.

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

### -CfgScale
Specifies how strongly the generated image should adhere to the prompt.
Use a lower value to introduce more randomness in the generation.

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

### -ModelID
The unique identifier of the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: Amazon.titan-image-generator-v2:0
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
I have not had much luck with the INPAINTING and OUTPAINTING functionality.
They seem to be very sensitive to the content filters.
That said, I'm not an image editing expert, so I may be doing something wrong.
Image generation and variation seem to work well.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-AmazonImageModel/](https://www.pwshbedrock.dev/en/latest/Invoke-AmazonImageModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html](https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html)

[https://docs.aws.amazon.com/nova/latest/userguide/image-gen-req-resp-structure.html](https://docs.aws.amazon.com/nova/latest/userguide/image-gen-req-resp-structure.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html)
