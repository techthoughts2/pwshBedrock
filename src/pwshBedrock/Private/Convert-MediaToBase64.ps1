<#
.SYNOPSIS
    Converts a media file to a base64 string.
.DESCRIPTION
    This function converts a specified media file to a base64 string using the System.IO.File namespace.
    It reads the file bytes and encodes them in base64 format.
.EXAMPLE
    Convert-MediaToBase64 -MediaPath 'C:\path\to\image.jpg'

    Converts the image located at 'C:\path\to\image.jpg' to a base64 string.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.String
.NOTES
    This function is a wrapper around the System.IO.File namespace, which is not mockable in tests.
.COMPONENT
    pwshBedrock
#>
function Convert-MediaToBase64 {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath
    )

    Write-Verbose -Message ('{0} Converting to base64' -f $MediaPath)
    try {
        $base64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($MediaPath))
    }
    catch {
        Write-Warning -Message ('Failed to convert {0} to base64' -f $MediaPath)
        throw
    }
    return $base64
} #Convert-MediaToBase64
