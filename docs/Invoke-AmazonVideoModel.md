---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/Invoke-AmazonVideoModel/
schema: 2.0.0
---

# Invoke-AmazonVideoModel

## SYNOPSIS

Sends messages to an Amazon Nova Reel model on the Amazon Bedrock platform to generate a video.

## SYNTAX

```powershell
Invoke-AmazonVideoModel [[-VideoPrompt] <String>] [[-MediaPath] <String>] [-S3OutputURI] <String>
 [[-TaskType] <String>] [[-DurationSeconds] <Int32>] [[-Shots] <Hashtable[]>] [[-Seed] <Int32>]
 [[-ModelID] <String>] [-AttemptS3Download] [[-LocalSavePath] <String>] [[-S3OutputBucketOwner] <String>]
 [[-S3OutputKmsKeyId] <String>] [[-JobCheckInterval] <Int32>] [[-JobTimeout] <Int32>] [[-AccessKey] <String>]
 [[-Credential] <AWSCredentials>] [[-EndpointUrl] <String>] [[-NetworkCredential] <PSCredential>]
 [[-ProfileLocation] <String>] [[-ProfileName] <String>] [[-Region] <Object>] [[-SecretKey] <String>]
 [[-SessionToken] <String>] [<CommonParameters>]
```

## DESCRIPTION

Sends an asynchronous message to an Amazon Nova Reel model on the Amazon Bedrock platform to generate a video.
The function supports text-to-video generation, text and image-to-video generation, and both short-form and long-form videos.
Short videos are limited to 6 seconds, while long-form videos can be up to 2 minutes long (in 6-second increments).
For long-form videos, either automated generation from a single prompt (MULTI_SHOT_AUTOMATED) or manual shot-by-shot generation (MULTI_SHOT_MANUAL) is supported.

The response from this model is an invocation ARN, which can be used to check the status of the async job.
The async job once completed will store the output video in the specified S3 bucket.
The cmdlet will also attempt to download the video from S3 if the -AttemptS3Download switch is specified.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-AmazonVideoModel -VideoPrompt 'Closeup of a large seashell in the sand, gentle waves flow around the shell. Camera zoom in.' -S3OutputURI 's3://mybucket' -Credential $awsCredential -Region 'us-east-1'
```

Generates a short 6-second video asynchronously using the Amazon Nova Reel model with the prompt and stores the output in the specified S3 bucket.
Returns the invocation ARN.

### EXAMPLE 2

```powershell
$invokeAmazonVideoModelSplat = @{
    VideoPrompt       = 'Closeup of a large seashell in the sand, gentle waves flow around the shell. Camera zoom in.'
    S3OutputURI       = 's3://mybucket'
    AttemptS3Download = $true
    LocalSavePath     = 'C:\temp\videos'
    Credential        = $Credential
    Region            = 'us-east-1'
}
Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
```

Generates a short 6-second video and attempts to download the completed video from S3 to the specified local path.

### EXAMPLE 3

```powershell
$invokeAmazonVideoModelSplat = @{
    VideoPrompt       = 'Closeup of a large seashell in the sand, gentle waves flow around the shell. Camera zoom in.'
    MediaPath         = 'C:\Images\seashell.png'
    S3OutputURI       = 's3://mybucket'
    Credential        = $Credential
    Region            = 'us-east-1'
}
Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
```

Generates a short 6-second video using both text prompt and a reference image as the starting frame.

### EXAMPLE 4

```powershell
$invokeAmazonVideoModelSplat = @{
    VideoPrompt       = 'A man walks through a forest, observing the beauty of nature in various seasons.'
    DurationSeconds   = 24
    TaskType          = 'MULTI_SHOT_AUTOMATED'
    S3OutputURI       = 's3://mybucket'
    Credential        = $Credential
    Region            = 'us-east-1'
}
Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
```

Generates a 24-second long-form video (four 6-second shots) automatically from a single prompt.

### EXAMPLE 5

```powershell
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
```

Generates a 24-second long-form video (four 6-second shots) with manually defined shots, including an image reference for shot 2.

## PARAMETERS

### -VideoPrompt

A text prompt used to generate the output video.
For TEXT_VIDEO and MULTI_SHOT_AUTOMATED task types.
For TEXT_VIDEO, must be 1-512 characters in length.
For MULTI_SHOT_AUTOMATED, must be 1-4000 characters in length.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaPath

File path to local media image file to use as the starting frame of the video.
The image must be in PNG or JPEG format with a resolution of 1280x720 pixels.
Only valid for TEXT_VIDEO task type.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -S3OutputURI

The MP4 file will be stored in the Amazon S3 bucket as configured in the response.
Required parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaskType

The type of video generation task to perform.
- TEXT_VIDEO: Generate a short 6-second video from text, with optional reference image
- MULTI_SHOT_AUTOMATED: Generate a long-form video (12-120 seconds) from a single text prompt
- MULTI_SHOT_MANUAL: Generate a long-form video with manually defined shots
Default is TEXT_VIDEO.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: TEXT_VIDEO
Accept pipeline input: False
Accept wildcard characters: False
```

### -DurationSeconds

The duration of the output video in seconds.
For TEXT_VIDEO, must be 6 (the only supported value).
For MULTI_SHOT_AUTOMATED, must be a multiple of 6 between 12 and 120, inclusive.
For MULTI_SHOT_MANUAL, the duration is determined by the number of shots (6 seconds per shot).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 6
Accept pipeline input: False
Accept wildcard characters: False
```

### -Shots

An array of shot details for MULTI_SHOT_MANUAL task type.
Each shot should be a hashtable with Text key (required) and optional ImagePath key.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Seed

Determines the initial noise setting for the generation process.
The seed value must be between 0-2,147,483,646.
Default is 42.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 42
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModelID

The unique identifier of the model.
Default is 'amazon.nova-reel-v1:1'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: Amazon.nova-reel-v1:1
Accept pipeline input: False
Accept wildcard characters: False
```

### -AttemptS3Download

Attempt to download the completed video from S3.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalSavePath

Local path to save the downloaded MP4 file.
This parameter is required if the -AttemptS3Download switch is specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -S3OutputBucketOwner

If the bucket belongs to another AWS account, specify that account's ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -S3OutputKmsKeyId

A KMS encryption key ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobCheckInterval

The interval in seconds between job status checks when waiting for video generation to complete.
Default is 30 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: 30
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobTimeout

The maximum time in minutes to wait for the video generation job to complete.
Default is 30 minutes, which should be sufficient for most Nova Reel video generation jobs.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: 20
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessKey

The AWS access key for the user account.
This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.

```yaml
Type: AWSCredentials
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndpointUrl

The endpoint to make the call against.
Note: This parameter is primarily for internal AWS use and is not required/should not be specified for normal usage.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkCredential

Used with SAML-based authentication when ProfileName references a SAML role profile.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileLocation

Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName

The user-defined name of an AWS credentials or SAML-based role profile containing credential information.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region

The system name of an AWS region or an AWSRegion instance.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretKey

The AWS secret key for the user account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionToken

The session token if the access and secret keys are temporary session-based credentials.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

By default, this function will only return the invocation ARN of the async job.
If you want to download the video from S3, you must specify the -AttemptS3Download switch and provide a valid -LocalSavePath.

Amazon Nova Reel video generation is an asynchronous process that typically takes about 90 seconds for a 6-second video
and approximately 14-17 minutes for a 2-minute video.

When video generation completes, the video and its constituent shots are stored in the Amazon S3 bucket you specified.
Amazon Nova creates a folder for each invocation ID containing manifest.json, output.mp4, and generation-status.json files.

For MULTI_SHOT_MANUAL task type, each shot is 6 seconds long, so the total duration is 6 × number of shots.

## RELATED LINKS

[https://www.pwshbedrock.dev/Invoke-AmazonVideoModel/](https://www.pwshbedrock.dev/Invoke-AmazonVideoModel/)

[https://docs.aws.amazon.com/nova/latest/userguide/video-generation.html](https://docs.aws.amazon.com/nova/latest/userguide/video-generation.html)

[https://docs.aws.amazon.com/nova/latest/userguide/video-gen-access.html](https://docs.aws.amazon.com/nova/latest/userguide/video-gen-access.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-runtime_example_bedrock-runtime_Scenario_AmazonNova_TextToVideo_section.html](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-runtime_example_bedrock-runtime_Scenario_AmazonNova_TextToVideo_section.html)
