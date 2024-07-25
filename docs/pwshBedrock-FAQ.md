# pwshBedrock - FAQ

## Why would I use pwshBedrock instead of just calling Invoke-BDRRModel directly?

pwshBedrock is not required to use PowerShell to interact with Amazon Bedrock, as commands like `Invoke-BDRRModel` and `Invoke-BDRRConverse` are already part of the [AWS Tools for PowerShell](https://aws.amazon.com/powershell/). However pwshBedrock offers several key advantages:

1. **Simplified Parameter Handling**:
    - pwshBedrock provides easy-to-use parameters, removing the need to craft complex JSON payloads or Bedrock runtime objects. You can use simple parameter values and native PowerShell objects to interact with the models.
2. **Context Management**:
    - pwshBedrock automatically manages the conversation context for models that support it. This context is stored in memory by default, and you can also save it to the file system for later retrieval, ensuring seamless and continuous interactions.
3. **Abstraction of Complex Payloads**:
    - By abstracting the complexity of forming JSON payloads and handling Bedrock runtime objects, pwshBedrock allows you to focus on your core tasks without getting bogged down by the intricacies of payload structure and validation.
4. **Token Counting and Cost Estimates**:
    - pwshBedrock tracks token usage and provides basic cost estimation, giving you valuable insights into the usage and cost implications of your model interactions.
5. **PowerShell Idiomatic Interface**:
    - pwshBedrock offers a PowerShell-native way to interface with Bedrock, making it intuitive and efficient for PowerShell developers to integrate AI capabilities into their scripts and workflows.

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

pwshBedrock also has the `Get-ModelInfo` function which can give you quick insight into the various model's capabitilties.

Here are some model links to learn about the respective models:

- [Jamba](https://docs.ai21.com/docs/jamba-models)
- [Jurassic-2 models](https://docs.ai21.com/docs/jurassic-2-models)
- [Amazon Titan Image Generator G1 model](https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html)
- [Amazon Titan Text models](https://docs.aws.amazon.com/bedrock/latest/userguide/titan-text-models.html)
- [Anthropic Calude Models](https://docs.anthropic.com/en/docs/about-claude/models)
- [Cohere Models Overview](https://docs.cohere.com/docs/models)
    - [Command R](https://docs.cohere.com/docs/command-r)
    - [Command R+](https://docs.cohere.com/docs/command-r-plus)
- [Meta Model Cards](https://llama.meta.com/docs/model-cards-and-prompt-formats)
    -[Llama 2](https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-2/)
    -[Llama 3](https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/)
- [Mistal AI Models Overview]([Models](https://docs.mistral.ai/getting-started/models/))
- [Stability AI](https://platform.stability.ai/docs/legacy/grpc-api/features/text-to-image)