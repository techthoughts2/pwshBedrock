---
external help file: pwshBedrock-help.xml
Module Name: pwshBedrock
online version: https://www.pwshbedrock.dev/en/latest/Get-TokenCountEstimate/
schema: 2.0.0
---

# Get-TokenCountEstimate

## SYNOPSIS
Estimates the number of tokens in the provided text.

## SYNTAX

```
Get-TokenCountEstimate [-Text] <String> [<CommonParameters>]
```

## DESCRIPTION
Estimates the number of tokens in the provided text based on an average token length of 4 characters.
It provides a rough estimate of token count, which can be useful for understanding potential usage costs with language models.

## EXAMPLES

### EXAMPLE 1
```
Get-TokenCountEstimate -Text 'This is a test.'
```

Estimates the number of tokens in the provided text.

### EXAMPLE 2
```
Get-TokenCountEstimate -Text (Get-Content -Path 'C:\Temp\test.txt' -Raw)
```

Estimates the number of tokens in the text file.

## PARAMETERS

### -Text
The text to estimate tokens for.

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

### System.Int32
## NOTES
Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

This function provides an estimate of the number of tokens in a given text.
Note that it is just an estimate, as each language model (LLM) has a different tokenization strategy.
The tokenization strategy used in this function is based on an average token length of 4 characters.

## RELATED LINKS

[https://www.pwshbedrock.dev/en/latest/Get-TokenCountEstimate/](https://www.pwshbedrock.dev/en/latest/Get-TokenCountEstimate/)
