<#
.SYNOPSIS
    Sends messages to an Amazon Nova Reel model on the Amazon Bedrock platform to generate a video.
.DESCRIPTION
    Sends an asynchronous message to an Amazon Nova Reel model on the Amazon Bedrock platform to generate a video.
    The function supports text-to-video generation, text and image-to-video generation, and both short-form and long-form videos.
    Short videos are limited to 6 seconds, while long-form videos can be up to 2 minutes long (in 6-second increments).
    For long-form videos, either automated generation from a single prompt (MULTI_SHOT_AUTOMATED) or manual shot-by-shot generation (MULTI_SHOT_MANUAL) is supported.

    The response from this model is an invocation ARN, which can be used to check the status of the async job.
    The async job once completed will store the output video in the specified S3 bucket.
    The cmdlet will also attempt to download the video from S3 if the -AttemptS3Download switch is specified.
.EXAMPLE
    Invoke-AmazonVideoModel -VideoPrompt 'Closeup of a large seashell in the sand, gentle waves flow around the shell. Camera zoom in.' -S3OutputURI 's3://mybucket' -Credential $awsCredential -Region 'us-east-1'

    Generates a short 6-second video asynchronously using the Amazon Nova Reel model with the prompt and stores the output in the specified S3 bucket. Returns the invocation ARN.
.EXAMPLE
    $invokeAmazonVideoModelSplat = @{
        VideoPrompt       = 'Closeup of a large seashell in the sand, gentle waves flow around the shell. Camera zoom in.'
        S3OutputURI       = 's3://mybucket'
        AttemptS3Download = $true
        LocalSavePath     = 'C:\temp\videos'
        Credential        = $Credential
        Region            = 'us-east-1'
    }
    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

    Generates a short 6-second video and attempts to download the completed video from S3 to the specified local path.
.EXAMPLE
    $invokeAmazonVideoModelSplat = @{
        VideoPrompt       = 'Closeup of a large seashell in the sand, gentle waves flow around the shell. Camera zoom in.'
        MediaPath         = 'C:\Images\seashell.png'
        S3OutputURI       = 's3://mybucket'
        Credential        = $Credential
        Region            = 'us-east-1'
    }
    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

    Generates a short 6-second video using both text prompt and a reference image as the starting frame.
.EXAMPLE
    $invokeAmazonVideoModelSplat = @{
        VideoPrompt       = 'A man walks through a forest, observing the beauty of nature in various seasons.'
        DurationSeconds   = 24
        TaskType          = 'MULTI_SHOT_AUTOMATED'
        S3OutputURI       = 's3://mybucket'
        Credential        = $Credential
        Region            = 'us-east-1'
    }
    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

    Generates a 24-second long-form video (four 6-second shots) automatically from a single prompt.
.EXAMPLE
    $shotDetails = @(
        @{
            Text = "Shot 1: A man walks into a dense forest in spring, with new green leaves on trees."
        },
        @{
            Text = "Shot 2: The same forest, but in summer, with full, lush green trees and bright sunlight."
            ImagePath = "C:\Images\summer_forest.png"
        },
        @{
            Text = "Shot 3: The forest in autumn, with red and orange leaves falling gently."
        },
        @{
            Text = "Shot 4: The forest in winter, covered in snow, sun setting in the background."
        }
    )
    $invokeAmazonVideoModelSplat = @{
        TaskType          = 'MULTI_SHOT_MANUAL'
        Shots             = $shotDetails
        S3OutputURI       = 's3://mybucket'
        Credential        = $Credential
        Region            = 'us-east-1'
    }
    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

    Generates a 24-second long-form video (four 6-second shots) with manually defined shots, including an image reference for shot 2.
.PARAMETER VideoPrompt
    A text prompt used to generate the output video. For TEXT_VIDEO and MULTI_SHOT_AUTOMATED task types.
    For TEXT_VIDEO, must be 1-512 characters in length.
    For MULTI_SHOT_AUTOMATED, must be 1-4000 characters in length.
.PARAMETER MediaPath
    File path to local media image file to use as the starting frame of the video.
    The image must be in PNG or JPEG format with a resolution of 1280x720 pixels.
    Only valid for TEXT_VIDEO task type.
.PARAMETER S3OutputURI
    The MP4 file will be stored in the Amazon S3 bucket as configured in the response.
    Required parameter.
.PARAMETER TaskType
    The type of video generation task to perform.
    - TEXT_VIDEO: Generate a short 6-second video from text, with optional reference image
    - MULTI_SHOT_AUTOMATED: Generate a long-form video (12-120 seconds) from a single text prompt
    - MULTI_SHOT_MANUAL: Generate a long-form video with manually defined shots
    Default is TEXT_VIDEO.
.PARAMETER DurationSeconds
    The duration of the output video in seconds.
    For TEXT_VIDEO, must be 6 (the only supported value).
    For MULTI_SHOT_AUTOMATED, must be a multiple of 6 between 12 and 120, inclusive.
    For MULTI_SHOT_MANUAL, the duration is determined by the number of shots (6 seconds per shot).
.PARAMETER Shots
    An array of shot details for MULTI_SHOT_MANUAL task type.
    Each shot should be a hashtable with Text key (required) and optional ImagePath key.
.PARAMETER Seed
    Determines the initial noise setting for the generation process.
    The seed value must be between 0-2,147,483,646.
    Default is 42.
.PARAMETER ModelID
    The unique identifier of the model.
    Default is 'amazon.nova-reel-v1:1'.
.PARAMETER AttemptS3Download
    Attempt to download the completed video from S3.
.PARAMETER LocalSavePath
    Local path to save the downloaded MP4 file.
    This parameter is required if the -AttemptS3Download switch is specified.
.PARAMETER S3OutputBucketOwner
    If the bucket belongs to another AWS account, specify that account's ID.
.PARAMETER S3OutputKmsKeyId
    A KMS encryption key ID.
.PARAMETER JobCheckInterval
    The interval in seconds between job status checks when waiting for video generation to complete.
    Default is 30 seconds.
.PARAMETER JobTimeout
    The maximum time in minutes to wait for the video generation job to complete.
    Default is 30 minutes, which should be sufficient for most Nova Reel video generation jobs.
.PARAMETER AccessKey
    The AWS access key for the user account. This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.
.PARAMETER Credential
    An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.
.PARAMETER EndpointUrl
    The endpoint to make the call against.
    Note: This parameter is primarily for internal AWS use and is not required/should not be specified for normal usage.
.PARAMETER NetworkCredential
    Used with SAML-based authentication when ProfileName references a SAML role profile.
.PARAMETER ProfileLocation
    Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs).
.PARAMETER ProfileName
    The user-defined name of an AWS credentials or SAML-based role profile containing credential information.
.PARAMETER Region
    The system name of an AWS region or an AWSRegion instance.
.PARAMETER SecretKey
    The AWS secret key for the user account.
.PARAMETER SessionToken
    The session token if the access and secret keys are temporary session-based credentials.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    By default, this function will only return the invocation ARN of the async job.
    If you want to download the video from S3, you must specify the -AttemptS3Download switch and provide a valid -LocalSavePath.

    Amazon Nova Reel video generation is an asynchronous process that typically takes about 90 seconds for a 6-second video
    and approximately 14-17 minutes for a 2-minute video.

    When video generation completes, the video and its constituent shots are stored in the Amazon S3 bucket you specified.
    Amazon Nova creates a folder for each invocation ID containing manifest.json, output.mp4, and generation-status.json files.

    For MULTI_SHOT_MANUAL task type, each shot is 6 seconds long, so the total duration is 6 × number of shots.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/Invoke-AmazonVideoModel/
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/video-generation.html
.LINK
    https://docs.aws.amazon.com/nova/latest/userguide/video-gen-access.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-runtime_example_bedrock-runtime_Scenario_AmazonNova_TextToVideo_section.html
#>
function Invoke-AmazonVideoModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        # Required parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'A text prompt used to generate the output video.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$VideoPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media image file to use as the starting frame of the video.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The MP4 file will be stored in the Amazon S3 bucket as configured in the response.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^s3://[a-z0-9][-a-z0-9.]*[a-z0-9](/.*)?$')]
        [string]$S3OutputURI,

        # Task Type parameters
        [Parameter(Mandatory = $false,
            HelpMessage = 'The type of video generation task to perform.')]
        [ValidateSet(
            'TEXT_VIDEO',
            'MULTI_SHOT_AUTOMATED',
            'MULTI_SHOT_MANUAL'
        )]
        [string]$TaskType = 'TEXT_VIDEO',

        [Parameter(Mandatory = $false,
            HelpMessage = 'The duration of the output video in seconds.')]
        [int]$DurationSeconds = 6,

        [Parameter(Mandatory = $false,
            HelpMessage = 'An array of shot details for MULTI_SHOT_MANUAL task type.')]
        [ValidateNotNull()]
        [ValidateCount(2, 20)]  # Allow 2-20 shots (12-120 seconds)
        [System.Collections.Hashtable[]]$Shots,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Determines the initial noise setting for the generation process.')]
        [ValidateRange(0, 2147483646)]
        [int]$Seed = 42,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'amazon.nova-reel-v1:1'
        )]
        [string]$ModelID = 'amazon.nova-reel-v1:1',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Attempt to download the completed video from S3.')]
        [switch]$AttemptS3Download,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Local path to save the downloaded MP4 file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$LocalSavePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'If the bucket belongs to another AWS account, specify that accounts ID.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[0-9]{12}$')]
        [string]$S3OutputBucketOwner,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A KMS encryption key ID.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$S3OutputKmsKeyId,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The interval in seconds between job status checks when waiting for video generation to complete.')]
        [ValidateRange(10, 300)]
        [int]$JobCheckInterval = 30,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The maximum time in minutes to wait for the video generation job to complete.')]
        [ValidateRange(5, 60)]
        [int]$JobTimeout = 20,

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

    # Check for necessary parameters
    if ($AttemptS3Download) {
        if (-not $LocalSavePath) {
            throw 'LocalSavePath is required when using the -AttemptS3Download switch.'
        }
        if (-not (Test-Path -Path $LocalSavePath -IsValid)) {
            throw ('{0} is not a valid path.' -f $LocalSavePath)
        }
    }

    # Validate parameters based on TaskType
    switch ($TaskType) {
        'TEXT_VIDEO' {
            if ([string]::IsNullOrWhiteSpace($VideoPrompt)) {
                throw 'VideoPrompt is required for TEXT_VIDEO task type.'
            }
            if ($VideoPrompt.Length -gt 512) {
                throw 'For TEXT_VIDEO task type, VideoPrompt must be 1-512 characters in length.'
            }
            if ($DurationSeconds -ne 6) {
                Write-Warning 'For TEXT_VIDEO task type, DurationSeconds must be 6. Setting to 6.'
                $DurationSeconds = 6
            }
        }
        'MULTI_SHOT_AUTOMATED' {
            if ([string]::IsNullOrWhiteSpace($VideoPrompt)) {
                throw 'VideoPrompt is required for MULTI_SHOT_AUTOMATED task type.'
            }
            if ($VideoPrompt.Length -gt 4000) {
                throw 'For MULTI_SHOT_AUTOMATED task type, VideoPrompt must be 1-4000 characters in length.'
            }
            if ($DurationSeconds -lt 12 -or $DurationSeconds -gt 120) {
                throw 'For MULTI_SHOT_AUTOMATED task type, DurationSeconds must be between 12 and 120, inclusive.'
            }
            if ($DurationSeconds % 6 -ne 0) {
                throw 'For MULTI_SHOT_AUTOMATED task type, DurationSeconds must be a multiple of 6.'
            }
            if ($MediaPath) {
                Write-Warning 'MediaPath is ignored for MULTI_SHOT_AUTOMATED task type.'
            }
        }
        'MULTI_SHOT_MANUAL' {
            if (-not $Shots -or $Shots.Count -lt 2) {
                throw 'For MULTI_SHOT_MANUAL task type, at least 2 shots must be provided.'
            }
            if ($VideoPrompt) {
                Write-Warning 'VideoPrompt is ignored for MULTI_SHOT_MANUAL task type.'
            }
            if ($MediaPath) {
                Write-Warning 'MediaPath is ignored for MULTI_SHOT_MANUAL task type.'
            }
            # DurationSeconds will be set later based on the number of shots
        }
    }

    # Build model input based on task type
    $modelInput = @{
        taskType              = $TaskType
        videoGenerationConfig = @{
            fps       = 24
            dimension = '1280x720'
            seed      = $Seed
        }
    }

    # Add specific parameters based on task type
    switch ($TaskType) {
        'TEXT_VIDEO' {
            $modelInput.textToVideoParams = @{
                text = $VideoPrompt
            }
            $modelInput.videoGenerationConfig.durationSeconds = 6  # Only supported value for TEXT_VIDEO

            # Add image if provided
            if ($MediaPath) {
                if (-not (Test-Path -Path $MediaPath)) {
                    throw ('MediaPath {0} does not exist.' -f $MediaPath)
                }

                # Determine image format from file extension
                $imageFormat = [System.IO.Path]::GetExtension($MediaPath).ToLower()
                switch ($imageFormat) {
                    '.png' {
                        $format = 'png'
                    }
                    '.jpg' {
                        $format = 'jpeg'
                    }
                    '.jpeg' {
                        $format = 'jpeg'
                    }
                    default {
                        throw 'Unsupported image format. Only PNG and JPEG are supported.'
                    }
                }

                # Convert image to base64 using the private function
                try {
                    Write-Verbose -Message 'Converting image to base64...'
                    $base64Image = Convert-MediaToBase64 -MediaPath $MediaPath
                }
                catch {
                    Write-Error -Message 'Failed to convert image to base64.'
                    Write-Error -Message $_.Exception.Message
                    throw
                }

                # Add image to model input
                $modelInput.textToVideoParams.images = @(
                    @{
                        format = $format
                        source = @{
                            bytes = $base64Image
                        }
                    }
                )
            }
        }
        'MULTI_SHOT_AUTOMATED' {
            # Validate prompt length for multi-shot automated
            if ($VideoPrompt.Length -gt 4000) {
                throw 'For MULTI_SHOT_AUTOMATED task type, VideoPrompt must be 1-4000 characters in length.'
            }

            $modelInput.multiShotAutomatedParams = @{
                text = $VideoPrompt
            }
            $modelInput.videoGenerationConfig.durationSeconds = $DurationSeconds
        }
        'MULTI_SHOT_MANUAL' {
            # Process each shot in the Shots array
            # Initialize an array with the exact size needed to avoid inefficient array concatenation
            $shotsArray = New-Object object[] $Shots.Count
            $shotIndex = 0

            foreach ($shot in $Shots) {
                # Validate shot has text property
                if (-not $shot.ContainsKey('Text') -or [string]::IsNullOrWhiteSpace($shot.Text)) {
                    throw 'Each shot in Shots array must have a non-empty Text property.'
                }

                # Validate text length
                if ($shot.Text.Length -gt 512) {
                    throw 'Shot text must be 1-512 characters in length.'
                }

                $shotObj = @{
                    text = $shot.Text
                }

                # Process image if provided for this shot
                if ($shot.ContainsKey('ImagePath') -and -not [string]::IsNullOrWhiteSpace($shot.ImagePath)) {
                    $imagePath = $shot.ImagePath

                    if (-not (Test-Path -Path $imagePath)) {
                        throw 'ImagePath {0} for shot does not exist.' -f $imagePath
                    }

                    # Determine image format from file extension
                    $imageFormat = [System.IO.Path]::GetExtension($imagePath).ToLower()
                    switch ($imageFormat) {
                        '.png' {
                            $format = 'png'
                        }
                        '.jpg' {
                            $format = 'jpeg'
                        }
                        '.jpeg' {
                            $format = 'jpeg'
                        }
                        default {
                            throw 'Unsupported image format. Only PNG and JPEG are supported.'
                        }
                    }

                    # Convert image to base64 using the private function
                    try {
                        Write-Verbose -Message ('Converting image {0} to base64...' -f $imagePath)
                        $base64Image = Convert-MediaToBase64 -MediaPath $imagePath
                    }
                    catch {
                        Write-Error -Message ('Failed to convert image {0} to base64.' -f $imagePath)
                        Write-Error -Message $_.Exception.Message
                        throw
                    }

                    # Add image to shot
                    $shotObj.image = @{
                        format = $format
                        source = @{
                            bytes = $base64Image
                        }
                    }
                }

                # Add to the array using index assignment (more efficient than array concatenation)
                $shotsArray[$shotIndex] = $shotObj
                $shotIndex++
            }

            $modelInput.multiShotManualParams = @{
                shots = $shotsArray
            }

            # For MULTI_SHOT_MANUAL, duration is determined by the number of shots (each shot is 6 seconds)
            $shotCount = $Shots.Count
        }
    }
    $cmdletParams = @{
        ModelId                  = $ModelID
        ModelInput               = $modelInput
        S3OutputDataConfig_S3Uri = $S3OutputURI
    }

    if ($S3OutputBucketOwner) {
        $cmdletParams.Add('S3OutputDataConfig_BucketOwner', $S3OutputBucketOwner)
    }
    if ($S3OutputKmsKeyId) {
        $cmdletParams.Add('S3OutputDataConfig_KmsKeyId', $S3OutputKmsKeyId)
    }

    Write-Debug -Message 'Cmdlet Params:'
    Write-Debug -Message ($cmdletParams | Out-String)

    Write-Debug -Message '$modelInput:'
    Write-Debug -Message ($modelInput | ConvertTo-Json -Depth 10)

    # Common AWS parameters
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

    # Start the asynchronous invocation
    try {
        Write-Verbose -Message 'Starting asynchronous video generation job...'
        $rawResponse = Start-BDRRAsyncInvoke @cmdletParams @commonParams -ErrorAction Stop
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        if ($exceptionMessage -like "*don't have access*") {
            Write-Debug -Message 'Model access error'
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

    # For async jobs, the rawResponse is the InvocationArn
    $invocationArn = $rawResponse
    Write-Debug -Message ('Received InvocationArn: {0}' -f $invocationArn)


    # Calculate cost estimate based on video duration
    Write-Verbose -Message 'Calculating cost estimate.'

    if ($TaskType -eq 'MULTI_SHOT_MANUAL') {
        $durationInSeconds = $shotCount * 6
    }
    else {
        $durationInSeconds = $modelInput.videoGenerationConfig.durationSeconds
    }

    Write-Debug -Message ('TaskType: {0}, DurationSeconds: {1}' -f $TaskType, $durationInSeconds)

    try {
        # Add cost estimate using the Video parameter set
        Add-ModelCostEstimate -Duration $durationSeconds -ModelID $ModelID

        Write-Verbose -Message ('Estimated cost: ${0} for {1} seconds of video' -f ($durationSeconds * 0.5), $durationSeconds)
    }
    catch {
        Write-Warning -Message 'Failed to calculate cost estimate.'
        Write-Debug -Message $_.Exception.Message
    }

    # If user wants to wait for async job completion and download the result
    if ($AttemptS3Download) {
        Write-Verbose -Message 'Monitoring async job status and waiting for completion...'

        $startTime = Get-Date
        $timeout = New-TimeSpan -Minutes $JobTimeout

        while ($true) {
            $jobStatus = $null
            try {
                $jobStatus = Get-BDRRAsyncInvoke -InvocationArn $invocationArn @commonParams -ErrorAction Stop
            }
            catch {
                Write-Error ('Error checking job status: {0}' -f $_.Exception.Message)
                Write-Warning -Message ('This was the returned InvocationArn: {0}' -f $invocationArn)
                throw $_
            }

            Write-Debug -Message ('Job status details: {0}' -f ($jobStatus | Out-String))
            Write-Debug -Message ('Job status: {0}' -f $jobStatus.Status)

            if ($jobStatus.Status -eq 'Completed') {
                Write-Verbose -Message 'Job completed successfully.'

                # Get the S3 URI for the output file
                $s3OutputDataConfigUri = $jobStatus.OutputDataConfig.S3OutputDataConfig.S3Uri
                if ([string]::IsNullOrEmpty($s3OutputDataConfigUri)) {
                    Write-Warning 'No S3 output URI found in job results'
                    return @{
                        InvocationArn = $invocationArn
                        Status        = 'Completed'
                        Message       = 'Job completed but no S3 URI found. Check S3 bucket manually.'
                    }
                }

                $localFilePath = Join-Path -Path $LocalSavePath -ChildPath ('NovaReel_Video_{0}.mp4' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

                # Ensure path ends with /output.mp4 for Nova Reel videos
                if ($s3OutputDataConfigUri -notlike '*/output.mp4') {
                    $s3OutputDataConfigUri = '{0}/output.mp4' -f $s3OutputDataConfigUri
                }

                Write-Verbose -Message ('Downloading file from: {0} to: {1}' -f $s3OutputDataConfigUri, $localFilePath)

                # Parse the S3 URI to extract bucket name and key
                # Format: s3://bucketname/path/to/file
                if ($s3OutputDataConfigUri -match '^s3://([^/]+)/(.+)$') {
                    $bucketName = $matches[1]
                    $keyName = $matches[2]

                    $s3Params = @{
                        BucketName = $bucketName
                        Key        = $keyName
                        LocalFile  = $localFilePath
                    }
                    Write-Debug -Message ('S3 parameters: Bucket={0}, Key={1}' -f $bucketName, $keyName)
                }
                else {
                    Write-Warning -Message 'Invalid S3 URI format. Expected format: s3://bucketname/path/to/file'
                    return @{
                        InvocationArn = $invocationArn
                        Status        = 'Completed'
                        Message       = 'Job completed but S3 URI format is invalid.'
                        S3Uri         = $s3OutputDataConfigUri
                    }
                }

                try {
                    Copy-S3Object @s3Params @commonParams -ErrorAction Stop
                }
                catch {
                    Write-Warning -Message 'Error downloading file from S3.'
                    Write-Error -Message $_.Exception.Message
                    Write-Warning -Message ('This was the returned InvocationArn: {0}' -f $invocationArn)
                    throw $_
                }
                Write-Verbose -Message ('File downloaded successfully to: {0}' -f $localFilePath)

                # Return information about the downloaded file
                $result = [PSCustomObject]@{
                    InvocationArn   = $invocationArn
                    Status          = $jobStatus.Status
                    LocalFilePath   = $localFilePath
                    S3Uri           = $s3OutputDataConfigUri
                    TaskType        = $TaskType
                    DurationSeconds = $modelInput.videoGenerationConfig.durationSeconds
                }
                return $result
            }
            elseif ($jobStatus.Status -eq 'InProgress') {
                $elapsedTime = (Get-Date) - $startTime
                Write-Debug -Message ('Elapsed time: {0}' -f $elapsedTime.ToString())
                if ($elapsedTime -gt $timeout) {
                    Write-Warning -Message ('Time limit of {0} minutes exceeded while waiting for job completion.' -f $JobTimeout)
                    return [PSCustomObject]@{
                        InvocationArn = $invocationArn
                        Status        = 'Timeout'
                        Message       = ('Job is still in progress after {0} minutes. You can check the status manually later.' -f $JobTimeout)
                    }
                }

                # Calculate expected completion time based on video duration
                $expectedDuration = switch ($TaskType) {
                    'TEXT_VIDEO' {
                        90
                    } # ~90 seconds for 6-second video
                    'MULTI_SHOT_AUTOMATED' {
                        90 * ($modelInput.videoGenerationConfig.durationSeconds / 6)
                    } # ~90 seconds per segment
                    'MULTI_SHOT_MANUAL' {
                        90 * $Shots.Count
                    } # ~90 seconds per shot
                }

                $estimatedTimeRemaining = [Math]::Max(0, $expectedDuration - $elapsedTime.TotalSeconds)

                Write-Verbose -Message ('Job still in progress. Elapsed time: {0}. Estimated time remaining: ~{1:N0} seconds. Checking again in {2} seconds...' -f
                    $elapsedTime.ToString(),
                    $estimatedTimeRemaining,
                    $JobCheckInterval)

                Start-Sleep -Seconds $JobCheckInterval
            }
            else {
                # Job failed or is in another state
                Write-Warning -Message ('Job is in unexpected state: {0}' -f $jobStatus.Status)

                if ($jobStatus.FailureMessage) {
                    Write-Warning -Message ('Failure message: {0}' -f $jobStatus.FailureMessage)

                    # Check for common failure messages
                    if ($jobStatus.FailureMessage -like '*content filters*') {
                        Write-Warning -Message 'The request was blocked by AWS responsible AI content filters.'
                        Write-Warning -Message 'Please adjust your text prompt or input image to comply with AWS content policies.'
                    }
                }

                Write-Warning -Message ('This was the returned InvocationArn: {0}' -f $invocationArn)

                return [PSCustomObject]@{
                    InvocationArn  = $invocationArn
                    Status         = $jobStatus.Status
                    FailureMessage = $jobStatus.FailureMessage
                }
            }
        } #while
    } #if_AttemptS3Download
    else {
        # Return the invocation ARN for user reference

        return [PSCustomObject]@{
            InvocationArn   = $invocationArn
            TaskType        = $TaskType
            DurationSeconds = $durationInSeconds
            Message         = 'Async job started. Use Get-BDRRAsyncInvoke -InvocationArn {0} to check status.' -f $invocationArn
        }
    } #else_AttemptS3Download

} #Invoke-AmazonVideoModel
