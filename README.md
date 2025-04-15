# pwshBedrock

[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-5.1+-purple.svg)](https://github.com/PowerShell/PowerShell) [![PowerShell Gallery][psgallery-img]][psgallery-site] ![Cross Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-lightgrey) [![License][license-badge]](LICENSE) [![Documentation Status](https://readthedocs.org/projects/pwshbedrock/badge/?version=latest)](https://pwshbedrock.readthedocs.io/en/latest/?badge=latest)

[psgallery-img]:   https://img.shields.io/powershellgallery/dt/pwshBedrock?label=Powershell%20Gallery&logo=powershell
[psgallery-site]:  https://www.powershellgallery.com/packages/pwshBedrock
[license-badge]:   https://img.shields.io/github/license/techthoughts2/pwshBedrock

<p align="center">
    <img src="./docs/assets/pwshBedrock.png" alt="pwshBedrock Logo" >
</p>

Branch | Windows - PowerShell | Windows - pwsh | Linux | MacOS
--- | --- | --- | --- | --- |
main | [![pwshBedrock-Windows-PowerShell](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows.yml/badge.svg?branch=main)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows.yml) | [![pwshBedrock-Windows-pwsh](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows_Core.yml/badge.svg?branch=main)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows_Core.yml)| [![pwshBedrock-Linux](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Linux.yml/badge.svg?branch=main)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Linux.yml) | [![pwshBedrock-MacOS](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_MacOS.yml/badge.svg?branch=main)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_MacOS.yml)
Enhancements | [![pwshBedrock-Windows-PowerShell](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows.yml/badge.svg?branch=Enhancements)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows.yml) | [![pwshBedrock-Windows-pwsh](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows_Core.yml/badge.svg?branch=Enhancements)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Windows_Core.yml) | [![pwshBedrock-Linux](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Linux.yml/badge.svg?branch=Enhancements)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_Linux.yml) | [![pwshBedrock-MacOS](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_MacOS.yml/badge.svg?branch=Enhancements)](https://github.com/techthoughts2/pwshBedrock/actions/workflows/wf_MacOS.yml)

## Synopsis

pwshBedrock is a PowerShell module that enables interaction with foundation models (FMs) on the Amazon Bedrock platform. It allows users to send messages, retrieve responses, manage conversation contexts, generate/transform images, and estimate costs.

## Description

pwshBedrock provides a set of cmdlets to interact with on-demand foundation models (FMs) hosted on Amazon Bedrock. Each model offers varying capabilities, enabling you to send messages or media files, retrieve responses, manage conversation contexts, generate/transform images, and estimate usage costs. This module simplifies the integration of Bedrock models into your PowerShell development and workflows.

You can use pwshBedrock to interact with models directly via InvokeModel or through the Converse API for supported models. Converse provides a consistent interface for most models that support messages, allowing you to write code once and use it with different models while receiving a consistent response format.

pwshBedrock is designed to streamline the process of building generative AI applications with Amazon Bedrock using PowerShell, offering an accessible and efficient approach for developers looking to explore and leverage generative AI within their PowerShell projects.

### Features

*Note: Not all models support all features*

- **Messaging:** Directly engage with Bedrock models using simple or custom messages and receive responses.
- **Custom Conversations:** Supports custom formats for conversations, allowing for tailored interactions.
- **Context Control:** Maintain continuous and coherent interactions with models through effective context management.
- **Image Generation:** Leverage powerful image generative capabilities to both create and transform images.
- **Video Generation:** Leverage powerful video generative capabilities to create videos.
- **Document Support:** Upload common document types directly to the model to provide context or generate summaries.
- **Vision:**: Provide medial files directly to the model for context and evaluation.
- **Cost Estimation:** Estimates the cost of your AI engagements, helping you keep a tab on model engagement.
- **Function calling:** Connect models to external tools. Enables models to handle specific use cases and pull custom responses.
- **Converse API support** Provides a consistent interface that works with most models that support messages. This allows you to write code once and use it with different models. It also provides a consistent response format for each model.

## Getting Started

### Documentation

Documentation for pwshBedrock is available at: [https://www.pwshbedrock.dev](https://www.pwshbedrock.dev)

### Prerequisites

- PowerShell 5.1 or later
- AWS account with access to Amazon Bedrock
    - AWS credentials with appropriate `bedrock:InvokeModel` permission
    - You must [manage and add model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) through one-time request model access action. *Note: this must be done for each model you plan to interact with.*

### Installation

```powershell
# Install pwshBedrock from the PowerShell Gallery
Install-Module -Name pwshBedrock -Repository PSGallery -Scope CurrentUser
```

### Quick start

#### Converse

*Converse provides a consistent interface that works with most models that support messages.*

```powershell
#------------------------------------------------------------------------------------------------
# Sends a message to the specified model via the Converse API in the specified AWS region and returns the response.
Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1
#------------------------------------------------------------------------------------------------
```

#### Models

##### AI21 Labs Jamba-Instruct models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a chat message to the on-demand AI21 Labs Jamba model in the specified AWS region and returns the response.
Invoke-AI21LabsJambaModel -Message 'Explain zero-point energy.' -ModelID 'ai21.jamba-1-5-large-v1:0' -Credential $awsCredential -Region 'us-east-1'
#------------------------------------------------------------------------------------------------
```

##### Amazon Image Generator

```powershell
#------------------------------------------------------------------------------------------------
# Generates an image and saves the image to the C:\temp folder.
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'amazon.nova-canvas-v1:0' -Credential $awsCredential -Region 'us-east-1'
#------------------------------------------------------------------------------------------------
```

##### Amazon Titan Text models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Amazon Titan model in the specified AWS region and returns the response.
Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Amazon Nova Text models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Amazon Nova model in the specified AWS region and returns the response.
Invoke-AmazonNovaTextModel -Message 'Explain zero-point energy.' -ModelID 'amazon.nova-pro-v1:0' -Credential $awsCredential -Region 'us-east-1'
#------------------------------------------------------------------------------------------------
```

##### Anthropic Models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the response.
Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-5-haiku-20241022-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
# Sending a media file to an Anthropic model and retrieving the response
Invoke-AnthropicModel -Message 'What can you tell me about this picture?' -ModelID 'anthropic.claude-3-5-sonnet-20241022-v2:0' -MediaPath 'C:\images\tanagra.jpg' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Cohere Command models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Cohere Command model in the specified AWS region and returns the response.
Invoke-CohereCommandModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-text-v14' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Cohere Command R and Command R+ models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Cohere Command R model in the specified AWS region and returns the response.
Invoke-CohereCommandRModel -Message 'Explain zero-point energy.' -ModelID 'cohere.command-r-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### DeepSeek Models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Cohere Command R model in the specified AWS region and returns the response.
Invoke-DeepSeekModel -Message 'Explain zero-point energy.' -ModelID 'deepseek.r1-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Luma AI Models

```powershell
#------------------------------------------------------------------------------------------------
# Sends messages to a Luma AI model on the Amazon Bedrock platform to generate a video.
Invoke-LumaAIModel -VideoPrompt 'A cat playing with a ball' -S3OutputURI 's3://mybucket' -ModelID 'luma.ray-v2:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
# Generates a video asynchronously using the Luma AI model and stores the output in the specified S3 bucket. Downloads the video to the specified local path.
Invoke-LumaAIModel -VideoPrompt 'A cat playing with a ball' -S3OutputURI 's3://mybucket' -ModelID 'luma.ray-v2:0' -AttemptS3Download -LocalSavePath 'C:\temp\videos' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Meta Llama models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Meta model in the specified AWS region and returns the response.
Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama3-8b-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
# Sending a media file to a Meta model and retrieving the response
Invoke-MetaModel -ImagePrompt 'Describe this image in two sentences.' -ModelID 'meta.llama3-2-11b-instruct-v1:0' -MediaPath 'C:\path\to\image.jpg' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Mistral AI models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a chat message to the on-demand Mistral AI chat model in the specified AWS region and returns the response.
Invoke-MistralAIChatModel -Message 'Explain zero-point energy.' -ModelID 'mistral.mistral-large-2402-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Mistral AI text model in the specified AWS region and returns the response.
Invoke-MistralAIModel -Message 'Explain zero-point energy.' -ModelID 'mistral.mistral-large-2402-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Stability AI models

```powershell
#------------------------------------------------------------------------------------------------
# Generates an image using the on-demand StabilityAI diffusion image model. The returned image is saved to the provided output path.
Invoke-StabilityAIDiffusionXLModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
# Generates an image using the on-demand StabilityAI image model. The returned image is saved to the provided output path.
Invoke-StabilityAIImageModel -ImagesSavePath 'C:\images' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-image-ultra-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

#### General

```powershell
#------------------------------------------------------------------------------------------------
# Returns the message context history for the specified model.
Get-ModelContext -ModelID 'anthropic.claude-3-5-sonnet-20241022-v2:0'
#------------------------------------------------------------------------------------------------
# Estimates the cost of using the model with 1000 input tokens and 1000 output tokens.
Get-ModelCostEstimate -InputTokenCount 1000 -OutputTokenCount 1000 -ModelID 'cohere.command-r-plus-v1:0'
#------------------------------------------------------------------------------------------------
# Gets information about specified model
Get-ModelInfo -ModelID 'anthropic.claude-3-opus-20240229-v1:0'
# Retrieves information for all models.
Get-ModelInfo -AllModels
#------------------------------------------------------------------------------------------------
# Retrieves the tally for the model
Get-ModelTally -ModelID 'meta.llama3-70b-instruct-v1:0'
#------------------------------------------------------------------------------------------------
# Estimates the number of tokens in the provided text.
Get-TokenCountEstimate -Text 'Explain zero-point energy.'
#------------------------------------------------------------------------------------------------
# Resets the message context for the specified model.
Reset-ModelContext -ModelID 'anthropic.claude-v2:1'
#------------------------------------------------------------------------------------------------
# Resets the tally for the model
Reset-ModelTally -ModelID 'mistral.mistral-large-2402-v1:0'
#------------------------------------------------------------------------------------------------
# Saves the message context history for the specified model to a file,
Save-ModelContext -ModelID 'amazon.titan-tg1-large' -FilePath 'C:\temp'
#------------------------------------------------------------------------------------------------
# Loads and sets the message context for a model from a file.
Set-ModelContextFromFile -FilePath 'C:\temp\context.xml'
#------------------------------------------------------------------------------------------------
```

## Contributing

If you'd like to contribute to pwshBedrock, please see the [contribution guidelines](.github/CONTRIBUTING.md).

## License

pwshBedrock is licensed under the [MIT license](LICENSE).
