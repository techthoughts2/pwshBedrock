---
Module Name: pwshBedrock
Module Guid: b4f9e4dc-0229-44ef-99a1-08be4c5e81f2
Download Help Link: NA
Help Version: 0.48.0
Locale: en-US
---

# pwshBedrock Module
## Description
pwshBedrock enables interfacing with Amazon Bedrock foundational models, supporting direct on-demand model calls via InvokeModel and the Converse API for supported models. It allows sending messages, retrieving responses, managing message context, displaying model information, and estimating token counts and costs. Use PowerShell to integrate generative AI applications with Amazon Bedrock.

## pwshBedrock Cmdlets
### [Get-ModelContext](Get-ModelContext.md)
Returns the message context history for the specified model.

### [Get-ModelCostEstimate](Get-ModelCostEstimate.md)
Estimates the cost of using a model.

### [Get-ModelInfo](Get-ModelInfo.md)
Gets information for specified model(s).

### [Get-ModelTally](Get-ModelTally.md)
Retrieves the tally for a specific model or all models.

### [Get-TokenCountEstimate](Get-TokenCountEstimate.md)
Estimates the number of tokens in the provided text.

### [Invoke-AI21LabsJambaModel](Invoke-AI21LabsJambaModel.md)
Sends message(s) to the AI21 Labs Jamba model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-AmazonImageModel](Invoke-AmazonImageModel.md)
Sends message(s) to an Amazon Titan image model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local directory.

### [Invoke-AmazonNovaTextModel](Invoke-AmazonNovaTextModel.md)
Sends message(s) to an Amazon Nova model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-AmazonTextModel](Invoke-AmazonTextModel.md)
Sends message(s) to an Amazon Titan model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-AnthropicModel](Invoke-AnthropicModel.md)
Sends message(s) or media files to an Anthropic model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-CohereCommandModel](Invoke-CohereCommandModel.md)
Sends message(s) to the Cohere Command model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-CohereCommandRModel](Invoke-CohereCommandRModel.md)
Sends message(s) to the Cohere Command R/R+ model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-ConverseAPI](Invoke-ConverseAPI.md)
Sends messages, media, or documents to a model via the Converse API and returns the response.

### [Invoke-MetaModel](Invoke-MetaModel.md)
Sends message(s) to a Meta model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-MistralAIChatModel](Invoke-MistralAIChatModel.md)
Sends message(s) to the Mistral AI chat model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-MistralAIModel](Invoke-MistralAIModel.md)
Sends message(s) to a Mistral AI text model on the Amazon Bedrock platform and retrieves the response.

### [Invoke-StabilityAIDiffusionXLModel](Invoke-StabilityAIDiffusionXLModel.md)
Sends message(s) to an Stability AI XL Diffusion model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local folder.

### [Invoke-StabilityAIImageModel](Invoke-StabilityAIImageModel.md)
Sends message(s) to an Stability AI Image Core model on the Amazon Bedrock platform and retrieves the response and saves the generated image(s) to a local folder.

### [Reset-ModelContext](Reset-ModelContext.md)
Resets the message context for specified model(s).

### [Reset-ModelTally](Reset-ModelTally.md)
Resets the tally for specified model(s).

### [Save-ModelContext](Save-ModelContext.md)
Saves the message context history for the specified model to a file.

### [Set-ModelContextFromFile](Set-ModelContextFromFile.md)
Loads and sets the message context for a model from a file.


