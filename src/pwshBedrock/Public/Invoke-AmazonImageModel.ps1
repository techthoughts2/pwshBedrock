<#
.SYNOPSIS
    Sends message(s) to an Amazon Titan image model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local directory.
.DESCRIPTION
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
.EXAMPLE
    Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'amazon.titan-image-generator-v2:0' -Credential $awsCredential -Region 'us-west-2'

    Generates an image and saves the image to the C:\temp folder.
.EXAMPLE
    Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -VariationImagePath 'C:\temp\image1.png' -VariationTextPrompt 'Add more stars and space debris.' -ModelID 'amazon.titan-image-generator-v2:0' -Credential $awsCredential -Region 'us-west-2'

    Generates variations of the image located at C:\temp\image1.png and saves the images to the C:\temp folder.
.EXAMPLE
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

    Generates an image and saves the image to the specified folder.
.EXAMPLE
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

    Modifies an image by changing the inside of a mask to match the surrounding background and saves the image to the specified folder.
    You must provide a masked image identical and inside and use RGB value of (0 0 0) for pixels inside the mask, and (255 255 255) for pixels outside the mask.
.EXAMPLE
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

    Modifies an image by seamlessly extending the region defined by the mask and saves the image to the specified folder.
    You must provide a masked image identical and inside and use RGB value of (0 0 0) for pixels inside the mask, and (255 255 255) for pixels outside the mask.
.EXAMPLE
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

    Generates variations of the image located at $variationMainImage and saves the images to the specified folder.
.EXAMPLE
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

    Generates an image based on the text prompt and the conditioning image and saves the image to the specified folder.
    The layout and composition of the generated image are guided by the conditioning image.
    The control mode is set to CANNY_EDGE and the control strength is set to 0.5.
.EXAMPLE
    $invokeAmazonImageSplat = @{
        ImagesSavePath        = 'C:\temp'
        ColorGuidedTextPrompt = 'Create a starship emerging from a nebula.'
        Colors                = @('#FF0000', '#00FF00', '#0000FF')
        ModelID               = $ModelID
        Credential            = $awsCredential
        Region                = 'us-west-2'
    }
    Invoke-AmazonImageModel @invokeAmazonImageSplat

    Generates an image based on the text prompt colored by the specified hex colors and saves the image to the specified folder.
.EXAMPLE
    $invokeAmazonImageSplat = @{
        ImagesSavePath             = 'C:\temp'
        BackgroundRemovalImagePath = $backgroundRemovalImage
        ModelID                    = $ModelID
        Credential                 = $awsCredential
        Region                     = 'us-west-2'
    }
    Invoke-AmazonImageModel @invokeAmazonImageSplat

    Removes the background from the image located at $backgroundRemovalImage and saves the image to the specified folder.
.PARAMETER ImagesSavePath
    The local file path to save the generated images.
.PARAMETER ImagePrompt
    A text prompt used to generate the image.
.PARAMETER Seed
    Use to control and reproduce results. Determines the initial noise setting. Use the same seed and the same settings as a previous run to allow inference to create a similar image.
.PARAMETER InPaintImagePath
    File path to local media to be modified.
.PARAMETER InPaintTextPrompt
    A text prompt to define what to change inside the mask. If you don't include this field, the model tries to replace the entire mask area with the background.
.PARAMETER InPaintMaskPrompt
    A text prompt that defines the mask.
.PARAMETER InPaintMaskImagePath
    File path to local media containing the masked image.
.PARAMETER OutPaintImagePath
    File path to local media to be modified.
.PARAMETER OutPaintTextPrompt
    A text prompt to define what to change outside the mask.
.PARAMETER OutPaintMaskPrompt
    A text prompt that defines the mask.
.PARAMETER OutPaintMaskImagePath
    File path to local media containing the masked image.
.PARAMETER OutPaintMode
    Specifies whether to allow modification of the pixels inside the mask or not.
    DEFAULT – Use this option to allow modification of the image inside the mask in order to keep it consistent with the reconstructed background.
    PRECISE – Use this option to prevent modification of the image inside the mask.
.PARAMETER VariationImagePath
    File path to local media files for which to generate variations. More than one file path can be provided.
.PARAMETER VariationTextPrompt
    A text prompt that can define what to preserve and what to change in the image.
.PARAMETER SimilarityStrength
    Specifies how similar the generated image should be to the input image.  Use a lower value to introduce more randomness in the generation. Accepted range is between 0.2 and 1.0 (both inclusive), while a default of 0.7 is used if this parameter is missing in the request.
.PARAMETER ConditionImagePath
    File path to local media file conditioning image that guides the layout and composition of the generated image. V2 only.
    A single input conditioning image that guides the layout and composition of the generated image
.PARAMETER ConditionTextPrompt
    A text prompt to generate the image. V2 only.
.PARAMETER ControlMode
    Specifies that type of conditioning mode should be used. V2 only.
.PARAMETER ControlStrength
    Specifies how similar the layout and composition of the generated image should be to the conditioningImage. Lower values used to introduce more randomness. V2 only.
.PARAMETER ColorGuidedImagePath
    File path to local media file conditioning image that guides the color palette of the generated image. V2 only.
.PARAMETER ColorGuidedTextPrompt
    A text prompt to generate the image. V2 only.
.PARAMETER Colors
    A list of up to 10 hex color codes to specify colors in the generated image. V2 only.
.PARAMETER BackgroundRemovalImagePath
    File path to local media file that you want to have the background removed from. V2 only.
.PARAMETER NegativeText
    A text prompt to define what not to include in the image.
    Don't use negative words in the negativeText prompt. For example, if you don't want to include mirrors in an image, enter mirrors in the negativeText prompt. Don't enter no mirrors.
.PARAMETER NumberOfImages
    The number of images to generate.
    The maximum number of images that can be generated is 5.
.PARAMETER Width
    The width of the image in pixels.
    Only precise image sizes are supported. See the Titan Image Model Parameters documentation for a list of supported image sizes.
.PARAMETER Height
    The height of the image in pixels.
    Only precise image sizes are supported. See the Titan Image Model Parameters documentation for a list of supported image sizes.
.PARAMETER CfgScale
    Specifies how strongly the generated image should adhere to the prompt. Use a lower value to introduce more randomness in the generation.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER ReturnFullObject
    Specify if you want the full object returned from the model. This will include the raw base64 image data and other information.
.PARAMETER AccessKey
    The AWS access key for the user account. This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.
.PARAMETER Credential
    An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.
.PARAMETER EndpointUrl
    The endpoint to make the call against.
    Note: This parameter is primarily for internal AWS use and is not required/should not be specified for  normal usage. The cmdlets normally determine which endpoint to call based on the region specified to the -Region parameter or set as default in the shell (via Set-DefaultAWSRegion). Only specify this parameter if you must direct the call to a specific custom endpoint.
.PARAMETER NetworkCredential
    Used with SAML-based authentication when ProfileName references a SAML role profile.  Contains the network credentials to be supplied during authentication with the  configured identity provider's endpoint. This parameter is not required if the user's default network identity can or should be used during authentication.
.PARAMETER ProfileLocation
    Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs)
    If this optional parameter is omitted this cmdlet will search the encrypted credential file used by the AWS SDK for .NET and AWS Toolkit for Visual Studio first. If the profile is not found then the cmdlet will search in the ini-format credential file at the default location: (user's home directory)\.aws\credentials.
    If this parameter is specified then this cmdlet will only search the ini-format credential file at the location given.
    As the current folder can vary in a shell or during script execution it is advised that you use specify a fully qualified path instead of a relative path.
.PARAMETER ProfileName
    The user-defined name of an AWS credentials or SAML-based role profile containing credential information. The profile is expected to be found in the secure credential file shared with the AWS SDK for .NET and AWS Toolkit for Visual Studio. You can also specify the name of a profile stored in the .ini-format credential file used with  the AWS CLI and other AWS SDKs.
.PARAMETER Region
    The system name of an AWS region or an AWSRegion instance. This governs the endpoint that will be used when calling service operations. Note that  the AWS resources referenced in a call are usually region-specific.
.PARAMETER SecretKey
    The AWS secret key for the user account. This can be a temporary secret key if the corresponding session token is supplied to the -SessionToken parameter.
.PARAMETER SessionToken
    The session token if the access and secret keys are temporary session-based credentials.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    This was really hard to make.
    I have not had much luck with the INPAINTING and OUTPAINTING functionality. They seem to be very sensitive to the content filters.
    That said, I'm not an image editing expert, so I may be doing something wrong.
    Image generation and variation seem to work well.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-AmazonImageModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/image-gen-req-resp-structure.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html
#>
function Invoke-AmazonImageModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        #_______________________________________________________
        # required parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'The local file path to save the generated images.')]
        [ValidateScript({
                if (-not ($_ | Test-Path -PathType Container)) {
                    throw 'The Path argument must be a folder. File paths are not allowed.'
                }
                if (-not ($_ | Test-Path)) {
                    throw 'File or folder does not exist'
                }
                return $true
            })]
        $ImagesSavePath,
        #_______________________________________________________
        # image generation parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt used to generate the image.',
            ParameterSetName = 'Generation')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(0, 512)]
        [string]$ImagePrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use to control and reproduce results. Determines the initial noise setting.',
            ParameterSetName = 'Generation')]
        [ValidateRange(0, 2147483646)]
        [int]$Seed,

        #_______________________________________________________
        # inpainting parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to local media to be modified.',
            ParameterSetName = 'InPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$InPaintImagePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A text prompt to define what to change inside the mask.',
            ParameterSetName = 'InPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(0, 512)]
        [string]$InPaintTextPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A text prompt that defines the mask.',
            ParameterSetName = 'InPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$InPaintMaskPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media containing the masked image.',
            ParameterSetName = 'InPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$InPaintMaskImagePath,

        #_______________________________________________________
        # outpainting parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to local media to be modified.',
            ParameterSetName = 'OutPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$OutPaintImagePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt to define what to change outside the mask.',
            ParameterSetName = 'OutPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(0, 512)]
        [string]$OutPaintTextPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A text prompt that defines the mask.',
            ParameterSetName = 'OutPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$OutPaintMaskPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media containing the masked image.',
            ParameterSetName = 'OutPaint')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$OutPaintMaskImagePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies whether to allow modification of the pixels inside the mask or not.',
            ParameterSetName = 'OutPaint')]
        [ValidateSet(
            'DEFAULT',
            'PRECISE'
        )]
        [string]$OutPaintMode = 'DEFAULT',

        #_______________________________________________________
        # variation parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to local media files for which to generate variations. More than one file path can be provided.',
            ParameterSetName = 'Variation')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$VariationImagePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt that can define what to preserve and what to change in the image.',
            ParameterSetName = 'Variation')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(0, 512)]
        [string]$VariationTextPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies how similar the generated image should be to the input image.',
            ParameterSetName = 'Variation')]
        [ValidateRange(0.2, 1.0)]
        [float]$SimilarityStrength,
        #_______________________________________________________
        # conditioning parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file conditioning image that guides the layout and composition of the generated image.',
            ParameterSetName = 'Condition')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ConditionImagePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt to generate the image.',
            ParameterSetName = 'Condition')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(0, 512)]
        [string]$ConditionTextPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies that type of conditioning mode should be used.',
            ParameterSetName = 'Condition')]
        [ValidateSet(
            'CANNY_EDGE',
            'SEGMENTATION'
        )]
        [string]$ControlMode,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies how similar the layout and composition of the generated image should be to the conditioningImage. Lower values used to introduce more randomness.',
            ParameterSetName = 'Condition')]
        [ValidateRange(0.0, 1.0)]
        [float]$ControlStrength,
        #_______________________________________________________
        # color guided parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file conditioning image that guides the color palette of the generated image.',
            ParameterSetName = 'ColorGuided')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ColorGuidedImagePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt to generate the image.',
            ParameterSetName = 'ColorGuided')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(0, 512)]
        [string]$ColorGuidedTextPrompt,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A list of up to 10 hex color codes to specify colors in the generated image.',
            ParameterSetName = 'ColorGuided')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Colors,
        #_______________________________________________________
        # background removal parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file that you want to have the background removed from.',
            ParameterSetName = 'BackgroundRemoval')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$BackgroundRemovalImagePath,
        #_______________________________________________________
        # common image parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'A text prompt to define what not to include in the image.')]
        [string]$NegativeText,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The number of images to generate.')]
        [ValidateRange(1, 5)]
        [int]$NumberOfImages,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The width of the image in pixels.')]
        [ValidateSet(
            320,
            384,
            448,
            512,
            576,
            640,
            704,
            768,
            896,
            1024,
            1152,
            1173,
            1280,
            1408
        )]
        [int]$Width,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The height of the image in pixels.')]
        # [Parameter(ParameterSetName = 'Generation')]
        # [Parameter(ParameterSetName = 'InPaint')]
        [ValidateSet(
            320,
            384,
            448,
            512,
            576,
            640,
            704,
            768,
            896,
            1024,
            1152,
            1173,
            1280,
            1408
        )]
        [int]$Height,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies how strongly the generated image should adhere to the prompt.')]
        [ValidateRange(1.1, 9.9)]
        [float]$CfgScale,

        #_______________________________________________________

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'amazon.nova-canvas-v1:0',
            'amazon.titan-image-generator-v2:0',
            'amazon.titan-image-generator-v1'
        )]
        [string]$ModelID = 'amazon.titan-image-generator-v2:0',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specify if you want the full object returned from the model. This will include the raw base64 image data and other information.')]
        [switch]$ReturnFullObject,

        # Common Parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The AWS access key for the user account.')]
        [string]$AccessKey,

        [Parameter(Mandatory = $false,
            HelpMessage = 'An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.')]
        [Amazon.Runtime.AWSCredentials]$Credential,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The endpoint to make the call against. Not for normal use.')]
        [string]$EndpointUrl,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Used with SAML-based authentication when ProfileName references a SAML role profile.')]
        [System.Management.Automation.PSCredential]$NetworkCredential,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs)')]
        [string]$ProfileLocation,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The user-defined name of an AWS credentials or SAML-based role profile containing credential information.')]
        [string]$ProfileName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system name of an AWS region or an AWSRegion instance.')]
        [object]$Region,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The AWS secret key for the user account.')]
        [string]$SecretKey,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The session token if the access and secret keys are temporary session-based credentials.')]
        [string]$SessionToken

    )

    Write-Debug -Message ('Parameter Set Name: {0}' -f $PSCmdlet.ParameterSetName)

    $modelInfo = $script:amazonModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    switch ($PSCmdlet.ParameterSetName) {
        'Generation' {
            $bodyObj = @{
                taskType          = 'TEXT_IMAGE'
                textToImageParams = @{
                    text = $ImagePrompt
                }
            }
            if ($NegativeText) {
                $bodyObj.textToImageParams.Add('negativeText', $NegativeText)
            }
        } #generation
        'InPaint' {
            # validate that either $InPaintMaskPrompt or $InPaintMaskImagePath is provided
            if (-not ($InPaintMaskPrompt -or $InPaintMaskImagePath)) {
                throw 'Either -InPaintMaskPrompt or -InPaintMaskImagePath is required.'
            }
            # validate that both $InPaintMaskPrompt and $InPaintMaskImagePath are not provided
            if ($InPaintMaskPrompt -and $InPaintMaskImagePath) {
                throw 'Either -InPaintMaskPrompt or -InPaintMaskImagePath should be provided. Not both.'
            }

            Write-Debug -Message 'Validating primary INPAINTING image.'
            $mediaEval = Test-AmazonMedia -MediaPath $InPaintImagePath
            if ($mediaEval -ne $true) {
                throw 'Media file not supported.'
            }
            else {
                Write-Debug -Message 'Primary INPAINTING image is supported.'
            }

            Write-Debug -Message 'Converting primary INPAINTING image to base64.'
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $InPaintImagePath -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }

            $bodyObj = @{
                taskType         = 'INPAINTING'
                inPaintingParams = @{
                    image = $base64
                }
            }
            if ($InPaintTextPrompt) {
                $bodyObj.inPaintingParams.Add('text', $InPaintTextPrompt)
            }
            if ($InPaintMaskPrompt) {
                $bodyObj.inPaintingParams.Add('maskPrompt', $InPaintMaskPrompt)
            }
            if ($InPaintMaskImagePath) {
                Write-Debug -Message 'Validating INPAINTING mask image.'
                $mediaMaskEval = Test-AmazonMedia -MediaPath $InPaintMaskImagePath
                if ($mediaMaskEval -ne $true) {
                    throw 'Media file not supported.'
                }
                else {
                    Write-Debug -Message 'Mask image is supported.'
                }

                Write-Debug -Message 'Converting INPAINTING mask image to base64.'
                try {
                    $base64Mask = Convert-MediaToBase64 -MediaPath $InPaintMaskImagePath -ErrorAction Stop
                }
                catch {
                    Write-Error $_
                    throw
                }
                $bodyObj.inPaintingParams.Add('maskImage', $base64Mask)
            }
            if ($NegativeText) {
                $bodyObj.inPaintingParams.Add('negativeText', $NegativeText)
            }
        } #inPaint
        'OutPaint' {
            # validate that either $OutPaintMaskPrompt or $OutPaintMaskImagePath is provided
            if (-not ($OutPaintMaskPrompt -or $OutPaintMaskImagePath)) {
                throw 'Either -OutPaintMaskPrompt or -OutPaintMaskImagePath is required.'
            }
            # validate that both $OutPaintMaskPrompt and $OutPaintMaskImagePath are not provided
            if ($OutPaintMaskPrompt -and $OutPaintMaskImagePath) {
                throw 'Either -OutPaintMaskPrompt or -OutPaintMaskImagePath should be provided. Not both.'
            }

            Write-Debug -Message 'Validating primary OUTPAINTING image.'
            $mediaEval = Test-AmazonMedia -MediaPath $OutPaintImagePath
            if ($mediaEval -ne $true) {
                throw 'Media file not supported.'
            }
            else {
                Write-Debug -Message 'Primary OUTPAINTING image is supported.'
            }

            Write-Debug -Message 'Converting primary OUTPAINTING image to base64.'
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $OutPaintImagePath -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }

            $bodyObj = @{
                taskType          = 'OUTPAINTING'
                outPaintingParams = @{
                    image           = $base64
                    outPaintingMode = $OutPaintMode
                }
            }
            if ($OutPaintTextPrompt) {
                $bodyObj.outPaintingParams.Add('text', $OutPaintTextPrompt)
            }
            if ($OutPaintMaskPrompt) {
                $bodyObj.outPaintingParams.Add('maskPrompt', $OutPaintMaskPrompt)
            }
            if ($OutPaintMaskImagePath) {
                Write-Debug -Message 'Validating OUTPAINTING mask image.'
                $mediaMaskEval = Test-AmazonMedia -MediaPath $OutPaintMaskImagePath
                if ($mediaMaskEval -ne $true) {
                    throw 'Media file not supported.'
                }
                else {
                    Write-Debug -Message 'OUTPAINTING mask image is supported.'
                }

                Write-Debug -Message 'Converting OUTPAINTING mask image to base64.'
                try {
                    $base64Mask = Convert-MediaToBase64 -MediaPath $OutPaintMaskImagePath -ErrorAction Stop
                }
                catch {
                    Write-Error $_
                    throw
                }
                $bodyObj.outPaintingParams.Add('maskImage', $base64Mask)
            }
            if ($NegativeText) {
                $bodyObj.outPaintingParams.Add('negativeText', $NegativeText)
            }
        } #outPaint
        'Variation' {
            $bodyObj = @{
                taskType             = 'IMAGE_VARIATION'
                imageVariationParams = @{
                    # images             = @($base64)
                    images = New-Object System.Collections.Generic.List[string]
                }
            }

            foreach ($imagePath in $VariationImagePath) {
                #-------------------------
                # resets
                $mediaEval = $false
                $base64 = $null
                #-------------------------
                $mediaEval = Test-AmazonMedia -MediaPath $imagePath
                if (-not $mediaEval) {
                    throw 'Media file not supported.'
                }
                try {
                    $base64 = Convert-MediaToBase64 -MediaPath $imagePath -ErrorAction Stop
                }
                catch {
                    Write-Error $_
                    throw
                }
                $bodyObj.imageVariationParams.images.Add($base64)
            }

            if ($VariationTextPrompt) {
                $bodyObj.imageVariationParams.Add('text', $VariationTextPrompt)
            }
            if ($SimilarityStrength) {
                $bodyObj.imageVariationParams.Add('similarityStrength', $SimilarityStrength)
            }
            if ($NegativeText) {
                $bodyObj.imageVariationParams.Add('negativeText', $NegativeText)
            }
        } #variation
        'Condition' {
            if ($ModelID -ne 'amazon.titan-image-generator-v2:0' -and $ModelID -ne 'amazon.nova-canvas-v1:0') {
                throw 'Conditioning can only be used with the Titan v2 or Nova model.'
            }

            Write-Debug -Message 'Validating primary CONDITIONING image.'
            $mediaEval = Test-AmazonMedia -MediaPath $ConditionImagePath
            if ($mediaEval -ne $true) {
                throw 'Media file not supported.'
            }
            else {
                Write-Debug -Message 'Primary CONDITIONING image is supported.'
            }

            $bodyObj = @{
                taskType          = 'TEXT_IMAGE'
                textToImageParams = @{
                    text = $ConditionTextPrompt
                }
            }
            if ($NegativeText) {
                $bodyObj.textToImageParams.Add('negativeText', $NegativeText)
            }

            Write-Debug -Message 'Converting primary CONDITIONING image to base64.'
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $ConditionImagePath -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }

            $bodyObj.textToImageParams.Add('conditionImage', $base64)
            if ($ControlMode) {
                $bodyObj.textToImageParams.Add('controlMode', $ControlMode)
            }
            if ($ControlStrength) {
                $bodyObj.textToImageParams.Add('controlStrength', $ControlStrength)
            }
        } #condition
        'ColorGuided' {
            if ($ModelID -ne 'amazon.titan-image-generator-v2:0' -and $ModelID -ne 'amazon.nova-canvas-v1:0') {
                throw 'ColorGuided can only be used with the Titan v2 or Nova model.'
            }

            Write-Debug -Message 'Validating primary COLORGUIDED image.'
            $mediaEval = Test-AmazonMedia -MediaPath $ColorGuidedImagePath
            if ($mediaEval -ne $true) {
                throw 'Media file not supported.'
            }
            else {
                Write-Debug -Message 'Primary COLORGUIDED image is supported.'
            }

            $bodyObj = @{
                taskType                    = 'COLOR_GUIDED_GENERATION'
                colorGuidedGenerationParams = @{
                    text = $ColorGuidedTextPrompt
                }
            }
            if ($NegativeText) {
                $bodyObj.colorGuidedGenerationParams.Add('negativeText', $NegativeText)
            }

            Write-Debug -Message 'Converting primary COLORGUIDED image to base64.'
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $ColorGuidedImagePath -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }

            $bodyObj.colorGuidedGenerationParams.Add('referenceImage', $base64)

            $colorsEval = Test-ColorHex -Colors $Colors
            if ($colorsEval -ne $true) {
                throw 'Colors are not valid.'
            }
            else {
                $bodyObj.colorGuidedGenerationParams.Add('colors', $Colors)
            }

        } #colorGuided
        'BackgroundRemoval' {

            if ($ModelID -ne 'amazon.titan-image-generator-v2:0' -and $ModelID -ne 'amazon.nova-canvas-v1:0') {
                throw 'BackgroundRemoval can only be used with the Titan v2 or Nova model.'
            }

            Write-Debug -Message 'Validating primary BACKGROUND REMOVAL image.'
            $mediaEval = Test-AmazonMedia -MediaPath $BackgroundRemovalImagePath
            if ($mediaEval -ne $true) {
                throw 'Media file not supported.'
            }
            else {
                Write-Debug -Message 'Primary BACKGROUND REMOVAL image is supported.'
            }

            Write-Debug -Message 'Converting primary BACKGROUND REMOVAL image to base64.'
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $BackgroundRemovalImagePath -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }

            $bodyObj = @{
                taskType                = 'BACKGROUND_REMOVAL'
                backgroundRemovalParams = @{
                    image = $base64
                }
            }

        } #backgroundRemoval
    } #switch_parameterSetName

    #region common image parameters

    if ($NumberOfImages -or $Width -or $Height -or $CfgScale) {
        $bodyObj.Add('imageGenerationConfig', @{})
    }
    if ($NumberOfImages) {
        $bodyObj.imageGenerationConfig.Add('numberOfImages', $NumberOfImages)
    }
    if ($Width) {
        $bodyObj.imageGenerationConfig.Add('width', $Width)
    }
    if ($Height) {
        $bodyObj.imageGenerationConfig.Add('height', $Height)
    }
    if ($CfgScale) {
        $bodyObj.imageGenerationConfig.Add('cfgScale', $CfgScale)
    }
    if ($PSCmdlet.ParameterSetName -eq 'Generation') {
        if ($Seed) {
            $bodyObj.imageGenerationConfig.Add('seed', $Seed)
        }
    }
    $jsonBody = $bodyObj | ConvertTo-Json -Depth 10
    [byte[]]$byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

    $inferenceModelID = Format-InferenceProfileID -ModelID $ModelID -Region $Region

    $cmdletParams = @{
        ContentType = 'application/json'
        ModelId     = $inferenceModelID
        Body        = $byteArray
    }

    Write-Debug -Message 'Cmdlet Params:'
    Write-Debug -Message ($cmdletParams | Out-String)

    Write-Debug -Message 'Body JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    #endregion

    #region commonParams

    $commonParams = @{}

    if ($AccessKey) {
        $commonParams.Add('AccessKey', $AccessKey)
    }
    if ($Credential) {
        $commonParams.Add('Credential', $Credential)
    }
    if ($EndpointUrl) {
        $commonParams.Add('EndpointUrl', $EndpointUrl)
    }
    if ($NetworkCredential) {
        $commonParams.Add('NetworkCredential', $NetworkCredential)
    }
    if ($ProfileLocation) {
        $commonParams.Add('ProfileLocation', $ProfileLocation)
    }
    if ($ProfileName) {
        $commonParams.Add('ProfileName', $ProfileName)
    }
    if ($Region) {
        $commonParams.Add('Region', $Region)
    }
    if ($SecretKey) {
        $commonParams.Add('SecretKey', $SecretKey)
    }
    if ($SessionToken) {
        $commonParams.Add('SessionToken', $SessionToken)
    }

    #endregion

    try {
        $rawResponse = Invoke-BDRRModel @cmdletParams @commonParams -ErrorAction Stop
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        if ($exceptionMessage -like "*don't have access*") {
            Write-Debug -Message 'Specific Error'
            Write-Warning -Message 'You do not have access to the requested model.'
            Write-Warning -Message 'In your AWS account, you will need to request access to the model.'
            Write-Warning -Message 'AWS -> Amazon Bedrock -> Model Access -> Request Access'
            throw ('No access to model {0}.' -f $ModelID)
        }
        elseif ($exceptionMessage -like '*content filters*') {
            Write-Debug -Message 'Specific Error'
            Write-Warning -Message 'Your request was blocked by the Amazon Titan content filters.'
            throw $exceptionMessage
        }
        else {
            Write-Debug -Message 'General Error'
            Write-Debug -Message ($_ | Out-String)
            Write-Error -Message $_
            Write-Error -Message $_.Exception.Message
            throw
        }
    }

    if ([String]::IsNullOrWhiteSpace($rawResponse)) {
        throw 'No response from model API.'
    }

    Write-Verbose -Message'Processing response.'
    try {
        $jsonBody = ConvertFrom-MemoryStreamToString -MemoryStream $rawResponse.body -ErrorAction Stop
    }
    catch {
        Write-Error $_
        throw
    }

    Write-Debug -Message 'Response JSON:'
    Write-Debug -Message ($jsonBody | Out-String)

    Write-Verbose -Message 'Converting response from JSON.'
    $response = $jsonBody | ConvertFrom-Json

    if ([string]::IsNullOrWhiteSpace($response.images)) {
        Write-Warning -Message 'No images were returned from the model.'
    }
    else {
        $imageCount = $response.images.Count
        Write-Verbose -Message ('Processing {0} images returned from model.' -f $imageCount)

        Write-Verbose -Message 'Calculating cost estimate.'
        Add-ModelCostEstimate -ImageCount $imageCount -ModelID $ModelID

        foreach ($image in $response.images) {
            Write-Verbose -Message ('....Processing image {0}.' -f $imageCount)
            try {
                $imageBytes = Convert-FromBase64ToByte -Base64String $image -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }
            $imageFileName = '{0}-{1}.png' -f ($ModelID -replace ':',''), (Get-Date -Format 'yyyyMMdd-HHmmss')
            $imageFilePath = [System.IO.Path]::Combine($ImagesSavePath, $imageFileName)
            Write-Verbose -Message ('Saving image to {0}.' -f $imageFilePath)
            try {
                Save-BytesToFile -ImageBytes $imageBytes -FilePath $imageFilePath -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }

            Start-Sleep -Milliseconds 5500 #for naming uniqueness
            $imageCount--
        } #foreach_image
    }

    if ($ReturnFullObject) {
        return $response
    }

} #Invoke-AmazonImageModel
