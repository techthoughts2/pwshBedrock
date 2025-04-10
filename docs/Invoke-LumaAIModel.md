---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Invoke-LumaAIModel/
schema: 2.0.0
---

# Invoke-LumaAIModel

## SYNOPSIS
Sends message(s) to a Luma AI model on the Amazon Bedrock platform to generate a video.

## SYNTAX

```
Invoke-LumaAIModel [-VideoPrompt] <String> [[-S3OutputURI] <String>] [[-AspectRatio] <String>]
 [[-Loop] <Boolean>] [[-Duration] <String>] [[-Resolution] <String>] [[-ModelID] <String>] [-AttemptS3Download]
 [[-LocalSavePath] <String>] [[-S3OutputBucketOwner] <String>] [[-S3OutputKmsKeyId] <String>]
 [[-AccessKey] <String>] [[-Credential] <AWSCredentials>] [[-EndpointUrl] <String>]
 [[-NetworkCredential] <PSCredential>] [[-ProfileLocation] <String>] [[-ProfileName] <String>]
 [[-Region] <Object>] [[-SecretKey] <String>] [[-SessionToken] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Sends an ansynchronous message to a Luma AI model on the Amazon Bedrock platform to generate a video.
The response from this model is an invocation ARN, which can be used to check the status of the async job.
The async job once completed will store the output video in the specified S3 bucket.
The cmdlet will also attempt to download the video from S3 if the -AttemptS3Download switch is specified.

## EXAMPLES

### EXAMPLE 1
```
Invoke-LumaAIModel -VideoPrompt 'A cat playing with a ball' -S3OutputURI 's3://mybucket'
```

Generates a video asynchronously using the Luma AI model with the prompt 'A cat playing with a ball' and stores the output in the specified S3 bucket.
Returns the invocation ARN.

### EXAMPLE 2
```
$invokeLumaAIModelSplat = @{
    VideoPrompt       = 'A cat playing with a ball'
    S3OutputURI       =  's3://mybucket'
    AttemptS3Download = $true
    LocalSavePath     = 'C:\temp\videos'
    Credential        = $Credential
    Region            = 'us-west-2'
}
Invoke-LumaAIModel @invokeLumaAIModelSplat
```

Generates a video asynchronously using the Luma AI model with the prompt 'A cat playing with a ball' and stores the output in the specified S3 bucket.
Downloads the video to the specified local path.

## PARAMETERS

### -VideoPrompt
A text prompt used to generate the output video.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -S3OutputURI
The MP4 file will be stored in the Amazon S3 bucket as configured in the response.

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

### -AspectRatio
The aspect ratio of the output video.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Loop
Whether to loop the output video.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Duration
The duration of the output video.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resolution
The resolution of the output video.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModelID
The unique identifier of the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: Luma.ray-v2:0
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
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -S3OutputBucketOwner
If the bucket belongs to another AWS account, specify that accounts ID.

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

### -S3OutputKmsKeyId
A KMS encryption key ID.

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

### -AccessKey
The AWS access key for the user account.
This can be a temporary access key if the corresponding session token is supplied to the -SessionToken parameter.

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

### -Credential
An AWSCredentials object instance containing access and secret key information, and optionally a token for session-based credentials.

```yaml
Type: AWSCredentials
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndpointUrl
The endpoint to make the call against.
Note: This parameter is primarily for internal AWS use and is not required/should not be specified for  normal usage.
The cmdlets normally determine which endpoint to call based on the region specified to the -Region parameter or set as default in the shell (via Set-DefaultAWSRegion).
Only specify this parameter if you must direct the call to a specific custom endpoint.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkCredential
Used with SAML-based authentication when ProfileName references a SAML role profile. 
Contains the network credentials to be supplied during authentication with the  configured identity provider's endpoint.
This parameter is not required if the user's default network identity can or should be used during authentication.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileLocation
Used to specify the name and location of the ini-format credential file (shared with the AWS CLI and other AWS SDKs)
If this optional parameter is omitted this cmdlet will search the encrypted credential file used by the AWS SDK for .NET and AWS Toolkit for Visual Studio first.
If the profile is not found then the cmdlet will search in the ini-format credential file at the default location: (user's home directory)\.aws\credentials.
If this parameter is specified then this cmdlet will only search the ini-format credential file at the location given.
As the current folder can vary in a shell or during script execution it is advised that you use specify a fully qualified path instead of a relative path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
The user-defined name of an AWS credentials or SAML-based role profile containing credential information.
The profile is expected to be found in the secure credential file shared with the AWS SDK for .NET and AWS Toolkit for Visual Studio.
You can also specify the name of a profile stored in the .ini-format credential file used with  the AWS CLI and other AWS SDKs.

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

### -Region
The system name of an AWS region or an AWSRegion instance.
This governs the endpoint that will be used when calling service operations.
Note that  the AWS resources referenced in a call are usually region-specific.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecretKey
The AWS secret key for the user account.
This can be a temporary secret key if the corresponding session token is supplied to the -SessionToken parameter.

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

### -SessionToken
The session token if the access and secret keys are temporary session-based credentials.

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

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Invoke-LumaAIModel/](https://www.pwshbedrock.dev/en/latest/Invoke-LumaAIModel/)

[https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-luma.html](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-luma.html)

[https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_service-with-iam.html](https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_service-with-iam.html)

[https://docs.lumalabs.ai/docs/video-generation](https://docs.lumalabs.ai/docs/video-generation)
