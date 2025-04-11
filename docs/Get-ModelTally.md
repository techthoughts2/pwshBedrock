---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Get-ModelTally/
schema: 2.0.0
---

# Get-ModelTally

## SYNOPSIS

Retrieves the tally for a specific model or all models.

## SYNTAX

### Single

```powershell
Get-ModelTally -ModelID <String> [<CommonParameters>]
```

### All

```powershell
Get-ModelTally [-AllModels] [<CommonParameters>]
```

### Total

```powershell
Get-ModelTally [-JustTotalCost] [<CommonParameters>]
```

## DESCRIPTION

This function retrieves the tally of a specific model or all models.
The tally includes the estimated total cost, input token count,
output token count, estimated input token cost, and estimated output token cost.
pwshBedrock provides this tally to give you a general
estimate of model use.
If you want to get the estimated total cost estimate for all models, use the -JustTotalCost switch.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

Retrieves the tally for the model 'anthropic.claude-3-sonnet-20240229-v1:0'.

### EXAMPLE 2

```powershell
Get-ModelTally -AllModels
```

Retrieves the tally for all models.

### EXAMPLE 3

```powershell
Get-ModelTally -JustTotalCost
```

Retrieves the total cost estimate for all models.

## PARAMETERS

### -ModelID

The unique identifier of the model.

```yaml
Type: String
Parameter Sets: Single
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllModels

Gets the tally for all models.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -JustTotalCost

Gets the total tallied cost for all models.

```yaml
Type: SwitchParameter
Parameter Sets: Total
Aliases:

Required: True
Position: Named
Default value: False
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

The model tally information provided by pwshBedrock is a best effort estimate of model use.
pwshBedrock captures the token input and output counts if provided by the model provider.
If the provider does not provide token counts,
the counts will be estimated based on an average token length of 4 characters.
The cost estimate is based on token cost information
provided by AWS documentation for a single region, which may not reflect current prices or include all regions.
Therefore, the actual costs may vary, and the estimates are likely conservative.
You are responsible for monitoring your usage and costs.
Tally estimates provided by pwshBedrock are just that, estimates.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Get-ModelTally/](https://www.pwshbedrock.dev/en/latest/Get-ModelTally/)

[https://aws.amazon.com/bedrock/pricing/](https://aws.amazon.com/bedrock/pricing/)
