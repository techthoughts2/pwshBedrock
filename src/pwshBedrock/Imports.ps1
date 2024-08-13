# This is a locally sourced Imports file for local development.
# It can be imported by the psm1 in local development to add script level variables.
# It will merged in the build process. This is for local development only.

# region script variables
# $script:resourcePath = "$PSScriptRoot\Resources"

#region model tally variables

$Global:pwshBedRockSessionCostEstimate = 0
$Global:pwshBedRockSessionModelTally = @(
    [PSCustomObject]@{
        ModelId          = 'Converse'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'ai21.j2-grande-instruct'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'ai21.j2-jumbo-instruct'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'ai21.jamba-instruct-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'ai21.j2-mid-v1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'ai21.j2-ultra-v1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId    = 'amazon.titan-image-generator-v1'
        ImageCount = 0
        ImageCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'amazon.titan-text-express-v1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'amazon.titan-text-lite-v1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'amazon.titan-text-premier-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'amazon.titan-tg1-large'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'anthropic.claude-v2:1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'anthropic.claude-3-haiku-20240307-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'anthropic.claude-3-opus-20240229-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'cohere.command-text-v14'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'cohere.command-light-text-v14'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'cohere.command-r-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'cohere.command-r-plus-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama2-13b-chat-v1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama2-70b-chat-v1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama3-70b-instruct-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama3-8b-instruct-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama3-1-8b-instruct-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama3-1-70b-instruct-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'meta.llama3-1-405b-instruct-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'mistral.mistral-7b-instruct-v0:2'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'mistral.mistral-large-2402-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'mistral.mistral-large-2407-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'mistral.mistral-small-2402-v1:0'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId          = 'mistral.mixtral-8x7b-instruct-v0:1'
        TotalCost        = 0
        InputTokenCount  = 0
        OutputTokenCount = 0
        InputTokenCost   = 0
        OutputTokenCost  = 0
    }
    [PSCustomObject]@{
        ModelId    = 'stability.stable-diffusion-xl-v1'
        ImageCount = 0
        ImageCost  = 0
    }
)

#endregion

#region model context variables

$Global:pwshBedrockModelContext = @(
    [PSCustomObject]@{
        ModelId = 'Converse'
        Context = New-Object System.Collections.Generic.List[object]
    }
    # [PSCustomObject]@{
    #     ModelId = 'ai21.j2-grande-instruct'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    # [PSCustomObject]@{
    #     ModelId = 'ai21.j2-jumbo-instruct'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    [PSCustomObject]@{
        ModelId = 'ai21.jamba-instruct-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    # [PSCustomObject]@{
    #     ModelId = 'ai21.j2-mid-v1'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    # [PSCustomObject]@{
    #     ModelId = 'ai21.j2-ultra-v1'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    # [PSCustomObject]@{
    #     ModelId = 'amazon.titan-image-generator-v1'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    [PSCustomObject]@{
        ModelId = 'amazon.titan-text-express-v1'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'amazon.titan-text-lite-v1'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'amazon.titan-text-premier-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'amazon.titan-tg1-large'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'anthropic.claude-v2:1'
        Context = New-Object System.Collections.Generic.List[object]
    }
    [PSCustomObject]@{
        ModelId = 'anthropic.claude-3-haiku-20240307-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    [PSCustomObject]@{
        ModelId = 'anthropic.claude-3-opus-20240229-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    [PSCustomObject]@{
        ModelId = 'anthropic.claude-3-sonnet-20240229-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    [PSCustomObject]@{
        ModelId = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    # [PSCustomObject]@{
    #     ModelId = 'cohere.command-text-v14'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    # [PSCustomObject]@{
    #     ModelId = 'cohere.command-light-text-v14'
    #     Context = New-Object System.Collections.Generic.List[object]
    # }
    [PSCustomObject]@{
        ModelId = 'cohere.command-r-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    [PSCustomObject]@{
        ModelId = 'cohere.command-r-plus-v1:0'
        Context = New-Object System.Collections.Generic.List[object]
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama2-13b-chat-v1'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama2-70b-chat-v1'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama3-70b-instruct-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama3-8b-instruct-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama3-1-8b-instruct-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama3-1-70b-instruct-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'meta.llama3-1-405b-instruct-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'mistral.mistral-7b-instruct-v0:2'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'mistral.mistral-large-2402-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'mistral.mistral-large-2407-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'mistral.mistral-small-2402-v1:0'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
        Context = ''
    }
    [PSCustomObject]@{
        ModelId = 'stability.stable-diffusion-xl-v1'
        Context = New-Object System.Collections.Generic.List[object]
    }
)

#endregion

#region model info

# https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html
# https://docs.aws.amazon.com/bedrock/latest/userguide/model-ids.html
# https://aws.amazon.com/bedrock/pricing/
# https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html - supported models and model features

#region anthropic

# https://docs.anthropic.com/en/docs/models-overview#model-comparison
# https://docs.anthropic.com/en/api/messages

$script:anthropicModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'Anthropic'
        ModelName                  = 'Claude'
        ModelId                    = 'anthropic.claude-v2:1'
        Description                = 'Updated version of Claude 2 with improved accuracy'
        Strength                   = 'Legacy model - performs less well than Claude 3 models'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 200000
        MaxOutput                  = 4096
        TrainingCutoff             = '01-01-2023'
        PayloadLimit               = '20MB'
        InputTokenCost             = 0.008
        OutputTokenCost            = 0.024
    }
    [PSCustomObject]@{
        ProviderName               = 'Anthropic'
        ModelName                  = 'Claude 3 Haiku'
        ModelId                    = 'anthropic.claude-3-haiku-20240307-v1:0'
        Description                = 'Fastest and most compact model for near-instant responsiveness'
        Strength                   = 'Quick and accurate targeted performance'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $true
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 200000
        MaxOutput                  = 4096
        TrainingCutoff             = '08-01-2023'
        PayloadLimit               = '20MB'
        InputTokenCost             = 0.00025
        OutputTokenCost            = 0.00125
    }
    [PSCustomObject]@{
        ProviderName               = 'Anthropic'
        ModelName                  = 'Claude 3 Sonnet'
        ModelId                    = 'anthropic.claude-3-sonnet-20240229-v1:0'
        Description                = 'Ideal balance of intelligence and speed for enterprise workloads'
        Strength                   = 'Maximum utility at a lower price, dependable, balanced for scaled deployments'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $true
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 200000
        MaxOutput                  = 4096
        TrainingCutoff             = '08-01-2023'
        PayloadLimit               = '20MB'
        InputTokenCost             = 0.003
        OutputTokenCost            = 0.015
    }
    [PSCustomObject]@{
        ProviderName               = 'Anthropic'
        ModelName                  = 'Claude 3.5 Sonnet'
        ModelId                    = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
        Description                = 'Most intelligent model'
        Strength                   = 'Highest level of intelligence and capability'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $true
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 200000
        MaxOutput                  = 4096
        TrainingCutoff             = '04-01-2024'
        PayloadLimit               = '20MB'
        InputTokenCost             = 0.003
        OutputTokenCost            = 0.015
    }
    [PSCustomObject]@{
        ProviderName               = 'Anthropic'
        ModelName                  = 'Claude 3 Opus'
        ModelId                    = 'anthropic.claude-3-opus-20240229-v1:0'
        Description                = 'Most powerful model for highly complex tasks'
        Strength                   = 'Top-level performance, intelligence, fluency, and understanding'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $true
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 200000
        MaxOutput                  = 4096
        TrainingCutoff             = '08-01-2023'
        PayloadLimit               = '20MB'
        InputTokenCost             = 0.015
        OutputTokenCost            = 0.075
    }
) #anthropicModelInfo

#endregion

#region amazon

# https://docs.aws.amazon.com/bedrock/latest/userguide/titan-text-models.html
# https://docs.aws.amazon.com/bedrock/latest/userguide/titan-image-models.html
# https://aws.amazon.com/machine-learning/responsible-machine-learning/titan-text-premier/

$script:amazonModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'Amazon'
        ModelName                  = 'Amazon Titan Text G1 - Premier'
        ModelId                    = 'amazon.titan-text-premier-v1:0'
        Description                = @'
Amazon Titan Text G1 - Premier is a large language model for text generation.
It is useful for a wide range of tasks including open-ended and context-based question answering, code generation, and summarization.
This model is integrated with Amazon Bedrock Knowledge Base and Amazon Bedrock Agents. The model also supports Custom Fine tuning in preview.
'@
        Strength                   = '32k context window, open-ended text generation, brainstorming, summarizations, code generation, table creation, data formatting, paraphrasing, chain of thought, rewrite, extraction, QnA, chat, Knowledge Base support, Agents support, Model Customization (preview)'
        Multilingual               = $false
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 32000
        MaxOutput                  = 8192
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.0005
        OutputTokenCost            = 0.0015
    }
    [PSCustomObject]@{
        ProviderName               = 'Amazon'
        ModelName                  = 'Titan Text G1 - Express'
        ModelId                    = 'amazon.titan-text-express-v1'
        Description                = @'
Amazon Titan Text G1 - Express is a large language model for text generation.
It is useful for a wide range of advanced, general language tasks such as open-ended text generation and conversational chat, as well as support within Retrieval Augmented Generation (RAG).
At launch, the model is optimized for English, with multilingual support for more than 30 additional languages available in preview.'
'@
        Strength                   = 'Retrieval augmented generation, open-ended text generation, brainstorming, summarizations, code generation, table creation, data formatting, paraphrasing, chain of thought, rewrite, extraction, QnA, and chat.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 8000
        MaxOutput                  = 8192
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.0002
        OutputTokenCost            = 0.0006
    }
    [PSCustomObject]@{
        ProviderName               = 'Amazon'
        ModelName                  = 'Titan Text G1 - Lite'
        ModelId                    = 'amazon.titan-text-lite-v1'
        Description                = @'
Amazon Titan Text G1 - Lite is a light weight efficient model, ideal for fine-tuning of English-language tasks, including like summarizations and copy writing,
where customers want a smaller, more cost-effective model that is also highly customizable.'
'@
        Strength                   = 'Open-ended text generation, brainstorming, summarizations, code generation, table creation, data formatting, paraphrasing, chain of thought, rewrite, extraction, QnA, and chat.'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 4000
        MaxOutput                  = 4096
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.00015
        OutputTokenCost            = 0.0002
    }
    [PSCustomObject]@{
        ProviderName               = 'Amazon'
        ModelName                  = 'Titan Text Large'
        ModelId                    = 'amazon.titan-tg1-large'
        Description                = @'
Amazon Titan Text G1 - Premier is a large language model for text generation.
It is useful for a wide range of tasks including open-ended and context-based question answering, code generation, and summarization.
This model is integrated with Amazon Bedrock Knowledge Base and Amazon Bedrock Agents. The model also supports Custom Fine tuning in preview.'
'@
        Strength                   = '32k context window, open-ended text generation, brainstorming, summarizations, code generation, table creation, data formatting, paraphrasing, chain of thought, rewrite, extraction, QnA, chat, Knowledge Base support, Agents support, Model Customization (preview)'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 32000
        MaxOutput                  = 3072
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.0005
        OutputTokenCost            = 0.0015
    }
    [PSCustomObject]@{
        ProviderName               = 'Amazon'
        ModelName                  = 'Titan Image Generator G1'
        ModelId                    = 'amazon.titan-image-generator-v1'
        Description                = @'
Amazon Titan Image Generator G1 is an image generation model.
It generates images from text, and allows users to upload and edit an existing image.
This model can generate images from natural language text and can also be used to edit or generate variations for an existing or a generated image.
Users can edit an image with a text prompt (without a mask) or parts of an image with an image mask.
You can extend the boundaries of an image with outpainting, and fill in an image with inpainting.
It can also generate variations of an image based on an optional text prompt.
'@
        Strength                   = 'image generation, image editing, image variations'
        Multilingual               = $false
        Text                       = $false
        Document                   = $false
        Vision                     = $true
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $true
        ContextWindow              = ''
        MaxOutput                  = ''
        TrainingCutoff             = ''
        PayloadLimit               = '5MB'
        ImageCost                  = 0.012
        # InputTokenCost             = 0.01
        # OutputTokenCost            = 0.012
        # pricing structure is different for image models
    }
) #amazonModelInfo

#endregion

#region AI21 Labs

# https://docs.ai21.com/changelog/jurassic-2-and-task-specific-apis-are-now-available
# https://docs.ai21.com/docs/jurassic-2-models
# https://docs.ai21.com/docs/instruct-models
# https://docs.ai21.com/reference/j2-complete-ref
# https://docs.ai21.com/docs/choosing-the-right-instance-type-for-amazon-sagemaker-models

# https://docs.ai21.com/docs/jamba-models
# https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-jamba.html
# https://docs.ai21.com/reference/jamba-instruct-api#response-details
# https://docs.ai21.com/docs/migrating-from-jurassic-to-jamba
# https://docs.ai21.com/docs/prompt-engineering


$script:ai21ModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'AI21 Labs'
        ModelName                  = 'Jamba-Instruct'
        ModelId                    = 'ai21.jamba-instruct-v1:0'
        Description                = 'Built on top of our flagship base model, Jamba Instruct is tailored for commercial use. It is a chat model with instruction-following capability, and integrates safety features and guardrails. Most importantly, this model is optimized for real-world deployment. Jamba responses can include markdown; if you do not want markdown in any responses, indicate it in your system or initial contextual prompt'
        Strength                   = '256K context window, instruction following, chat capabilities, enhanced command comprehension.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $true
        ContextWindow              = 256000
        MaxOutput                  = 4096
        TrainingCutoff             = '02-01-2024'
        PayloadLimit               = ''
        InputTokenCost             = 0.0005
        OutputTokenCost            = 0.0007
    }
    [PSCustomObject]@{
        ProviderName               = 'AI21 Labs'
        ModelName                  = 'J2 Grande Instruct'
        ModelId                    = 'ai21.j2-grande-instruct'
        Description                = 'Designed specifically for generating text based on minimal context. Highly accurate, and can be fine-tuned to power smart chatbot and other conversational interfaces.'
        Strength                   = 'Designed to meticulously follow instructions. Trained specifically to handle instructions-only prompts ("zero-shot") without examples ("few-shot"). It is the most natural way to interact with large language models, and it is the best way to get a sense of the optimal output for your task without any examples.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $false
        ContextWindow              = 8192
        MaxOutput                  = 8191
        TrainingCutoff             = '03-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.0188 #! this pricing was not available in the documentation. keeping the same as ultra pricing.
        OutputTokenCost            = 0.0188 #! this pricing was not available in the documentation. keeping the same as ultra pricing.
    }
    [PSCustomObject]@{
        ProviderName               = 'AI21 Labs'
        ModelName                  = 'J2 Jumbo Instruct'
        ModelId                    = 'ai21.j2-jumbo-instruct'
        Description                = 'Similar to Grande-Instruct, but with superior language understanding and response generation capabilities. Ideal for users with more advanced conversational interface needs.'
        Strength                   = 'Designed to meticulously follow instructions. Trained specifically to handle instructions-only prompts ("zero-shot") without examples ("few-shot"). It is the most natural way to interact with large language models, and it is the best way to get a sense of the optimal output for your task without any examples.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $false
        ContextWindow              = 8192
        MaxOutput                  = 8191
        TrainingCutoff             = '03-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.0188 #! this pricing was not available in the documentation. keeping the same as ultra pricing.
        OutputTokenCost            = 0.0188 #! this pricing was not available in the documentation. keeping the same as ultra pricing.
    }
    [PSCustomObject]@{
        ProviderName               = 'AI21 Labs'
        ModelName                  = 'Jurassic-2 Mid'
        ModelId                    = 'ai21.j2-mid-v1'
        Description                = 'This model offers enhanced text generation capabilities, making it well-suited to language tasks with a greater degree of complexity.'
        Strength                   = 'Text generation based on prompting, Instruction following, Sentiment analysis, Summarization, Text recommendation including diversifying vocabulary, grammatical error correction, text segmentation, question and answering.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $false
        ContextWindow              = 8192
        MaxOutput                  = 8191
        TrainingCutoff             = '03-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.0125
        OutputTokenCost            = 0.0125
    }
    [PSCustomObject]@{
        ProviderName               = 'AI21 Labs'
        ModelName                  = 'Jurassic-2 Ultra'
        ModelId                    = 'ai21.j2-ultra-v1'
        Description                = 'As the largest and most powerful model in the Jurassic series, J2-Ultra is an ideal choice for the most complex language processing tasks and generative text applications.'
        Strength                   = 'Text generation based on prompting, Instruction following, Sentiment analysis, Summarization, Text recommendation including diversifying vocabulary, grammatical error correction, text segmentation, question and answering.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $false
        ContextWindow              = 8192
        MaxOutput                  = 8191
        TrainingCutoff             = '03-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.0188
        OutputTokenCost            = 0.0188
    }
) #ai21ModelInfo

#endregion

#region Cohere

# https://docs.cohere.com/docs/the-cohere-platform
# https://docs.cohere.com/docs/models
# https://docs.cohere.com/docs/command-r-plus
# https://docs.cohere.com/docs/command-r
# https://docs.cohere.com/docs/command-beta

$script:cohereModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'Cohere'
        ModelName                  = 'Command'
        ModelId                    = 'cohere.command-text-v14'
        Description                = 'An instruction-following conversational model that performs language tasks with high quality, more reliably and with a longer context than our base generative models.'
        Strength                   = 'chat, summarize'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $false
        ContextWindow              = 4000
        MaxOutput                  = 4000
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.0015
        OutputTokenCost            = 0.0020
    }
    [PSCustomObject]@{
        ProviderName               = 'Cohere'
        ModelName                  = 'Command Light'
        ModelId                    = 'cohere.command-light-text-v14'
        Description                = 'A smaller, faster version of command. Almost as capable, but a lot faster.'
        Strength                   = 'chat, summarize'
        Multilingual               = $false
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $false
        ContextWindow              = 4000
        MaxOutput                  = 4000
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.0003
        OutputTokenCost            = 0.0006
    }
    [PSCustomObject]@{
        ProviderName               = 'Cohere'
        ModelName                  = 'Command R'
        ModelId                    = 'cohere.command-r-v1:0'
        Description                = 'Command R is an instruction-following conversational model that performs language tasks at a higher quality, more reliably, and with a longer context than previous models.'
        Strength                   = 'chat, complex workflows like code generation, retrieval augmented generation (RAG), tool use, and agents.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 128000
        MaxOutput                  = 4000
        TrainingCutoff             = '04-01-2024'
        PayloadLimit               = ''
        InputTokenCost             = 0.0005
        OutputTokenCost            = 0.0015
    }
    [PSCustomObject]@{
        ProviderName               = 'Cohere'
        ModelName                  = 'Command R+'
        ModelId                    = 'cohere.command-r-plus-v1:0'
        Description                = 'Command R+ is an instruction-following conversational model that performs language tasks at a higher quality, more reliably, and with a longer context than previous models.'
        Strength                   = 'chat, best suited for complex RAG workflows and multi-step tool use.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 128000
        MaxOutput                  = 4000
        TrainingCutoff             = '04-01-2024'
        PayloadLimit               = ''
        InputTokenCost             = 0.0030
        OutputTokenCost            = 0.0150
    }
) #cohereModelInfo

#endregion

#region Meta

# https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html
# https://huggingface.co/blog/llama2#how-to-prompt-llama-2
# https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-2/
# https://github.com/meta-llama/llama/blob/main/MODEL_CARD.md
# https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/
# https://github.com/meta-llama/llama3/blob/main/MODEL_CARD.md
# https://llama.meta.com/docs/model-cards-and-prompt-formats/llama3_1
# https://github.com/meta-llama/llama-models/blob/main/models/llama3_1/MODEL_CARD.md

$script:metaModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 2 Chat 13B'
        ModelId                    = 'meta.llama2-13b-chat-v1'
        Description                = 'Our fine-tuned LLMs, called Llama-2-Chat, are optimized for dialogue use cases. Llama-2-Chat models outperform open-source chat models on most benchmarks we tested, and in our human evaluations for helpfulness and safety, are on par with some popular closed-source models like ChatGPT and PaLM.'
        Strength                   = 'Tuned models are intended for assistant-like chat'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 4000
        MaxOutput                  = 2048
        TrainingCutoff             = '07-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.00075
        OutputTokenCost            = 0.001
    }
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 2 Chat 70B'
        ModelId                    = 'meta.llama2-70b-chat-v1'
        Description                = 'Our fine-tuned LLMs, called Llama-2-Chat, are optimized for dialogue use cases. Llama-2-Chat models outperform open-source chat models on most benchmarks we tested, and in our human evaluations for helpfulness and safety, are on par with some popular closed-source models like ChatGPT and PaLM.'
        Strength                   = 'Tuned models are intended for assistant-like chat'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 4000
        MaxOutput                  = 2048
        TrainingCutoff             = '07-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.00195
        OutputTokenCost            = 0.00256
    }
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 3 8B Instruct'
        ModelId                    = 'meta.llama3-8b-instruct-v1:0'
        Description                = 'The Llama 3 instruction tuned models are optimized for dialogue use cases and outperform many of the available open source chat models on common industry benchmarks.'
        Strength                   = 'Instruction tuned models are intended for assistant-like chat'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 8000
        MaxOutput                  = 2048
        TrainingCutoff             = '03-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.0003
        OutputTokenCost            = 0.0006
    }
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 3 70B Instruct'
        ModelId                    = 'meta.llama3-70b-instruct-v1:0'
        Description                = 'The Llama 3 instruction tuned models are optimized for dialogue use cases and outperform many of the available open source chat models on common industry benchmarks.'
        Strength                   = 'Instruction tuned models are intended for assistant-like chat'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 8000
        MaxOutput                  = 2048
        TrainingCutoff             = '12-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.00265
        OutputTokenCost            = 0.0035
    }
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 3.1 8B Instruct'
        ModelId                    = 'meta.llama3-1-8b-instruct-v1:0'
        Description                = 'Light-weight, ultra-fast model. Instruction tuned text only models are intended for assistant-like chat.'
        Strength                   = 'best suited for limited computational power and resources. The model excels at text summarization, text classification, sentiment analysis, and language translation requiring low-latency inferencing.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 128000
        MaxOutput                  = 2048
        TrainingCutoff             = '12-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.00022
        OutputTokenCost            = 0.00022
    }
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 3.1 70B Instruct'
        ModelId                    = 'meta.llama3-1-70b-instruct-v1:0'
        Description                = 'Highly performant, cost effective model that enables diverse use cases. Instruction tuned text only models are intended for assistant-like chat.'
        Strength                   = 'ideal for content creation, conversational AI, language understanding, R&D, and enterprise applications. The model excels at text summarization and accuracy, text classification, sentiment analysis and nuance reasoning, language modeling, dialogue systems, code generation, and following instructions.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 128000
        MaxOutput                  = 2048
        TrainingCutoff             = '12-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.00099
        OutputTokenCost            = 0.00099
    }
    [PSCustomObject]@{
        ProviderName               = 'Meta'
        ModelName                  = 'Llama 3.1 405B Instruct'
        ModelId                    = 'meta.llama3-1-405b-instruct-v1:0'
        Description                = 'Highly performant, cost effective model that enables diverse use cases. Instruction tuned text only models are intended for assistant-like chat.'
        Strength                   = 'ideal for content creation, conversational AI, language understanding, R&D, and enterprise applications. The model excels at text summarization and accuracy, text classification, sentiment analysis and nuance reasoning, language modeling, dialogue systems, code generation, and following instructions.'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 128000
        MaxOutput                  = 2048
        TrainingCutoff             = '12-01-2023'
        PayloadLimit               = ''
        InputTokenCost             = 0.00532
        OutputTokenCost            = 0.016
    }
) #metaModelInfo

#endregion

#region Mistral AI

# https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-mistral-text-completion.html
# https://docs.mistral.ai/getting-started/models/

$script:mistralAIModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'Mistral AI'
        ModelName                  = 'Mistral 7B Instruct'
        ModelId                    = 'mistral.mistral-7b-instruct-v0:2'
        Description                = 'The first dense model released by Mistral AI, perfect for experimentation, customization, and quick iteration'
        Strength                   = 'interpret and act on detailed instruction'
        Multilingual               = $false
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 32000
        MaxOutput                  = 8192
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.00015
        OutputTokenCost            = 0.0002
    }
    [PSCustomObject]@{
        ProviderName               = 'Mistral AI'
        ModelName                  = 'Mixtral 8X7B Instruct'
        ModelId                    = 'mistral.mixtral-8x7b-instruct-v0:1'
        Description                = 'A sparse mixture of experts model. As such, it leverages up to 45B parameters but only uses about 12B during inference, leading to better inference throughput at the cost of more vRAM.'
        Strength                   = 'Data extraction, Summarizing a Document, Writing emails, Writing a Job Description, or Writing Product Description'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 32000
        MaxOutput                  = 4096
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.00045
        OutputTokenCost            = 0.0007
    }
    [PSCustomObject]@{
        ProviderName               = 'Mistral AI'
        ModelName                  = 'Mistral Large'
        ModelId                    = 'mistral.mistral-large-2402-v1:0'
        Description                = "Our flagship model that's ideal for complex tasks that require large reasoning capabilities or are highly specialized."
        Strength                   = 'Synthetic Text Generation, Code Generation, RAG, or Agents'
        Multilingual               = $true
        Text                       = $true
        Document                   = $true
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 32000
        MaxOutput                  = 8192
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.004
        OutputTokenCost            = 0.012
    }
    [PSCustomObject]@{
        ProviderName               = 'Mistral AI'
        ModelName                  = 'Mistral Small'
        ModelId                    = 'mistral.mistral-small-2402-v1:0'
        Description                = 'Suitable for simple tasks that one can do in bulk.'
        Strength                   = 'Classification, Customer Support, or Text Generation'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 32000
        MaxOutput                  = 8192
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.001
        OutputTokenCost            = 0.003
    }
    [PSCustomObject]@{
        ProviderName               = 'Mistral AI'
        ModelName                  = 'Mistral Large (2407)'
        ModelId                    = 'mistral.mistral-large-2407-v1:0'
        Description                = 'The latest version of Mistral AI flagship large language model, with significant improvements on multilingual accuracy, conversational behavior, coding capabilities, reasoning and instruction-following behavior.'
        Strength                   = 'multilingual translation, text summarization, complex multilingual reasoning tasks, math and coding tasks including code generation'
        Multilingual               = $true
        Text                       = $true
        Document                   = $false
        Vision                     = $false
        SystemPrompt               = $true
        ToolUse                    = $true
        ResponseStreamingSupported = $true
        ChatHistorySupported       = $true
        ContextWindow              = 128000
        MaxOutput                  = 8192
        TrainingCutoff             = 'UNKNOWN' # ! Could not find this information in the documentation
        PayloadLimit               = ''
        InputTokenCost             = 0.001
        OutputTokenCost            = 0.003
    }
) #mistralModelInfo

#endregion

#region Stability AI

$script:stabilityAIModelInfo = @(
    [PSCustomObject]@{
        ProviderName               = 'Stability AI'
        ModelName                  = 'Stable Diffusion XL'
        ModelId                    = 'stability.stable-diffusion-xl-v1'
        Model                      = ''
        Description                = 'Stable Diffusion XL generates images of high quality in virtually any art style and is the best open model for photorealism.'
        Strength                   = 'Develop unlimited creative assets and ideate with images.'
        Multilingual               = $false
        Text                       = $false
        Document                   = $false
        Vision                     = $true
        SystemPrompt               = $false
        ToolUse                    = $false
        ResponseStreamingSupported = $false
        ChatHistorySupported       = $false
        ContextWindow              = ''
        MaxOutput                  = ''
        TrainingCutoff             = ''
        PayloadLimit               = '' #! Couldn't find in documentation
        ImageCost                  = @{
            Over50Steps  = 0.08
            Under50Steps = 0.04
        }
        # InputTokenCost             = 0.01
        # OutputTokenCost            = 0.012
        # pricing structure is different for image models
    }
) #ai21ModelInfo

#endregion

#endregion
