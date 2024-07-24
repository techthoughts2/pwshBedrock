<#
.SYNOPSIS
    Converts a base64 string to bytes.
.DESCRIPTION
    This function converts a base64 string to bytes using the System.IO.File namespace.
    It reads the base64 string and converts it to bytes.
.EXAMPLE
    Convert-FromBase64ToByte -Base64String $base64

    Converts the base64 string to bytes.
.PARAMETER Base64String
    Base64 string to convert to a media file.
.OUTPUTS
    System.Byte
.NOTES
    This function is a wrapper around the System.IO.File namespace, which is not mockable in tests.
.COMPONENT
    pwshBedrock
#>
function Convert-FromBase64ToByte {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Base64 string to convert to a media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Base64String
    )

    Write-Verbose -Message 'Converting from base64'
    try {
        $bytes = [Convert]::FromBase64String($Base64String)
    }
    catch {
        Write-Warning -Message 'Failed to convert from base64'
        throw
    }
    return $bytes
} #Convert-FromBase64ToByte
