# pwshBedrock - The Basics

## Getting Started with pwshBedrock

To use pwshBedrock, you first need to install it from the PowerShell Gallery using the following command:

```powershell
# Install pwshBedrock from the PowerShell Gallery
Install-Module -Name pwshBedrock -Repository PSGallery -Scope CurrentUser
```

### Prerequisites

Before you can use pwshBedrock, you'll need to meet a few prerequisites:

1. **AWS Account**: You need an AWS account. Within your AWS account, you must [manage and add model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) for each model you want to interact with. This is a one-time manual action. Note that model access is region-specific, so if you plan to engage with models in multiple regions, you'll need to perform this step in each region.
1. **AWS Credentials**: You'll need AWS credentials with the `bedrock:InvokeModel` permission.

### Determine which model you'll engage with

Amazon Bedrock supports various [foundation models]((https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)). You need to determine which model suits your requirements and retrieve its [model ID](https://docs.aws.amazon.com/bedrock/latest/userguide/model-ids.html#model-ids-arns). Note that not all models are available in all regions.

You can also get a list of foundation models using the [Get-BDRFoundationModelList](https://docs.aws.amazon.com/powershell/latest/reference/items/Get-BDRFoundationModelList.html) cmdlet from [AWS Tools for PowerShell](https://aws.amazon.com/powershell/).

### Using pwshBedrock with Supported Models

pwshBedrock currently supports on-demand models without embedded output modalities. To get a list of supported models for on-demand use, use the following example:

```powershell
Import-Module AWS.Tools.Bedrock
$models = Get-BDRFoundationModelList -Credential $awsCredential -Region us-west-2
$onDemandTextModels = $models | Where-Object {
    $_.OutputModalities -notcontains 'EMBEDDING' -and
    $_.InferenceTypesSupported -contains 'ON_DEMAND'
}
$onDemandTextModels | Select-Object ProviderName, ModelName, ModelId, InputModalities, InferenceTypesSupported, OutputModalities, ResponseStreamingSupported | Sort-Object ProviderName | Format-Table
```

This example filters the models to show only those that are supported by pwshBedrock for on-demand use in a specific region. Note that this example only pulls models for one region, and may not reflect all supported models.

### Quick Model Information with Get-ModelInfo

pwshBedrock also includes the `Get-ModelInfo` function, which provides rapid insight into supported models and their capabilities. This function quickly displays information about each model, such as whether it supports vision, text, documents, tool use, chat history, and more. Here's an example output for a specific model:

```powershell
Get-ModelInfo -ModelID stability.stable-diffusion-xl-v1
```

This will return detailed information about the model, including its provider, name, description, strengths, and supported features.

#### Choosing a foundation model

See the [FAQ - Which model should I use?](pwshBedrock-FAQ.md#which-model-should-i-use).

## Interacting with a model

### Converse vs Direct InvokeModel interaction

Refer to the [FAQ - When should I use Converse vs calling the model directly using one of the model specific functions?](pwshBedrock-FAQ.md#when-should-i-use-converse-vs-calling-the-model-directly-using-one-of-the-model-specific-functions) to understand when to use each approach.

### Converse API

`pwshBedrock` supports the [Converse](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html) API which provides a consistent interface for most models that support messages. This allows you to write code once and use it with different models.

In the example below, you can change the ModelID to another model, such as `meta.llama3-8b-instruct-v1:0` to engage a different model without modifying the function or parameters. *Note: Converse does not support all model IDs, particularly image-only models.*

```powershell
Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1
```

By default, `pwshBedrock` returns only the text reply from the model. To return the entire object, use the `ReturnFullObject` parameter with `Invoke-ConverseAPI`. Converse always returns the same object format, regardless of the model engaged.

The Converse API requires properly formed converse objects which `pwshBedrock` constructs based on the parameters provided to `Invoke-ConverseAPI`

`Invoke-ConverseAPI` supports a set of inference parameters common to all models such as `MaxTokens`, `StopSequences`, `Temperature`, and `TopP`. Additional model-specific parameters can be passed using the `AdditionalModelRequestField` parameter. For more information, see pwshBedrock Advanced.

#### Document Summarization

If you want to send a model a document such as a 'pdf', 'csv', 'docx', 'xlsx', etc., for providing context or to have it summarized, this is currently only possible when using `Invoke-ConverseAPI`.

pwshBedrock handles validating the document type and ensuring that requirements are met. You just need to provide the path to the document.

For example, to summarize a document:

```powershell
$invokeConverseAPISplat = @{
    Message          = 'Provide a one sentence summary of the document.'
    DocumentPath     = $pathToDocumentFile
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
Invoke-ConverseAPI @invokeConverseAPISplat
```

This command will send the document to the model and request a summary.

### Direct InvokeModel

`pwshBedrock` also supports direct calls to models using [InvokeModel]. Each model family has its own function.

For example, use `Invoke-AnthropicModel` to engage with Anthropic Claude models:

```powershell
Invoke-AnthropicModel -Message 'Explain zero-point energy.' -ModelID 'anthropic.claude-3-haiku-20240307-v1:0' -Credential $awsCredential -Region 'us-west-2'
```

To engage a Meta model, use `Invoke-MetaModel`:

```powershell
Invoke-MetaModel -Message 'Explain zero-point energy.' -ModelID 'meta.llama2-13b-chat-v1' -Credential $awsCredential -Region 'us-west-2'
```

By default, `pwshBedrock` returns only the text reply from the model. To return the entire object, use the `ReturnFullObject` parameter with each model function. Note that each model returns a slightly different object type.

All models require properly formed JSON body payloads, which `pwshBedrock` constructs based on the parameters provided.

Each model function supports a custom set of parameters specific to the model being interacted with.

### Context

By default, if the model you are engaging with supports conversation context, `pwshBedrock` will store the context of your interactions in memory. This means that if you send a prompt to the model and receive a response, the next message you send will include the original message, the model's response, and your new prompt. This increases token usage with each subsequent message.

This default behavior maintains a consistent experience with the model by preserving the context of your previous interactions.

You can change this default behavior by using the `NoContextPersist` parameter. When `NoContextPersist` is provided, interactions with the model are not persisted. Each message you send will be treated as the first message received by the model.

#### Viewing Model Context

`pwshBedrock` provides the `Get-ModelContext` function to view the context of your interactions with any supported model. For example, to retrieve the context for the Anthropic Claude Sonnet model:

```powershell
Get-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

To view the context when using Converse:

```powershell
Get-ModelContext -ModelID 'Converse'
```

Certainly! Here's the updated section with the additional command:

---

#### Resetting Model Context

If you need to reset the message context for a specific model, you can use the `Reset-ModelContext` function. This is useful when you want to start a new conversation with the model, clearing any previous interactions.

To reset the context for a specific model, use:

```powershell
Reset-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

If you want to reset the context for all models at once, you can use:

```powershell
Reset-ModelContext -AllModels
```

This command clears the context for all models, allowing you to start fresh with each one.

#### Saving Model Context to file

You can save a model's context history to a file using the `Save-ModelContext` function:

```powershell
Save-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0' -FilePath 'C:\temp'
```

This allows you persist the context for later use.

#### Retrieving Model Context from file

Retrieve a model's context history from a file using the `Set-ModelContextFromFile` function. *Note: pwshBedrock expects a specific format, so it only supports loading context history generated by pwshBedrock*.

```powershell
Set-ModelContextFromFile -FilePath 'C:\temp\context.xml'
```

Once the context history is loaded, the next message you send to the model will include the full context from the loaded file.

### Image Models

Some models, such as the Stability AI Diffusion model and the Amazon Titan Image model, only return images.

`pwshBedrock` natively supports capturing these image returns and converting them, allowing you to easily save the files to your system. You only need to provide a save path location.

For example, to generate and save an image with the Stability AI Diffusion model:

```powershell
Invoke-AmazonImageModel -ImagesSavePath 'C:\temp' -ImagePrompt 'Create a starship emerging from a nebula.' -ModelID 'stability.stable-diffusion-xl-v1' -Credential $awsCredential -Region 'us-west-2'
```

### Vision Models

Some models, such as the Anthropic Claude 3 models, support vision capabilities. This enables you to send an image directly to the model to provide context, have the model describe the image, interpret the image, or use other vision features.

`pwshBedrock` natively supports converting the image file and sending it in the proper format. It also validates the image against strict requirements and provides feedback if the image doesn't meet the criteria. You simply need to provide the path to the image.

For example, to have the model analyze an image:

```powershell
$invokeAnthropicModelSplat = @{
    Message    = 'What can you tell me about this picture? Is it referencing something?'
    ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
    MediaPath  = 'C:\images\tanagra.jpg'
    Credential = $awsCredential
    Region     = 'us-west-2'
}
Invoke-AnthropicModel @invokeAnthropicModelSplat
```

This command will send the image to the model and request information about it.

## Getting Model Cost Estimate

`pwshBedrock` allows you to estimate the cost of using a model based on input and output token counts or the number of images returned by the API.

To estimate the cost for a text model, you can use the following command:

```powershell
Get-ModelCostEstimate -InputTokenCount 1000 -OutputTokenCount 1000 -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

This example estimates the cost of using the model 'anthropic.claude-3-sonnet-20240229-v1:0' with 1000 input tokens and 1000 output tokens.

**Note:**

- The cost estimate is based on token cost information from public AWS documentation for a single AWS region.
- Each model provider has its own methodology for tokenization, so the actual cost may vary.
- These estimates are a best effort and are likely conservative.
- For more accurate budgeting, you should conduct your own cost analysis.

`pwshBedrock` provides these estimates to help you keep track of your potential costs when using Amazon Bedrock models.

## Getting Model Information

`pwshBedrock` allows you to retrieve detailed information about specific models, all models, or models from a specific provider. This information includes model capabilities, pricing, and other relevant details.

To get information for a specific model, use the following command:

```powershell
Get-ModelInfo -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

This will provide details about the specified model, such as its capabilities, pricing, and other important attributes.

**Note:**

- Pricing information provided by `pwshBedrock` is based on publicly available AWS documentation for a single region.
- Actual costs may vary, and the estimates are likely conservative.
- For accurate budgeting, you should conduct your own cost analysis.

`pwshBedrock` provides this functionality to help you quickly understand the capabilities and costs associated with different models, aiding in the selection of the most suitable model for your needs.

## Tally Information

### Getting Tally Information

`pwshBedrock` provides functionality to retrieve the usage tally for specific models or all models. This tally includes the estimated total cost, input token count, output token count, estimated input token cost, and estimated output token cost.

To get the tally for a specific model:

```powershell
Get-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

To get the tally for all models:

```powershell
Get-ModelTally -AllModels
```

**Note:**

- The tally information is an estimate based on token input and output counts provided by the model provider.
- If the provider does not supply token counts, `pwshBedrock` estimates counts based on an average token length of 4 characters.
- Cost estimates are based on AWS documentation for a single region and may not reflect current prices or include all regions.
- These estimates are conservative and actual costs may vary. You are responsible for monitoring your usage and costs.

#### Resetting Tally Information

You can reset the tally for specific models or all models to start fresh estimates of model usage. This is useful for clearing previous usage data and beginning new calculations.

To reset the tally for a specific model:

```powershell
Reset-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
```

To reset the tally for all models:

```powershell
Reset-ModelTally -AllModels
```

Use this command when you want to reset the total cost estimate as well.

## Estimating Token Count

`pwshBedrock` provides a function to estimate the number of tokens in a given text. This can help you understand potential usage costs with language models.

To estimate the number of tokens in a simple text string:

```powershell
Get-TokenCountEstimate -Text 'This is a test.'
```

To estimate the number of tokens in a text file:

```powershell
Get-TokenCountEstimate -Text (Get-Content -Path 'C:\Temp\test.txt' -Raw)
```

**Note:**

- This function provides a rough estimate based on an average token length of 4 characters.
- Each language model has a different tokenization strategy, so the actual token count may vary.
- Use this estimate to get a general idea of token usage, but conduct a more detailed analysis for precise budgeting.

This function is useful for quickly gauging the token count of your text inputs when planning interactions with language models.
