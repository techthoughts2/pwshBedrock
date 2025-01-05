<#
.SYNOPSIS
    Generates an inference profile ID from a model ID and a region.
.DESCRIPTION
    Depending on the region, a specific prefix is added to the start of the ModelID:
        - us-*  =>  us.
        - eu-*  =>  eu.
        - ap-*  =>  apac.
    Regions that do not match these patterns will produce no prefix.
.EXAMPLE
    Format-InferenceProfileID -ModelID "anthropic.claude-3-sonnet-20240229-v1:0" -Region "ap-northeast-1"

    apac.anthropic.claude-3-sonnet-20240229-v1:0
.EXAMPLE
    Format-InferenceProfileID -ModelID "meta.llama3-2-90b-instruct-v1:0" -Region "us-east-1"

    us.meta.llama3-2-90b-instruct-v1:0
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER Region
    The system name of an AWS region or an AWSRegion instance.
    The region name is used to generate the corresponding prefix.
.OUTPUTS
    System.String
.NOTES
    This function prefixes the region-based string onto the provided Model ID.
    For example, if Region = 'us-east-1', prefix will be 'us.',
    producing: us.meta.llama3-2-90b-instruct-v1:0
.COMPONENT
    pwshBedrock
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html
#>
function Format-InferenceProfileID {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system name of an AWS region or an AWSRegion instance.')]
        [object]$Region
    )

    Write-Verbose -Message 'Determining if Inference profile ID is required...'

    $modelInfo = Get-ModelInfo -ModelID $ModelID

    if ($modelInfo.InferenceProfile -eq $true) {

        Write-Debug -Message 'Inference profile ID is required.'

        # Convert region object to string just in case it's an AWSRegion instance
        $regionString = $Region.ToString()

        # Determine prefix based on region pattern
        $prefix = switch -Wildcard ($regionString) {
            "us-*" {
                "us."
            }
            "eu-*" {
                "eu."
            }
            "ap-*" {
                "apac."
            }
        }

        Write-Debug -Message ('Region: {0}, Prefix: {1}' -f $regionString, $prefix)

        # Construct the inference profile ID
        $inferenceProfileID = ($prefix + $ModelID)

        Write-Debug -Message ('Inference Profile ID: {0}' -f $inferenceProfileID)

    } #if_InferenceProfile
    else {
        Write-Debug -Message 'Inference profile ID is not required.'
        $inferenceProfileID = $ModelID
    } #else_InferenceProfile

    return $inferenceProfileID

} #Format-InferenceProfileID
