<#
.SYNOPSIS
    Sends messages to a Luma AI model on the Amazon Bedrock platform to generate a video.
.DESCRIPTION
    Sends an asynchronous message to a Luma AI model on the Amazon Bedrock platform to generate a video.
    The response from this model is an invocation ARN, which can be used to check the status of the async job.
    The async job once completed will store the output video in the specified S3 bucket.
    The cmdlet will also attempt to download the video from S3 if the -AttemptS3Download switch is specified.
.EXAMPLE
    Invoke-LumaAIModel -VideoPrompt 'A cat playing with a ball' -S3OutputURI 's3://mybucket' -Credential $awsCredential -Region 'us-west-2'

    Generates a video asynchronously using the Luma AI model with the prompt 'A cat playing with a ball' and stores the output in the specified S3 bucket. Returns the invocation ARN.

.EXAMPLE
    $invokeLumaAIModelSplat = @{
        VideoPrompt       = 'A cat playing with a ball'
        S3OutputURI       =  's3://mybucket'
        AttemptS3Download = $true
        LocalSavePath     = 'C:\temp\videos'
        Credential        = $Credential
        Region            = 'us-west-2'
    }
    Invoke-LumaAIModel @invokeLumaAIModelSplat

    Generates a video asynchronously using the Luma AI model with the prompt 'A cat playing with a ball' and stores the output in the specified S3 bucket. Downloads the video to the specified local path.
.PARAMETER VideoPrompt
    A text prompt used to generate the output video.
.PARAMETER S3OutputURI
    The MP4 file will be stored in the Amazon S3 bucket as configured in the response.
.PARAMETER AspectRatio
    The aspect ratio of the output video.
.PARAMETER Loop
    Whether to loop the output video.
.PARAMETER Duration
    The duration of the output video.
.PARAMETER Resolution
    The resolution of the output video.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER AttemptS3Download
    Attempt to download the completed video from S3.
.PARAMETER LocalSavePath
    Local path to save the downloaded MP4 file.
    This parameter is required if the -AttemptS3Download switch is specified.
.PARAMETER S3OutputBucketOwner
    If the bucket belongs to another AWS account, specify that accounts ID.
.PARAMETER S3OutputKmsKeyId
    A KMS encryption key ID.
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

    By default, this function will only return the invocation ARN of the async job. If you want to download the video from S3, you must specify the -AttemptS3Download switch and provide a valid -LocalSavePath.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Invoke-LumaAIModel/
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-luma.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_service-with-iam.html
.LINK
    https://docs.lumalabs.ai/docs/video-generation
#>
function Invoke-LumaAIModel {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUsePSCredentialType', '',
        Justification = 'Suppressed to support AWS credential parameter.')]
    param (
        #_______________________________________________________
        # required parameters
        [Parameter(Mandatory = $true,
            HelpMessage = 'A text prompt used to generate the output video.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 5000)]
        [string]$VideoPrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The MP4 file will be stored in the Amazon S3 bucket as configured in the response.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^s3://[a-z0-9][-a-z0-9.]*[a-z0-9](/.*)?$')]
        [string]$S3OutputURI,

        #_______________________________________________________
        # optional parameters

        [Parameter(Mandatory = $false,
            HelpMessage = 'The aspect ratio of the output video.')]
        [ValidateSet(
            '1:1',
            '16:9',
            '9:16',
            '4:3',
            '3:4',
            '21:9',
            '9:21'
        )]
        [string]$AspectRatio,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Whether to loop the output video.')]
        [bool]$Loop,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The duration of the output video')]
        [ValidateSet(
            '5s',
            '9s'
        )]
        [string]$Duration,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The resolution of the output video.')]
        [ValidateSet(
            '540p',
            '720p'
        )]
        [string]$Resolution ,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'luma.ray-v2:0'
        )]
        [string]$ModelID = 'luma.ray-v2:0',

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

        #_______________________________________________________
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

    $modelInfo = $script:stabilityAIModelInfo | Where-Object { $_.ModelId -eq $ModelID }
    Write-Debug -Message 'Model Info:'
    Write-Debug -Message ($modelInfo | Out-String)

    if ($AttemptS3Download) {
        if (-not $LocalSavePath) {
            throw 'LocalSavePath is required when using the -AttemptS3Download switch.'
        }
        if (-not (Test-Path -Path $LocalSavePath -IsValid)) {
            throw '{0} is not a valid path.' -f $LocalSavePath
        }
    }

    $modelInput = @{
        prompt = $VideoPrompt
    }

    #region optional parameters

    if ($AspectRatio) {
        $modelInput | Add-Member -NotePropertyName 'aspect_ratio' -NotePropertyValue $AspectRatio
    }
    if ($Loop) {
        $modelInput | Add-Member -NotePropertyName 'loop' -NotePropertyValue $Loop
    }
    if ($Duration) {
        $modelInput | Add-Member -NotePropertyName 'duration' -NotePropertyValue $Duration
    }
    if ($Resolution) {
        $modelInput | Add-Member -NotePropertyName 'resolution' -NotePropertyValue $Resolution
    }

    #endregion

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
    Write-Debug -Message ($modelInput | Out-String)

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

    # https://docs.aws.amazon.com/powershell/latest/reference/items/Start-BDRRAsyncInvoke.html
    try {
        $rawResponse = Start-BDRRAsyncInvoke @cmdletParams @commonParams -ErrorAction Stop
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

    # For Luma AI async jobs, the rawResponse is the InvocationArn
    $invocationArn = $rawResponse
    Write-Debug -Message "Received InvocationArn: $invocationArn"

    Write-Verbose -Message 'Calculating cost estimate.'
    $imageCount = 1
    if ($Resolution -eq '720p') {
        $stepCount = 2
    }
    else {
        $stepCount = 1
    }
    Add-ModelCostEstimate -ImageCount $imageCount -Steps $stepCount -ModelID $ModelID

    # If user wants to wait for async job completion and download the result
    if ($AttemptS3Download) {
        Write-Debug -Message 'Attempting to download the video from S3...'

        Write-Verbose -Message 'Monitoring async job status...'
        $startTime = Get-Date
        $timeout = New-TimeSpan -Minutes 15
        $checkInterval = 30  #seconds

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
                $s3OutPutDataConfigUri = $jobStatus.OutputDataConfig.S3OutputDataConfig.S3Uri
                if ([string]::IsNullOrEmpty($s3OutPutDataConfigUri)) {
                    Write-Warning 'No S3 output URI found in job results'
                    return $invocationArn
                }

                $localFilePath = Join-Path -Path $LocalSavePath -ChildPath ('LumaAI_Video_{0}.mp4' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
                if ($s3OutPutDataConfigUri -notlike '*output.mp4') {
                    $s3OutPutDataConfigUri = '{0}/output.mp4' -f $s3OutPutDataConfigUri
                }
                Write-Verbose -Message ('Downloading file from: {0} to: {1}' -f $s3OutPutDataConfigUri, $localFilePath)

                # Parse the S3 URI to extract bucket name and key
                # Format: s3://bucketname/path/to/file
                if ($s3OutPutDataConfigUri -match '^s3://([^/]+)/(.+)$') {
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
                    return $invocationArn
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
                    InvocationArn = $invocationArn
                    Status        = $jobStatus.Status
                    LocalFilePath = $localFilePath
                    S3Uri         = $s3OutPutDataConfigUri
                }
                return $result
            }
            elseif ($jobStatus.Status -eq 'InProgress') {
                $elapsedTime = (Get-Date) - $startTime
                Write-Debug -Message ('Elapsed time: {0}' -f $elapsedTime.ToString())

                if ($elapsedTime -gt $timeout) {
                    Write-Warning -Message 'Time limit of 15 minutes exceeded while waiting for job completion.'
                    return [PSCustomObject]@{
                        InvocationArn = $invocationArn
                        Status        = 'Timeout'
                        Message       = 'Job is still in progress after 15 minutes. You can check the status manually later.'
                    }
                }
                else {
                    Write-Debug -Message ('Job still in progress. Elapsed time: {0}' -f $elapsedTime.ToString())
                }
                Write-Verbose -Message ('Job still in progress. Elapsed time: {0}. Checking again in {1} seconds...' -f $elapsedTime.ToString(), $checkInterval)
                Start-Sleep -Seconds $checkInterval
            }
            else {
                # Job failed or is in another state
                Write-Warning -Message ('Job is in unexpected state: {0}' -f $jobStatus.Status)
                Write-Warning -Message ('This was the returned InvocationArn: {0}' -f $invocationArn)
                return $invocationArn
            }
        } #while

    } #if_AttemptS3Download
    else {
        # Return the invocation ARN for user reference
        return [PSCustomObject]@{
            InvocationArn = $invocationArn
            Message       = 'Async job started. Use Get-BDRRAsyncInvoke -InvocationArn {0} to check status.' -f $invocationArn
        }
    } #else_AttemptS3Download

} #Invoke-LumaAIModel
