<#
.SYNOPSIS
    Sends message(s) to an Stability AI XL Diffusion model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local folder.
.DESCRIPTION
    Sends a message to an Stability AI XL Diffusion model on the Amazon Bedrock platform and returns the model's response.
    The response from this model is an image or images generated based on the input parameters.
    The generated image(s) are decoded from base64 and saved to a local folder.
    This function supports the following Stability AI XL Diffusion image use cases:
        Text-to-image - Generation - Generate an image using a text prompt.
        Image-to-image - modifying new images based on a starting point image.
        Image-to-image-masking - masking out a specific area of an image, and then generating new details based on a provided prompt.
    You can use ImagePrompt / NegativePrompt for providing quick string prompts, or CustomPrompt for more advanced prompt generation.
    Prompts supplied via ImagePrompt will always be given a weight of 1, while prompts supplied via NegativePrompt will always be given a weight of -1.
    If you wish to provide a custom prompt with a specific weight, use the CustomPrompt parameter.
.EXAMPLE
    Invoke-StabilityAIDiffusionXLModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2'

    Generates an image and saves the image to the C:\temp folder.
.EXAMPLE
    Invoke-StabilityAIDiffusionXLModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Make the nebula more purple' -InitImagePath 'C:\temp\nebula.png' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Generates an image based on the provided prompt and starting image. Returns the full object from the model.
.EXAMPLE
    $invokeStabilityAIDiffusionXLModelSplat = @{
        ImagesSavePath    = 'C:\temp'
        ImagePrompt       = 'Make it darker.'
        InitMaskImagePath = 'C:\temp\image.png'
        MaskSource        = 'MASK_IMAGE_WHITE'
        MaskImagePath     = 'C:\images\mask_image.png'
        ModelID           = 'stability.stable-diffusion-xl-v1'
        ProfileName       = 'default'
        Region            = 'us-west-2'
    }
    Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat

    This command uses the Stability AI XL Diffusion Model to generate an image based on the provided prompt and mask.
    Masking is a technique used to selectively apply changes to specific parts of an image.
    In this example, the mask image ('C:\images\mask_image.png') contains a white cut-out area that indicates the region to be edited.
    The model will use this white area to focus its modifications, leaving the rest of the image unchanged. The generated image will be saved in the specified folder ('C:\temp').
.EXAMPLE
    $invokeStabilityAIDiffusionXLModelSplat = @{
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
    Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat

    This command generates an image based on the provided prompt and saves the image to the specified folder ('C:\images\image.png').
    The image generation process is influenced by the CfgScale, ClipGuidancePreset, Sampler, Steps, and StylePreset parameters.
.EXAMPLE
    $invokeStabilityAIDiffusionXLModelSplat = @{
        ImagesSavePath = 'C:\temp'
        ImagePrompt    = 'Replace the captain with a different crew member.'
        InitImagePath  = 'C:\temp\image.png'
        InitImageMode  = 'IMAGE_STRENGTH'
        ImageStrength  = 1.0
        ModelID        = 'stability.stable-diffusion-xl-v1'
        ProfileName    = 'default'
        Region         = 'us-west-2'
    }
    Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat

    This command generates an image based on the provided prompt and starting image.
.EXAMPLE
    $invokeStabilityAIDiffusionXLModelSplat = @{
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
    Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat

    This command generates an image based on the provided custom prompt.
.PARAMETER ImagesSavePath
    The local file path to save the generated images.
.PARAMETER ImagePrompt
    A text prompt used to generate the image.
.PARAMETER NegativePrompt
    Use a negative prompt to tell the model to avoid certain concepts.
.PARAMETER CustomPrompt
    Provide a set of weighted custom prompts to guide the generation of the image.
    The custom prompt object should contain a text and weight property.
    The weight property is a number that determines the importance of the prompt.
    The higher the number, the more important the prompt.
.PARAMETER Width
    The width of the image in pixels.
    Only precise image sizes are supported. See the Stability AI XL Diffusion mode Parameters documentation for a list of supported image sizes.
.PARAMETER Height
    The height of the image in pixels.
    Only precise image sizes are supported. See the Stability AI XL Diffusion mode Parameters documentation for a list of supported image sizes.
.PARAMETER InitImagePath
    File path to image that you want to use to initialize the diffusion process.
.PARAMETER InitImageMode
    Determines whether to use image_strength or step_schedule_* to control how much influence the image in init_image has on the result.
.PARAMETER ImageStrength
    Determines how much influence the source image in init_image has on the diffusion process. Values close to 1 yield images very similar to the source image. Values close to 0 yield images very different than the source image.
.PARAMETER InitMaskImagePath
    File path to image that you want to use to initialize the mask diffusion process.
.PARAMETER MaskSource
    Determines where to source the mask from.
    MASK_IMAGE_WHITE – Use the white pixels of the mask image in mask_image as the mask. White pixels are replaced and black pixels are left unchanged.
    MASK_IMAGE_BLACK – Use the black pixels of the mask image in mask_image as the mask. Black pixels are replaced and white pixels are left unchanged.
    INIT_IMAGE_ALPHA – Use the alpha channel of the image in init_image as the mask, Fully transparent pixels are replaced and fully opaque pixels are left unchanged.
.PARAMETER MaskImagePath
    File path to image that you want to use as a mask for the source image in init_image. Must be the same dimensions as the source image.
.PARAMETER CfgScale
    Determines how much the final image portrays the prompt. Use a lower number to increase randomness in the generation.
.PARAMETER ClipGuidancePreset
    CLIP Guidance is a technique that uses the CLIP neural network to guide the generation of images to be more in-line with your included prompt, which often results in improved coherency.
.PARAMETER Sampler
    The sampler to use for the diffusion process. If this value is omitted, the model automatically selects an appropriate sampler for you.
    If CLIP guidance is used, the sampler must be an ancestral sampler.
.PARAMETER Samples
    The number of image to generate. Currently Amazon Bedrock supports generating one image. If you supply a value for samples, the value must be one.
.PARAMETER Seed
    The seed determines the initial noise setting. Use the same seed and the same settings as a previous run to allow inference to create a similar image. If you don't set this value, or the value is 0, it is set as a random number.
    If a seed is provided, the resulting generated image will be deterministic.
    What this means is that as long as all generation parameters remain the same, you can always recall the same image simply by generating it again.
.PARAMETER Steps
    Generation step determines how many times the image is sampled. More steps can result in a more accurate result.
.PARAMETER StylePreset
    A style preset that guides the image model towards a particular style. This list of style presets is subject to change.
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

    A minimum of 262k pixels and a maximum of 1.04m pixels are recommended when generating images with 512px models, and a minimum of 589k pixels and a maximum of 1.04m pixels for 768px models. The true pixel limit is 1048576.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIDiffusionXLModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-text-image.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-image-image.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-1-0-image-image-mask.html
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/text-to-image
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/image-to-image
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/inpainting
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/clip-guidance
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/api-parameters#about-dimensions
#>
function Invoke-StabilityAIDiffusionXLModel {
    [CmdletBinding(DefaultParameterSetName = 'SimplePromptTextToImage')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        #_______________________________________________________
        # required parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'The local file path to save the generated images.')]
        [ValidateScript({
                if (-Not ($_ | Test-Path -PathType Container)) {
                    throw 'The Path argument must be a folder. File paths are not allowed.'
                }
                if (-Not ($_ | Test-Path)) {
                    throw 'File or folder does not exist'
                }
                return $true
            })]
        $ImagesSavePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt used to generate the image.',
            ParameterSetName = 'SimplePrompt')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptTextToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptImageToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptImageToImageMask')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$ImagePrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a negative prompt to tell the model to avoid certain concepts.',
            ParameterSetName = 'SimplePrompt')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptTextToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptImageToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptImageToImageMask')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$NegativePrompt,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Provide a set of weighted custom prompts to guide the generation of the image.',
            ParameterSetName = 'CustomPrompt')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptTextToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptImageToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptImageToImageMask')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [object[]]$CustomPrompt,


        #_______________________________________________________
        # text-to-image parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The width of the image in pixels.',
            ParameterSetName = 'TextToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptTextToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'CustomPromptTextToImage')]
        [ValidateSet(
            1024,
            1152,
            1216,
            1344,
            1536,
            640,
            768,
            832,
            896
        )]
        [int]$Width = 1024,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The height of the image in pixels.',
            ParameterSetName = 'TextToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptTextToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'CustomPromptTextToImage')]
        [ValidateSet(
            1024,
            896,
            832,
            768,
            640,
            1536,
            1344,
            1216,
            1152
        )]
        [int]$Height = 1024,

        #_______________________________________________________
        # image-to-image parameters

        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to image that you want to use to initialize the diffusion process',
            ParameterSetName = 'ImageToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptImageToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptImageToImage')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$InitImagePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Determines whether to use image_strength or step_schedule_* to control how much influence the image in init_image has on the result.',
            ParameterSetName = 'ImageToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptImageToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'CustomPromptImageToImage')]
        [ValidateSet(
            'IMAGE_STRENGTH',
            'STEP_SCHEDULE'
        )]
        [string]$InitImageMode,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Determines how much influence the source image in init_image has on the diffusion process. Values close to 1 yield images very similar to the source image. Values close to 0 yield images very different than the source image.',
            ParameterSetName = 'ImageToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'SimplePromptImageToImage')]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'CustomPromptImageToImage')]
        [ValidateRange(0, 1.0)]
        [float]$ImageStrength,

        #_______________________________________________________
        # image-to-image-masking parameters

        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to image that you want to use to initialize the mask diffusion process',
            ParameterSetName = 'ImageToImage')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptImageToImageMask')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptImageToImageMask')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$InitMaskImagePath,

        [Parameter(Mandatory = $true,
            HelpMessage = ' Determines where to source the mask from.',
            ParameterSetName = 'ImageToImageMask')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptImageToImageMask')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptImageToImageMask')]
        [ValidateSet(
            'MASK_IMAGE_WHITE',
            'MASK_IMAGE_BLACK',
            'INIT_IMAGE_ALPHA'
        )]
        [string]$MaskSource,

        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to image that you want to use as a mask for the source image in init_image. Must be the same dimensions as the source image.',
            ParameterSetName = 'ImageToImageMask')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'SimplePromptImageToImageMask')]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'CustomPromptImageToImageMask')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MaskImagePath,

        #_______________________________________________________
        # common image parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'Determines how much the final image portrays the prompt. Use a lower number to increase randomness in the generation.')]
        [ValidateRange(0, 35)]
        [float]$CfgScale,

        [Parameter(Mandatory = $false,
            HelpMessage = 'CLIP Guidance is a technique that uses the CLIP neural network to guide the generation of images to be more in-line with your included prompt, which often results in improved coherency.')]
        [ValidateSet(
            'FAST_BLUE',
            'FAST_GREEN',
            'NONE',
            'SIMPLE SLOW',
            'SLOWER',
            'SLOWEST'
        )]
        [string]$ClipGuidancePreset,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The sampler to use for the diffusion process. If this value is omitted, the model automatically selects an appropriate sampler for you.')]
        [ValidateSet(
            'DDIM',
            'DDPM',
            'K_DPMPP_2M',
            'K_DPMPP_2S_ANCESTRAL',
            'K_DPM_2',
            'K_DPM_2_ANCESTRAL',
            'K_EULER',
            'K_EULER_ANCESTRAL',
            'K_HEUN K_LMS'
        )]
        [string]$Sampler,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The number of image to generate. Currently Amazon Bedrock supports generating one image. If you supply a value for samples, the value must be one.')]
        [ValidateRange(0, 1)]
        [int]$Samples,

        [Parameter(Mandatory = $false,
            HelpMessage = "The seed determines the initial noise setting. Use the same seed and the same settings as a previous run to allow inference to create a similar image. If you don't set this value, or the value is 0, it is set as a random number.")]
        [ValidateRange(0, 4294967295)]
        [int]$Seed,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Generation step determines how many times the image is sampled. More steps can result in a more accurate result.')]
        [ValidateRange(10, 50)]
        [int]$Steps,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A style preset that guides the image model towards a particular style. This list of style presets is subject to change.')]
        [ValidateSet(
            '3d-model',
            'analog-film',
            'anime',
            'cinematic',
            'comic-book',
            'digital-art',
            'enhance',
            'fantasy-art',
            'isometric',
            'line-art',
            'low-poly',
            'modeling-compound',
            'neon-punk',
            'origami',
            'photographic',
            'pixel-art',
            'tile-texture'
        )]
        [string]$StylePreset,

        #_______________________________________________________

        [Parameter(Mandatory = $false,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'stability.stable-diffusion-xl-v1'
        )]
        [string]$ModelID = 'stability.stable-diffusion-xl-v1',

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

    $modelInfo = $script:stabilityAIModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if ($ClipGuidancePreset -and $Sampler) {
        Write-Debug -Message 'Validating Sampler'
        if ($Sampler -notlike '*ANCESTRAL*') {
            throw 'CLIP Guidance only supports ancestral samplers.'

        }
    }

    if ($Width -or $Height) {
        # width and height must match one of the supported combinations
        $supportedSizes = @(
            '1024x1024',
            '1152x896',
            '1216x832',
            '1344x768',
            '1536x640',
            '640x1536',
            '768x1344',
            '832x1216',
            '896x1152'
        )
        $size = '{0}x{1}' -f $Width, $Height
        Write-Debug -Message ('Size Evaluation: {0}' -f $size)
        if ($size -notin $supportedSizes) {
            throw 'Width and Height must match one of the supported combinations.'
        }
    }

    $bodyObj = @{}
    if ($CustomPrompt) {
        Write-Debug -Message 'Adding CustomPrompt to body object.'
        $bodyObj.Add('text_prompts', @($CustomPrompt))
    }
    elseif ($ImagePrompt) {
        Write-Debug -Message 'Adding ImagePrompt to body object.'
        $bodyObj.Add('text_prompts', (New-Object System.Collections.Generic.List[object]))
        foreach ($prompt in $ImagePrompt) {
            $bodyObj.text_prompts.Add(@{
                    text   = $prompt
                    weight = 1
                })
        }
        foreach ($prompt in $NegativePrompt) {
            $bodyObj.text_prompts.Add(@{
                    text   = $prompt
                    weight = -1
                })
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'SimplePromptTextToImage' -or $PSCmdlet.ParameterSetName -eq 'CustomPromptTextToImage') {
        $bodyObj.Add('height', $Height)
        $bodyObj.Add('width', $Width)
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'SimplePromptImageToImage' -or $PSCmdlet.ParameterSetName -eq 'CustomPromptImageToImage') {
        Write-Debug -Message 'Validating InitImage'
        $mediaEval = Test-StabilityAIDiffusionMedia -MediaPath $InitImagePath
        if ($mediaEval -ne $true) {
            throw 'Media file not supported.'
        }
        else {
            Write-Debug -Message 'InitImage is supported.'
        }
        Write-Debug -Message 'Converting InitImage to base64.'
        try {
            $base64 = Convert-MediaToBase64 -MediaPath $InitImagePath -ErrorAction Stop
        }
        catch {
            Write-Error $_
            throw
        }
        $bodyObj.Add('init_image', $base64)
        if ($InitImageMode) {
            $bodyObj.Add('init_image_mode', $InitImageMode)
        }
        if ($ImageStrength) {
            $bodyObj.Add('image_strength', $ImageStrength)
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'SimplePromptImageToImageMask' -or $PSCmdlet.ParameterSetName -eq 'CustomPromptImageToImageMask') {
        Write-Debug -Message 'Validating Init MaskImage'
        $mediaEval = Test-StabilityAIDiffusionMedia -MediaPath $InitMaskImagePath
        if ($mediaEval -ne $true) {
            throw 'Media file not supported.'
        }
        else {
            Write-Debug -Message 'Init MaskImage is supported.'
        }
        Write-Debug -Message 'Converting Init MaskImage to base64.'
        try {
            $base64 = Convert-MediaToBase64 -MediaPath $InitMaskImagePath -ErrorAction Stop
        }
        catch {
            Write-Error $_
            throw
        }
        $bodyObj.Add('init_image', $base64)

        Write-Debug -Message 'Validating MaskImage'
        $mediaEval = Test-StabilityAIDiffusionMedia -MediaPath $MaskImagePath
        if ($mediaEval -ne $true) {
            throw 'Mask file not supported.'
        }
        else {
            Write-Debug -Message 'MaskImage is supported.'
        }
        Write-Debug -Message 'Converting MaskImage to base64.'
        try {
            $base64 = Convert-MediaToBase64 -MediaPath $MaskImagePath -ErrorAction Stop
        }
        catch {
            Write-Error $_
            throw
        }
        $bodyObj.Add('mask_image', $base64)
        $bodyObj.Add('mask_source', $MaskSource)
    }

    #region common image parameters

    if ($CfgScale) {
        $bodyObj.Add('cfg_scale', $CfgScale)
    }
    if ($ClipGuidancePreset) {
        $bodyObj.Add('clip_guidance_preset', $ClipGuidancePreset)
    }
    if ($Sampler) {
        $bodyObj.Add('sampler', $Sampler)
    }
    if ($Samples) {
        $bodyObj.Add('samples', $Samples)
    }
    if ($Seed) {
        $bodyObj.Add('seed', $Seed)
    }
    if ($Steps) {
        $bodyObj.Add('steps', $Steps)
    }
    if ($StylePreset) {
        $bodyObj.Add('style_preset', $StylePreset)
    }

    #endregion

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

    $artifactCount = ($response.artifacts | Measure-Object).Count
    Write-Debug -Message ('Artifacts Count: {0}' -f $artifactCount)
    if ($artifactCount -eq 0) {
        Write-Warning -Message 'No images were returned from the model.'
    }
    else {
        if ($response.artifacts.finishReason -eq 'CONTENT_FILTERED') {
            Write-Warning -Message 'The content was filtered by the model.'
            Write-Warning -Message 'An image was still generated, but it may be blurred, blanked out, or in an undesired state.'
        }

        $imageCount = $artifactCount
        Write-Verbose -Message ('Processing {0} images returned from model.' -f $imageCount)

        Write-Verbose -Message 'Calculating cost estimate.'
        Add-ModelCostEstimate -ImageCount $imageCount -Steps $Steps -ModelID $ModelID

        foreach ($image in $response.artifacts) {
            Write-Verbose -Message ('....Processing image {0}.' -f $imageCount)
            try {
                $imageBytes = Convert-FromBase64ToByte -Base64String $image.base64 -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }
            $imageFileName = '{0}-{1}.png' -f 'stability.stable-diffusion-xl-v1', (Get-Date -Format 'yyyyMMdd-HHmmss')
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

} #Invoke-StabilityAIDiffusionXLModel
