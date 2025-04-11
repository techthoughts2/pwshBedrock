---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Set-ModelContextFromFile/
schema: 2.0.0
---

# Set-ModelContextFromFile

## SYNOPSIS

Loads and sets the message context for a model from a file.

## SYNTAX

```powershell
Set-ModelContextFromFile [-FilePath] <String> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This function loads and sets the message context for a model from a file.
It allows you to maintain a continuous conversation with the model by reloading previously saved context history.
If you have saved the context history using Save-ModelContext, you can reload it using this function.
This will overwrite the current context for the model, enabling you to continue the conversation from where you left off.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-ModelContextFromFile -FilePath 'C:\temp\context.xml'
```

Sets the message context for the specified model from a file.

## PARAMETERS

### -FilePath

File path to retrieve model context from.

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

This function only supports loading context from files saved using Save-ModelContext.
Use this function to reload model context previously saved with Save-ModelContext.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Set-ModelContextFromFile/](https://www.pwshbedrock.dev/en/latest/Set-ModelContextFromFile/)
