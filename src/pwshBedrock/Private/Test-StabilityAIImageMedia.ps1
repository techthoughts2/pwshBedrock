<#
.SYNOPSIS
    Tests if a media file is compatible with Stability AI Image model requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Stability AI Image model compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false.
    If the file resolution does not meet Stability AI Image model requirements, the function returns false.
.EXAMPLE
    Test-StabilityAIImageMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Stability AI Image model compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    Supported image types - JPEG, PNG, WEBP
    Width: 640 - 1536 px, Height: 640 - 1536 px
    Every side must be at least 64 pixels
.COMPONENT
    pwshBedrock
.LINK
    https://platform.stability.ai/docs/legacy/grpc-api/features/api-parameters#about-dimensions
#>
function Test-StabilityAIImageMedia {
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
        'JPEG',
        'PNG',
        'WEBP'
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
    if (($resolution.Width -lt 640) -or ($resolution.Width -gt 1536) -or ($resolution.Height -lt 640) -or ($resolution.Height -gt 1536)) {
        Write-Warning -Message ('The specified media resolution: {0}x{1} does not meet the Stability AI Image model required resolution of 640x640 to 1536x1536.' -f $resolution.Width, $resolution.Height)
        $result = $false
        return $result
    }

    return $result

} #Test-StabilityAIImageMedia