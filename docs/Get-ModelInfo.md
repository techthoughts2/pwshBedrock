---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Get-ModelInfo/
schema: 2.0.0
---

# Get-ModelInfo

## SYNOPSIS
Gets information for specified model(s).

## SYNTAX

### Single
```
Get-ModelInfo -ModelID <String> [<CommonParameters>]
```

### All
```
Get-ModelInfo [-AllModels] [<CommonParameters>]
```

### Provider
```
Get-ModelInfo -Provider <String> [<CommonParameters>]
```

## DESCRIPTION
Retrieves detailed information for a specific model, all models, or models from a specific provider.
The information includes model capabilities, pricing, and other relevant details.

## EXAMPLES

### EXAMPLE 1
```
Get-ModelInfo -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

Retrieves information for the model 'anthropic.claude-3-sonnet-20240229-v1:0'.

### EXAMPLE 2
```
Get-ModelInfo -AllModels
```

Retrieves information for all models.

### EXAMPLE 3
```
Get-ModelInfo -Provider 'Amazon'
```

Retrieves information for all models from the provider 'Amazon'.

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
Gets information for all models.

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

### -Provider
Gets information for model(s) from a specific provider.

```yaml
Type: String
Parameter Sets: Provider
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

Pricing information provided by pwshBedrock is based on publicly available pricing information from
AWS documentation.
This pricing information is for a single region, may not reflect current prices,
and does not include all regions.
As a result, the actual costs may vary, and the estimates are likely conservative.
You should conduct your own cost analysis for more accurate budgeting.
Remember, model cost estimates provided by pwshBedrock are just that, estimates.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Get-ModelInfo/](https://www.pwshbedrock.dev/en/latest/Get-ModelInfo/)
