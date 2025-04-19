---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Get-ModelCostEstimate/
schema: 2.0.0
---

# Get-ModelCostEstimate

## SYNOPSIS

Estimates the cost of using a model.

## SYNTAX

### Token

```powershell
Get-ModelCostEstimate [-InputTokenCount <Int32>] [-OutputTokenCount <Int32>] -ModelID <String>
 [<CommonParameters>]
```

### Image

```powershell
Get-ModelCostEstimate -ImageCount <Int32> [-Steps <Int32>] -ModelID <String>
 [<CommonParameters>]
```

### Video

```powershell
Get-ModelCostEstimate -Duration <Int32> -ModelID <String>
 [<CommonParameters>]
```

## DESCRIPTION

This function estimates the cost of using a model based on the provided input and output token counts.
The cost estimate is calculated using token cost information from public AWS documentation for a single AWS region.
Text models are estimated based on input and output token counts, while image models are estimated based on the number of images returned by the API.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ModelCostEstimate -InputTokenCount 1000 -OutputTokenCount 1000 -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

Estimates the cost of using the model 'anthropic.claude-3-sonnet-20240229-v1:0' with 1000 input tokens and 1000 output tokens.

### EXAMPLE 2

```powershell
Get-ModelCostEstimate -ImageCount 5 -Steps 10 -ModelID 'amazon.titan-image-generator-v2:0'
```

Estimates the cost of using the model 'amazon.titan-image-generator-v2:0' with 5 images and 10 steps.

### EXAMPLE 3

```powershell
Get-ModelCostEstimate -Duration 6 -ModelID 'amazon.nova-reel-v1:1'
```

Estimates the cost of using the model 'amazon.nova-reel-v1:1' with a duration of 6 seconds.

## PARAMETERS

### -InputTokenCount

The number of input tokens.

```yaml
Type: Int32
Parameter Sets: Token
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputTokenCount

The number of output tokens.

```yaml
Type: Int32
Parameter Sets: Token
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImageCount

Image count returned by the API.

```yaml
Type: Int32
Parameter Sets: Image
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Steps

Number of steps to run the image model for.

```yaml
Type: Int32
Parameter Sets: Image
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Duration

Duration in seconds for video generation models.

```yaml
Type: Int32
Parameter Sets: Video
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModelID

The unique identifier of the model.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
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

The cost estimate provided by this function is a best effort based on available public information.
Each model provider has its own methodology for tokenization, so you will need to understand how your provider calculates tokens to get accurate estimates.
The estimates are based on token cost information for a single AWS region, which may not reflect your actual price as all possible regions are not considered.
As a result, the actual costs may vary, and the estimates are likely conservative.
You should conduct your own cost analysis for more accurate budgeting.
Remember, model cost estimates provided by pwshBedrock are just that, estimates.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Get-ModelCostEstimate/](https://www.pwshbedrock.dev/en/latest/Get-ModelCostEstimate/)

[https://aws.amazon.com/bedrock/pricing/](https://aws.amazon.com/bedrock/pricing/)
