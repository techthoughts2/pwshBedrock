<#
.SYNOPSIS
    Sends message(s) to an Stability AI Image Core model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local folder.
.DESCRIPTION
    Sends a message to an Stability AI Image Core model on the Amazon Bedrock platform and returns the model's response.
    The response from this model is an image or images generated based on the input parameters.
    The generated image(s) are decoded from base64 and saved to a local folder.
    This function supports the following Stability AI Image Core image use cases:
        Text-to-image - Generation - Generate an image using a text prompt.
.EXAMPLE
    Invoke-StabilityAIImageModel -ImagesSavePath 'C:\images' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-image-core-v1:0' -Credential $awsCredential -Region 'us-west-2'

    Generates an image and saves the image to the C:\images folder.
.EXAMPLE
    Invoke-StabilityAIImageModel -ImagesSavePath 'C:\images' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-image-ultra-v1:0' -Credential $awsCredential -Region 'us-west-2' -ReturnFullObject

    Generates an image and saves the image to the C:\images folder. Returns the full object from the model.
.EXAMPLE
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

    This command generates an image based on the provided prompt and saves the image to the specified folder ('C:\images\image.png').
    This image will have a 1:1 aspect ratio and be in JPEG format.
    The seed is set to 1234, and the model is told to avoid the concept of stars.
.EXAMPLE
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

    This command generates an image based on the provided prompt and initial image and saves the image to the specified folder ('C:\images\image.png').
    The image strength is set to 0.5.
    The provided init image is used as a starting point for the generation.
.PARAMETER ImagesSavePath
    The local file path to save the generated images.
.PARAMETER ImagePrompt
    A text prompt used to generate the image.
.PARAMETER InitImagePath
    File path to image to use as the starting point for the generation.
.PARAMETER ImageStrength
    Sometimes referred to as denoising, this parameter controls how much influence the image parameter has on the generated image. A value of 0 would yield an image that is identical to the input. A value of 1 would be as if you passed in no image at all.
.PARAMETER AspectRatio
    Controls the aspect ratio of the generated image. Only valid for text-to-image requests.
.PARAMETER OutputFormat
    Specifies the format of the output image.
.PARAMETER Seed
    The seed determines the initial noise setting. Use the same seed and the same settings as a previous run to allow inference to create a similar image. If you don't set this value, or the value is 0, it is set as a random number.
    If a seed is provided, the resulting generated image will be deterministic.
    What this means is that as long as all generation parameters remain the same, you can always recall the same image simply by generating it again.
.PARAMETER NegativePrompt
    Use a negative prompt to tell the model to avoid certain concepts.
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
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-StabilityAIImageModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-diffusion-stable-image-core-text-image-request-response.html
.LINK
    https://platform.stability.ai/docs/api-reference#tag/Generate/paths/~1v2beta~1stable-image~1generate~1core/post
#>
function Invoke-StabilityAIImageModel {
    [CmdletBinding()]
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
            HelpMessage = 'A text prompt used to generate the image.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePrompt,

        #_______________________________________________________
        # image-to-image parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to image to use as the starting point for the generation.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$InitImagePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Sometimes referred to as denoising, this parameter controls how much influence the image parameter has on the generated image. A value of 0 would yield an image that is identical to the input. A value of 1 would be as if you passed in no image at all')]
        [ValidateRange(0, 1.0)]
        [float]$ImageStrength,
        #_______________________________________________________

        [Parameter(Mandatory = $false,
            HelpMessage = 'Controls the aspect ratio of the generated image. Only valid for text-to-image requests.')]
        [ValidateSet(
            '16:9',
            '1:1',
            '21:9',
            '2:3',
            '3:2',
            '4:5',
            '5:4',
            '9:16',
            '9:21'
        )]
        [string]$AspectRatio = '1:1',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Specifies the format of the output image.')]
        [ValidateSet(
            'jpeg',
            'png'
        )]
        [string]$OutputFormat = 'png',

        [Parameter(Mandatory = $false,
            HelpMessage = "The seed determines the initial noise setting. Use the same seed and the same settings as a previous run to allow inference to create a similar image. If you don't set this value, or the value is 0, it is set as a random number.")]
        [ValidateRange(0, 4294967295)]
        [int]$Seed,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Use a negative prompt to tell the model to avoid certain concepts.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$NegativePrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'stability.stable-image-core-v1:0',
            'stability.stable-image-ultra-v1:0',
            'stability.sd3-large-v1:0'
        )]
        [string]$ModelID = 'stability.stable-image-core-v1:0',

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

    $bodyObj = @{
        prompt = $ImagePrompt
    }

    #region image-to-image parameters

    if ($InitImagePath -and $ModelID -ne 'stability.sd3-large-v1:0') {
        Write-Warning -Message 'Only stability.sd3-large-v1:0 supports image-to-image requests.'
        throw ('Model {0} does not support image-to-image requests.' -f $ModelID)
    }
    elseif ($InitImagePath -and $ModelID -eq 'stability.sd3-large-v1:0') {
        $bodyObj.Add('mode', 'image-to-image')

        Write-Debug -Message 'Validating InitImage'
        $mediaEval = Test-StabilityAIImageMedia -MediaPath $InitImagePath
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
        $bodyObj.Add('image', $base64)
        if ($ImageStrength) {
            $bodyObj.Add('strength', $ImageStrength)
        }
        else {
            $bodyObj.Add('strength', 0.1)
        }
    }
    else {
        $bodyObj.Add('mode', 'text-to-image')
    }

    #endregion

    #region common image parameters

    if (-not $InitImagePath) {
        $bodyObj.Add('aspect_ratio', $AspectRatio)
    }
    if ($OutputFormat) {
        $bodyObj.Add('output_format', $OutputFormat.ToLower())
    }
    if ($Seed) {
        $bodyObj.Add('seed', $Seed)
    }
    if ($NegativePrompt) {
        $bodyObj.Add('negative_prompt', $NegativePrompt)
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

    if (-not $response.PSObject.Properties.Match('images').Count -or
        $null -eq $response.images -or
        $response.images.Count -eq 0 -or
        [string]::IsNullOrWhiteSpace($response.images[0])) {
        Write-Warning -Message 'No images were returned from the model.'
    }
    else {
        if ($response.finish_reasons -like '*filter*') {
            Write-Warning -Message 'The content was filtered by the model.'
            Write-Warning -Message ('Filter Reason: {0}' -f $response.finish_reasons)
            Write-Warning -Message 'An image was still generated, but it may be blurred, blanked out, or in an undesired state.'
        }

        $imageCount = $artifactCount
        Write-Verbose -Message ('Processing {0} images returned from model.' -f $imageCount)

        Write-Verbose -Message 'Calculating cost estimate.'
        Add-ModelCostEstimate -ImageCount $imageCount -Steps $Steps -ModelID $ModelID

        foreach ($image in $response.images) {
            Write-Verbose -Message ('....Processing image {0}.' -f $imageCount)
            try {
                $imageBytes = Convert-FromBase64ToByte -Base64String $image -ErrorAction Stop
            }
            catch {
                Write-Error $_
                throw
            }
            $imageFileName = '{0}-{1}.{2}' -f ($ModelID -replace ':',''), (Get-Date -Format 'yyyyMMdd-HHmmss'), ($OutputFormat.ToLower())
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

} #Invoke-StabilityAIImageModel
