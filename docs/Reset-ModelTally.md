---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Reset-ModelTally/
schema: 2.0.0
---

# Reset-ModelTally

## SYNOPSIS

Resets the tally for specified model(s).

## SYNTAX

### Single

```powershell
Reset-ModelTally -ModelID <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### All

```powershell
Reset-ModelTally [-AllModels] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Resets the tally for a specific model or all models.
The tally includes the total cost, input token count,
output token count, input token cost, and output token cost.
This is useful for starting fresh estimates of model usage.

## EXAMPLES

### EXAMPLE 1

```powershell
Reset-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

Resets the tally for the model 'anthropic.claude-3-sonnet-20240229-v1:0'.

### EXAMPLE 2

```powershell
Reset-ModelTally -AllModels
```

Resets the tally for all models.
Use this when you want to also reset the total cost estimate.

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

Resets the tally for all models.

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

### -Force

Skip Confirmation

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

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
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

### None

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

[https://www.pwshbedrock.dev/en/latest/Reset-ModelTally/](https://www.pwshbedrock.dev/en/latest/Reset-ModelTally/)

[https://aws.amazon.com/bedrock/pricing/](https://aws.amazon.com/bedrock/pricing/)
