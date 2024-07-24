<#
.SYNOPSIS
    Tests if a media file is compatible with Amazon Titan's requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Amazon Titan's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false.
    If the file resolution does not meet Amazon Titan's strict requirements, the function returns false.
.EXAMPLE
    Test-AmazonMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Amazon Titan's compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    Max input image size - 5 MB (only some specific resolutions are supported)

    Max image size using in/outpainting - 1,408 x 1,408 px

    Width     Height     Aspect ratio     Price equivalent to
    1024      1024       1:1              1024 x 1024
    768       768        1:1              512 x 512
    512       512        1:1              512 x 512
    768       1152       2:3              1024 x 1024
    384       576        2:3              512 x 512
    1152      768        3:2              1024 x 1024
    576       384        3:2              512 x 512
    768       1280       3:5              1024 x 1024
    384       640        3:5              512 x 512
    1280      768        5:3              1024 x 1024
    640       384        5:3              512 x 512
    896       1152       7:9              1024 x 1024
    448       576        7:9              512 x 512
    1152      896        9:7              1024 x 1024
    576       448        9:7              512 x 512
    768       1408       6:11             1024 x 1024
    384       704        6:11             512 x 512
    1408      768        11:6             1024 x 1024
    704       384        11:6             512 x 512
    640       1408       5:11             1024 x 1024
    320       704        5:11             512 x 512
    1408      640        11:5             1024 x 1024
    704       320        11:5             512 x 512
    1152      640        9:5              1024 x 1024
    1173      640        16:9             1024 x 1024

    Supported image types - JPEG, JPG, PNG
    The maximum file size allowed is 5 MB.
.COMPONENT
    pwshBedrock
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html
#>
function Test-AmazonMedia {
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
        'JPG'
        'JPEG'
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

    Write-Verbose -Message 'Verifying media file size...'
    try {
        $mediaFileInfo = Get-Item -Path $MediaPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying media file info: {0}' -f $MediaPath)
        Write-Error $_
        $result = $false
        return $result
    }

    $mediaSize = $mediaFileInfo.Length
    if ($mediaSize -gt 5MB) {
        Write-Warning -Message ('The specified media size: {0} exceeds the Amazon Titan maximum allowed image file size of 5MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Media size verified.'
    } #else_mediaSize

    #---------------------------------------------------------------
    # Define the list of supported width and height combinations
    # https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html
    $supportedResolutions = @(
        @{ Width = 1024; Height = 1024 }
        @{ Width = 768; Height = 768 }
        @{ Width = 512; Height = 512 }
        @{ Width = 768; Height = 1152 }
        @{ Width = 384; Height = 576 }
        @{ Width = 1152; Height = 768 }
        @{ Width = 576; Height = 384 }
        @{ Width = 768; Height = 1280 }
        @{ Width = 384; Height = 640 }
        @{ Width = 1280; Height = 768 }
        @{ Width = 640; Height = 384 }
        @{ Width = 896; Height = 1152 }
        @{ Width = 448; Height = 576 }
        @{ Width = 1152; Height = 896 }
        @{ Width = 576; Height = 448 }
        @{ Width = 768; Height = 1408 }
        @{ Width = 384; Height = 704 }
        @{ Width = 1408; Height = 768 }
        @{ Width = 704; Height = 384 }
        @{ Width = 640; Height = 1408 }
        @{ Width = 320; Height = 704 }
        @{ Width = 1408; Height = 640 }
        @{ Width = 704; Height = 320 }
        @{ Width = 1152; Height = 640 }
        @{ Width = 1173; Height = 640 }
    )

    Write-Verbose -Message 'Verifying media resolution...'
    Write-Verbose ('Media path: {0}' -f $MediaPath)
    $resolution = Get-ImageResolution -MediaPath $MediaPath

    # Check if the resolution matches any of the supported resolutions
    $matchFound = $false
    foreach ($supportedResolution in $supportedResolutions) {
        if ($resolution.width -eq $supportedResolution.Width -and $resolution.height -eq $supportedResolution.Height) {
            $matchFound = $true
            break
        }
    }

    if ($matchFound -eq $false) {
        Write-Warning -Message ('The specified media resolution: {0}x{1} is not supported.' -f $resolution.Width, $resolution.Height)
        Write-Warning -Message 'https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html'
        $result = $false
        return $result
    }

    return $result

} #Test-AmazonMedia
