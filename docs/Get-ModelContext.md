---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Get-ModelContext/
schema: 2.0.0
---

# Get-ModelContext

## SYNOPSIS
Returns the message context history for the specified model.

## SYNTAX

```
Get-ModelContext [-ModelID] <String> [<CommonParameters>]
```

## DESCRIPTION
This function returns the message context history for the specified model.
The context history is stored to maintain a continuous conversation with the model.

## EXAMPLES

### EXAMPLE 1
```
Get-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

Returns the message context history for the specified model.

### EXAMPLE 2
```
Get-ModelContext -ModelID 'Converse'
```

Returns the Converse API context history.
The Converse context history can represent whatever model you were interacting with at the time.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -Verbose, -WarningAction, -WarningVariable, and -ProgressAction. 
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject
## NOTES
Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

As you interact with models, message context history is stored in memory by pwshBedrock for maintaining a continuous conversation.
If you want to see the message context history for a specific model you have been interacting with, you can use this function.

The Converse API can be used to interact with various models.
The Converse history is stored in its own Converse context history.
You can retrieve the Converse context history directly by specifying Converse as the ModelID.
However, realize that the Converse context history can represent whatever model you were interacting with at the time.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Get-ModelContext/](https://www.pwshbedrock.dev/en/latest/Get-ModelContext/)
