<#
.SYNOPSIS
    Tests if a media file is compatible with Stability AI Diffusion model requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Stability AI Diffusion model compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false.
    If the file resolution does not meet Stability AI Diffusion model requirements, the function returns false.
.EXAMPLE
    Test-StabilityAIDiffusionMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Stability AI Diffusion model compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    Supported image types - PNG
    The value must be one of 1024x1024, 1152x896, 1216x832, 1344x768, 1536x640, 640x1536, 768x1344, 832x1216, 896x1152
    Height
    Measured in pixels. Pixel limit is 1048576, so technically any dimension is allowable within that amount.
    Width
    Measured in pixels. Pixel limit is 1048576, so technically any dimension is allowable within that amount.
    A minimum of 262k pixels and a maximum of 1.04m pixels are recommended when generating images with 512px models, and a minimum of 589k pixels and a maximum of 1.04m pixels for 768px models. The true pixel limit is 1048576.

    To avoid the dreaded 6N IndexError it is advised to use 64px increments when choosing an aspect ratio. Popular ratio combinations for 512px models include 1536 x 512 and 1536 x 384, while 1536 x 640 and 1024 x 576 are recommended for 768px models.

    For 512px models, the minimum useful sizes are 192-256 in one dimension. For 768px models the minimum useful size is 384 in one dimension.

    Generating images under the recommended dimensions may result in undesirable artifacts.
.COMPONENT
    pwshBedrock
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/api-parameters#about-dimensions
#>
function Test-StabilityAIDiffusionMedia {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '',
        Justification = 'Just a collective noun.')]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath
    )

    $result = $true # Assume success

    Write-Verbose -Message 'Verifying presence of media...'
    try {
        $pathEval = Test-Path -Path $MediaPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying media path: {0}' -f $MediaPath)
        Write-Error $_
        $result = $false
        return $result
    }
    if ($pathEval -ne $true) {
        Write-Warning -Message ('The specified media path: {0} was not found.' -f $PhotoPath)
        $result = $false
        return $result
    } #if_testPath
    else {
        Write-Verbose -Message 'Path verified.'
    } #else_testPath

    Write-Verbose -Message 'Verifying media type...'
    $supportedMediaExtensions = @(
        'PNG'
    )
    Write-Verbose -Message ('Splitting media path: {0}' -f $MediaPath)
    $divide = $MediaPath.Split('.')
    $rawExtension = $divide[$divide.Length - 1]
    $extension = $rawExtension.ToUpper()
    Write-Verbose -Message "Verifying discovered extension: $extension"
    if ($supportedMediaExtensions -notcontains $extension) {
        Write-Warning -Message ('The specified media type: {0} is not supported.' -f $extension)
        $result = $false
        return $result
    } #if_supportedMediaExtensions
    else {
        Write-Verbose -Message 'Media type verified.'
    } #else_supportedMediaExtensions

    # Write-Verbose -Message 'Verifying media file size...'
    # try {
    #     $mediaFileInfo = Get-Item -Path $MediaPath -ErrorAction Stop
    # }
    # catch {
    #     Write-Error ('Error verifying media file info: {0}' -f $MediaPath)
    #     Write-Error $_
    #     $result = $false
    #     return $result
    # }

    # $mediaSize = $mediaFileInfo.Length
    # if ($mediaSize -gt 5MB) {
    #     Write-Warning -Message ('The specified media size: {0} exceeds the Amazon Titan maximum allowed image file size of 5MB.' -f $mediaSize)
    #     $result = $false
    #     return $result
    # } #if_mediaSize
    # else {
    #     Write-Verbose -Message 'Media size verified.'
    # } #else_mediaSize


    Write-Verbose -Message 'Verifying media resolution...'
    Write-Verbose ('Media path: {0}' -f $MediaPath)
    $resolution = Get-ImageResolution -MediaPath $MediaPath

    # check if the resolution is within the pixel limit
    if (($resolution.Width * $resolution.Height -gt 1048576) -or ($resolution.Width * $resolution.Height -lt 262144)) {
        Write-Warning -Message ('The specified media resolution: {0}x{1} exceeds the Stability AI Diffusion model allowed pixel limit of 1048576.' -f $resolution.Width, $resolution.Height)
        $result = $false
        return $result
    }

    # # Check if the resolution matches any of the supported resolutions
    # $matchFound = $false
    # foreach ($supportedResolution in $supportedResolutions) {
    #     if ($resolution.width -eq $supportedResolution.Width -and $resolution.height -eq $supportedResolution.Height) {
    #         $matchFound = $true
    #         break
    #     }
    # }

    # if ($matchFound -eq $false) {
    #     Write-Warning -Message ('The specified media resolution: {0}x{1} is not supported.' -f $resolution.Width, $resolution.Height)
    #     Write-Warning -Message 'https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html'
    #     $result = $false
    #     return $result
    # }

    return $result

} #Test-StabilityAIDiffusionMedia
