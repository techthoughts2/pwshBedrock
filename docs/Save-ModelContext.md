---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Save-ModelContext/
schema: 2.0.0
---

# Save-ModelContext

## SYNOPSIS
Saves the message context history for the specified model to a file.

## SYNTAX

```
Save-ModelContext [-ModelID] <String> [-FilePath] <String>
 [<CommonParameters>]
```

## DESCRIPTION
This function saves the message context history for the specified model to a file.
The context history is used to maintain
a continuous conversation with the model, allowing you to save the current state and reload it later.
This can be used in conjunction with Set-ModelContextFromFile to save and load context for later use.

## EXAMPLES

### EXAMPLE 1
```
Save-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0' -FilePath 'C:\temp'
```

Saves the message context history for the specified model to a file.

## PARAMETERS

### -ModelID
The unique identifier of the model.

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

### -FilePath
File path to save the context to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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

As you interact with models, message context history is stored in memory by pwshBedrock to maintain a continuous conversation.
Use this function to save the message context history for a specific model.
You can later load the context back into memory using Get-ModelContext -FilePath 'C:\temp\context.xml'.
Use this function in conjunction with Set-ModelContextFromFile to save and load context for later use.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Save-ModelContext/](https://www.pwshbedrock.dev/en/latest/Save-ModelContext/)
