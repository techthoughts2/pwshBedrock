<#
.SYNOPSIS
    Tests if a hex color value is valid.
.DESCRIPTION
    Validates an array of hex color values to ensure they are in the correct format.
    The function checks if the hex color values are in the correct format and if the count of colors is less than or equal to 10.
.EXAMPLE
    Test-ColorHex -Colors '#FF0000', '#00FF00', '#0000FF'

    Tests the hex color values '#FF0000', '#00FF00', and '#0000FF' for validity.
.PARAMETER Colors
    An array of hex color values to validate.
.OUTPUTS
    System.Boolean
.COMPONENT
    pwshBedrock
#>
function Test-ColorHex {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'An array of hex color values to validate.')]
        [string[]]$Colors
    )

    Write-Verbose -Message 'Validating color hex values...'

    Write-Debug -Message 'Validating hex count...'
    if ($Colors.Count -gt 10) {
        Write-Debug -Message ('{0} colors provided. Maximum of 10 colors allowed.' -f $Colors.Count)
        return $false
    }

    Write-Debug -Message 'Validating hex format...'
    foreach ($color in $Colors) {
        # Check if the color is a valid hex color
        if ($color -notmatch "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$") {
            Write-Debug -Message ('Invalid hex color format: {0}' -f $color)
            return $false
        }
    }

    return $true
}
