---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Reset-ModelContext/
schema: 2.0.0
---

# Reset-ModelContext

## SYNOPSIS
Resets the message context for specified model(s).

## SYNTAX

### Single
```
Reset-ModelContext -ModelID <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### All
```
Reset-ModelContext [-AllModels] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Resets the message context for the specified model or all models, effectively "starting a new conversation".
This is useful for clearing any persisted interaction histories that have been stored during interactions with the model(s).

## EXAMPLES

### EXAMPLE 1
```
Reset-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

Resets the message context for the specified model.

### EXAMPLE 2
```
Reset-ModelContext -AllModels
```

Resets the message context for all models.

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
Resets the message context for all models.

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

Use this function to clear the message context when you want to start a fresh conversation without the influence of prior interactions.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Reset-ModelContext/](https://www.pwshbedrock.dev/en/latest/Reset-ModelContext/)
