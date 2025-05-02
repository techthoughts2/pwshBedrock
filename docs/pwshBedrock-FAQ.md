# pwshBedrock - FAQ

## Why would I use pwshBedrock instead of just calling Invoke-BDRRModel directly?

While you can directly use AWS Tools for PowerShell cmdlets (such as `Invoke-BDRRModel` or `Invoke-BDRRConverse` as part of the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/)) to interact with Amazon Bedrock, pwshBedrock offers several key advantages:

1. **Simplified Parameter Handling**: No need to manually craft complex JSON payloads or handle Bedrock runtime objects. pwshBedrock takes care of this complexity for you, freeing you to focus on your script logic instead of payload details.
2. **Context Management**: pwshBedrock automatically handles conversation context for models that support it. The context is stored in memory by default (with an option to save it to disk), so you can pause and resume multi-turn conversations seamlessly.
3. **Token Tracking & Cost Estimates**: pwshBedrock monitors token usage and provides basic cost estimates for each request. This gives you a clear picture of usage and helps you understand the potential cost of every interaction.
4. **Built-In Model Validations & Automation**: pwshBedrock includes guardrails for each model's unique constraints—such as max token limits—and automates file conversions (e.g., base64 encoding for image uploads). It also handles tasks like video download from S3 for models that generate media. This frees you from model-specific guesswork and ensures more reliable interactions with less overhead.

While more advanced users may find value in learning the specifics of a particular model and making direct calls with `Invoke-BDRRModel` or `Invoke-BDRRConverse`, pwshBedrock serves as a streamlined option that simplifies the process and enhances productivity for most use cases.

## When should I use Converse vs calling the model directly using one of the model specific functions?

There is no perfect answer to this question—it depends on your specific use case.

**Using Converse**:

- **Consistency**: Converse provides a consistent interface that works with most models that support messages. This allows you to write code once and use it with different models, always receiving the same object format in return.
- **Example**:

    ```powershell
    # Calling the Anthropic Claude Sonnet model
    Invoke-ConverseAPI -ModelID anthropic.claude-3-5-sonnet-20240620-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1

    # Calling the Meta model with the same command
    Invoke-ConverseAPI -ModelID meta.llama3-8b-instruct-v1:0 -Message 'Explain zero-point energy.' -Credential $awsCredential -Region us-east-1
    ```

- **Flexibility**: Converse supports a base set of inference parameters common to most models and allows adding additional model-specific parameters using the `AdditionalModelRequestField` parameter.
- **Special Features**: Some features, such as guardrail use cases and document uploads for context or summarization, are currently only supported through the Converse API.

**Using Model-Specific Functions**:

- **Model Support**: Not all models support conversational interactions. For example, models like Stability AI Fusion and Amazon Titan image generator require their specific functions.
- **Validation**: Model-specific functions include validation for parameters specific to each model, preventing errors from incorrect values.
- **Advanced Use Cases**: For more advanced or specific use cases, engaging the model directly may offer more control and precise interactions.
- **Model-Specific Returns**: If you need model-specific return structures, using the direct model functions may be more appropriate.

Ultimately, evaluate your use case to decide whether [InvokeModel](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModel.html) for direct model calls or [Converse](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html) for uniform conversational interactions best suits your requirements and workflow.

## Does pwshBedrock support streaming responses?

No, pwshBedrock does not currently support streaming responses. While it facilitates model interaction through [InvokeModel](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModel.html) and [Converse](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html), it does not support [InvokeModelWithResponseStream](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModelWithResponseStream.html) or [ConverseStream](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ConverseStream.html).

I am open to accepting pull requests to add this capability.

## Which model should I use?

Choosing the right model depends on your specific use case, as each model excels in different areas:

- Text Summarization: Some models are better at summarizing large texts.
- Creative Content: Others are more suited for generating creative content.
- Chatbot Applications: Certain models are designed for chatbot applications but may not retain conversational history.
- Advanced Features: Some models offer advanced features like tool interactions, allowing them to engage other APIs and access additional information.
- Unique Capabilities: Some models support unique capabilities like image generation or transformation.
- Context Windows and Tokens: Consider context windows and maximum tokens when choosing a model.

There is no single model that excels in all areas. If you need a general recommendation, the Anthropic Claude 3 models are a good choice. They support advanced features, including vision (image evaluation), and generally perform well across various categories.

pwshBedrock also has the `Get-ModelInfo` function which can give you quick insight into the various model's capabilities.

Here are some model links to learn about the respective models:

- [Jamba](https://docs.ai21.com/docs/jamba-models)
- [Jurassic-2 models](https://docs.ai21.com/docs/jurassic-2-models)
- [Amazon Titan Image Generator G1 model](https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html)
- [Amazon Titan Text models](https://docs.aws.amazon.com/bedrock/latest/userguide/titan-text-models.html)
- [Anthropic Claude Models](https://docs.anthropic.com/en/docs/about-claude/models)
- [Cohere Models Overview](https://docs.cohere.com/docs/models)
    - [Command R](https://docs.cohere.com/docs/command-r)
    - [Command R+](https://docs.cohere.com/docs/command-r-plus)
- [Meta Model Cards](https://llama.meta.com/docs/model-cards-and-prompt-formats)
    -[Llama 2](https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-2/)
    -[Llama 3](https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/)
- [Mistral AI Models Overview]([Models](https://docs.mistral.ai/getting-started/models/))
- [Stability AI](https://platform.stability.ai/docs/legacy/grpc-api/features/text-to-image)

## How do I pass credentials to pwshBedrock?

In pwshBedrock, the examples often demonstrate using the `Credential` parameter for authentication:

```powershell
Invoke-AmazonTextModel -Message 'Explain zero-point energy.' -ModelID amazon.titan-text-lite-v1 -Region us-west-2 -Credential $awsCredential
```

However, pwshBedrock supports multiple authentication methods, just like the AWS Tools for PowerShell. You can authenticate using:

- `Credential`: Pass a credential object (as shown above).
- `AccessKey` / `SecretKey`: Directly pass access keys.
- `NetworkCredential`: Use Windows credentials.
- `SessionToken`: For temporary sessions.
- `ProfileLocation`: Specify a custom credentials file.
- `ProfileName`: Use a named profile from your AWS credentials file.

To use the `Credential` parameter, you can easily create a credential object like this:

```powershell
$awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('ACCESSKEY', 'SECRETKEY')
Invoke-AmazonTextModel -Message 'Hello, World!' -ModelID amazon.titan-text-lite-v1 -Region us-west-2 -Credential $awsCredential
```

## Can I use AWSPowerShell.NetCore instead of AWS.Tools modules for pwshBedrock?

While [AWSPowerShell.NetCore](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore) is a single, large module that supports all AWS services, it's generally recommended to use the [AWS.Tools](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awstools) modularized version for pwshBedrock. Here's why:

- **AWSPowerShell.NetCore**: This large module bundles support for all AWS services in a single package. As it continues to grow, it takes significantly longer to import into memory, leading to potential performance issues.

- **AWS.Tools**: This modular version allows you to install individual modules for specific AWS services, such as `AWS.Tools.BedrockRuntime`, which reduces memory overhead and improves performance. It is more efficient and likely to be the long-term supported module for PowerShell at AWS.

### Why Can't pwshBedrock Support Both?

The `.psd1` manifest in PowerShell modules must specify dependencies on other modules, but it can only choose **one version**—either `AWSPowerShell.NetCore` or `AWS.Tools`. Unfortunately, it's not possible to specify dependencies on both. Given this limitation, pwshBedrock has chosen to depend on the modularized `AWS.Tools` version because of its performance benefits and long-term support.

While you can technically use **AWSPowerShell.NetCore**, it will not satisfy pwshBedrock's dependency requirements as defined in the `.psd1`. Therefore, to ensure compatibility and meet dependency requirements, **AWS.Tools** is the recommended version for pwshBedrock.
