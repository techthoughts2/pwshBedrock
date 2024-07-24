<#
.SYNOPSIS
    Retrieves the resolution of an image.
.DESCRIPTION
    This function returns the resolution (width and height) of an image using the System.Drawing namespace.
    It reads the specified image file and outputs its dimensions.
.EXAMPLE
    Get-ImageResolution -MediaPath 'C:\path\to\image.jpg'

    Gets the resolution of the image located at 'C:\path\to\image.jpg'.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    This function is a wrapper around the System.Drawing namespace, which is not mockable in tests.
.COMPONENT
    pwshBedrock
#>
function Get-ImageResolution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to local media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath
    )

    Write-Verbose -Message ('Getting resolution for {0} ...' -f $MediaPath)
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($MediaPath)
    # Get the width and height
    $width = $image.Width
    $height = $image.Height
    $obj = [PSCustomObject]@{
        Width  = $width
        Height = $height
    }
    Write-Debug -Message ('Width: {0}, Height: {1}' -f $width, $height)
    return $obj
} #Get-ImageResolution
