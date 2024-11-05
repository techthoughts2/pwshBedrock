# pwshBedrock

[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-5.1+-purple.svg)](https://github.com/PowerShell/PowerShell) [![PowerShell Gallery][psgallery-img]][psgallery-site] ![Cross Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux-lightgrey) [![License][license-badge]](LICENSE) [![Documentation Status](https://readthedocs.org/projects/pwshbedrock/badge/?version=latest)](https://pwshbedrock.readthedocs.io/en/latest/?badge=latest)

[psgallery-img]:   https://img.shields.io/powershellgallery/dt/pwshBedrock?label=Powershell%20Gallery&logo=powershell
[psgallery-site]:  https://www.powershellgallery.com/packages/pwshBedrock
[license-badge]:   https://img.shields.io/github/license/techthoughts2/pwshBedrock

<p align="left">
    <img src="assets/pwshBedrock.png" alt="pwshBedrock Logo" >
</p>

## What is pwshBedrock?

pwshBedrock is a PowerShell module designed to facilitate interaction with foundation models (FMs) on the Amazon Bedrock platform. It provides a comprehensive set of cmdlets that allow users to send messages, retrieve responses, manage conversation contexts, generate and transform images, and estimate costs. With support for both direct model calls via InvokeModel and a consistent interface through the Converse API, pwshBedrock simplifies the integration of generative AI capabilities into PowerShell scripts and workflows, making it accessible and efficient for developers to leverage AI in their PowerShell projects.

## Why pwshBedrock?

Interacting with foundation models on Amazon Bedrock typically requires extensive research to understand each model's unique capabilities and the precise JSON payloads needed for interaction. This can be time-consuming and complex, especially when crafting payloads and converting data formats isn't the primary focus for many PowerShell developers.

pwshBedrock abstracts this complexity by supporting parameters for each model based on their capabilities, allowing you to pass simple values and native PowerShell objects. The module handles the JSON payload formation, enabling you to interact with models using straightforward commands without delving into the intricacies of payload structures.

- **Converse API Made Easy**: For Converse API interactions, pwshBedrock eliminates the need to manually create and manage complex Amazon Bedrock Runtime objects. Standard parameters and PowerShell objects can be used, with all necessary conversions handled internally by the module.
- **Context Management:** Unlike native interactions, pwshBedrock natively manages ongoing context with models, storing interaction histories in memory. It also supports saving and retrieving conversation contexts from disk, allowing you to maintain continuous and coherent interactions across sessions.
- **Media and File Handling:** The module simplifies media and document interactions by handling base64 encoding and memory stream conversions as required by the models. It also supports specifying save paths for generated images, managing retrieval and conversion seamlessly.
- **Token Tracking and Cost Estimation:** pwshBedrock tracks token usage and provides basic cost estimation, giving you insights into your model interactions' usage and cost implications.
- **Model Capability Insights:** The module stores model support information, allowing you to quickly retrieve a model's capabilities and understand what each model can do without extensive research.

## Getting Started

### Prerequisites

- PowerShell 5.1 or later
- AWS account with access to Amazon Bedrock
    - AWS credentials with appropriate `bedrock:InvokeModel` permission
    - You must [manage and add model acesss](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) through one-time request model access action. *Note: this must be done for each model you plan to interact with.*

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
Invoke-AI21LabsJambaModel -Message 'Explain zero-point energy.' -ModelID 'ai21.jamba-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Amazon Titan Image Generator G2 model

```powershell
#------------------------------------------------------------------------------------------------
# Generates an image and saves the image to the C:\temp folder.
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'amazon.titan-image-generator-v2:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Amazon Titan Text models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Amazon Titan model in the specified AWS region and returns the response.
Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

##### Anthropic Models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Anthropic model in the specified AWS region and returns the response.
Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-haiku-20240307-v1:0' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
# Sending a media file to an Anthropic model and retrieving the response
Invoke-AnthropicModel -Message 'What can you tell me about this picture?' -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0' -MediaPath 'C:\images\tanagra.jpg' -Credential $awsCredential -Region 'us-west-2'
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

##### Meta Llama models

```powershell
#------------------------------------------------------------------------------------------------
# Sends a text message to the on-demand Meta model in the specified AWS region and returns the response.
Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama3-8b-instruct-v1:0' -Credential $awsCredential -Region 'us-west-2'
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

##### Stability AI Diffusion models

```powershell
#------------------------------------------------------------------------------------------------
# Generates an image and saves the image to the C:\temp folder.
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2'
#------------------------------------------------------------------------------------------------
```

#### General

```powershell
#------------------------------------------------------------------------------------------------
# Returns the message context history for the specified model.
Get-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
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

## How pwshBedrock Works

pwshBedrock leverages the [AWS.Tools.BedrockRuntime](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_Operations_Amazon_Bedrock_Runtime.html) from the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/) to interact with on-demand [foundational models](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html) in your AWS account.

- **Core Functionality:**
    - [InvokeModel](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModel.html) Calls: Uses the [Invoke-BDRRModel](https://docs.aws.amazon.com/powershell/latest/reference/items/Invoke-BDRRModel.html) cmdlet to send commands to the models.
    - [Converse](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html) API Calls: Uses the [Invoke-BDRRConverse](https://docs.aws.amazon.com/powershell/latest/reference/items/Invoke-BDRRConverse.html) cmdlet to manage interactions via the Converse API.
- **Simplified Parameter Handling:** pwshBedrock simplifies the process by providing easy-to-use parameters that automatically form the required payloads for both `Invoke-BDRRModel` and `Invoke-BDRRConverse`. This includes built-in validations and checks to ensure that only supported values are passed.
- **Context Management -** For models that support conversation context, pwshBedrock automatically manages this context:
    - **In-Memory Storage**: The context of the model interaction is stored in memory by default.
    - **File System Storage**: You can also save the context to the file system and retrieve it later, ensuring continuous interactions across sessions.

### Features

*Note: Not all models support all features*

- **Messaging:** Directly engage with Bedrock models using simple or custom messages and receive responses.
- **Custom Conversations:** Supports custom formats for conversations, allowing for tailored interactions.
- **Context Control:** Maintain continuous and coherent interactions with models through effective context management.
- **Image Generation:** Leverage powerful image generative capabilities to both create and transform images.
- **Document Support:** Upload common document types directly to the model to provide context or generate summaries.
- **Vision:**: Provide medial files directly to the model for context and evaluation.
- **Cost Estimation:** Estimates the cost of your AI engagements, helping you keep a tab on model engagement.
- **Function calling:** Connect models to external tools. Enables models to handle specific use cases and pull custom responses.
- **Converse API support** Provides a consistent interface that works with most models that support messages. This allows you to write code once and use it with different models. It also provides a consistent response format for each model.
