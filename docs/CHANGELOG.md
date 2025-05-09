# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.2.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.85.0] - **BREAKING CHANGES**

- Module changes:
    - Converse
        - `Invoke-ConverseAPI`
            - parameter `MediaPath` renamed to `ImagePath` - ***Breaking Change***
            - parameter `AdditionalModelRequestField` change from type `PSObject` to `[System.Collections.Specialized.OrderedDictionary]` - ***Breaking Change***
            - Fixed bug where use of `AdditionalModelRequestField` was not being properly formatted
            - Added new parameters `VideoPath`, `S3Location`, and `S3BucketOwner` to support Vision models that can take video files
    - Updated model pricing to latest published model prices
    - Minor spelling corrections throughout

## [0.75.0]

- Module changes:
    - Mistral AI
        - `Invoke-MistralAIChatModel.ps1`
            - Added support for new model: `mistral.pixtral-large-2502-v1:0`
                - Added new `MediaPath` parameter as this new model supports vision
            - Fixed bug where `mistral.mistral-small-2402-v1:0` was not functioning properly.

## [0.70.0]

- Module changes:
    - Amazon
        - Added new function `Invoke-AmazonVideoModel` to support text model: `amazon.nova-reel-v1:1`

## [0.65.0]

- Module changes:
    - DeepSeek
        - Added new function `Invoke-DeepSeekModel` to support text model: `deepseek.r1-v1:0`

## [0.60.0]

- Module changes:
    - Anthropic
        - `Invoke-AnthropicModel`
            - added support for new model: `anthropic.claude-3-7-sonnet-20250219-v1:0`
            - added new `Thinking` and `ThinkingBudgetTokens` parameters to support thinking and reasoning outputs for Claude 3.7 Sonnet

## [0.55.0]

- Module changes:
    - Luma
        - Added new function `Invoke-LumaAIModel` to support video model: `luma.ray-v2:0`
    - Manifest updates:
        - Require more recent version of `AWS.Tools.BedrockRuntime` to take advantage of new commands such as `Start-BDRRAsyncInvoke`
        - Require `AWS.Tools.S3` to support async video file generation download from S3.
    - Minor syntax formatting corrections throughout to address new PSScriptAnalyzer rules
- Build changes:
    - Updated bootstrap file to latest versions of modules
    - Updated all GitHub actions workflows from `actions/upload-artifact@v3` to `actions/upload-artifact@v4`
    - `pwshBedrock.build.ps1` Improvements:
        - `Invoke-Formatter` now runs at the end of `Build` step for final cleanup
        - Added new Markdown processing functionality to address two Markdown linting issues:
            - `MD022/blanks-around-headings`
            - `MD040/fenced-code-language`

## [0.52.0] - **BREAKING CHANGES**

- Module changes:
    - Added two new properties to all model documentation objects:
        - `Image` - designates if the model can generate images
        - `Video` - designates if the model can generate video
        - `Vision` - re-purposed to now designate if the model can see and describe uploaded content
            - This required some logic re-work in several functions that were previously using `Vision` to designate image capability
    - Added inference profile ID support to all models IAW [Supported cross-region inference profiles](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html)
        - pwshBedrock will now properly format the inference profile ID for all models that support which enables the ability to make Bedrock calls to other regions
    - `Reset-ModelContext` - fixed issue where certain models were missing from validation.
    - Amazon
        - `Invoke-AmazonNovaTextModel` - added support for new Nova Text models: `amazon.nova-pro-v1:0`, `amazon.nova-lite-v1:0`, `amazon.nova-micro-v1:0`
        - `Invoke-AmazonImageModel`
            - added support for new Nova image model: `amazon.nova-canvas-v1:0`
            - fixed bug where files would not always save to drive
            - `CfgScale` parameter maximum adjusted from 10 to 9.9
    - Meta
        - Removed `meta.llama2-13b-chat-v1` and `meta.llama2-70b-chat-v1` from all functions as Bedrock has EOL these two models. - ***Breaking Change***
        - Updated `Invoke-MetaModel` to support new model: `meta.llama3-3-70b-instruct-v1:0`
    - stability.ai
        - Updated `Invoke-StabilityAIImageModel` to support new model: `stability.sd3-5-large-v1:0`
    - Updated pricing for all models
- Build changes:
    - Updated bootstrap file to latest versions of modules

## [0.33.0] - **BREAKING CHANGES**

- Module changes:
    - stability.ai
        - `Invoke-StabilityAIDiffusionModel` renamed to `Invoke-StabilityAIDiffusionXLModel` - ***Breaking Change***
            - Updated help which had incorrect examples
            - `Height` parameter now defaults to 1024 if no user input is provided.
            - `Width` parameter now defaults to 1024 if no user input is provided.
        - Added `Invoke-StabilityAIImageModel` to support new models: `stability.stable-image-core-v1:0`, `stability.stable-image-ultra-v1:0`, `stability.sd3-large-v1:0`
    - AI21 Labs
        - `Invoke-AI21LabsJambaModel` - added support for `ai21.jamba-1-5-mini-v1:0` and `ai21.jamba-1-5-large-v1:0`
        - `Invoke-AI21LabsJurassic2Model` removed. All support for `ai21.j2-grande-instruct`, `ai21.j2-jumbo-instruct`, `ai21.j2-mid-v1`, `ai21.j2-ultra-v1` removed. These models are being [EOL](https://docs.aws.amazon.com/bedrock/latest/userguide/model-lifecycle.html) in Amazon Bedrock. - ***Breaking Change***
    - Amazon
        - `Invoke-AmazonTextModel` - minor corrections to debug output and help
    - Cohere
        - `Invoke-CohereCommandRModel` - minor corrections to debug output
    - Meta
        - `Invoke-MetaModel`
            - Added support for new 3.2 models: `meta.llama3-2-1b-instruct-v1:0`, `meta.llama3-2-3b-instruct-v1:0`, `meta.llama3-2-11b-instruct-v1:0`,  `meta.llama3-2-90b-instruct-v1:0`
            - Added vision support for new large 3.2 models
            - Added tools support for all Meta models 3.1 and higher
            - minor corrections to debug output and help
    - Mistral
        - `Invoke-MistralAIModel` - minor corrections to debug output and help. Adjusted Max token limit validation.
    - Anthropic
        - `Invoke-AnthropicModel` - added support for new models: `anthropic.claude-3-5-haiku-20241022-v1:0`, `anthropic.claude-3-5-sonnet-20241022-v2:0`
    - Updated pricing for all models
- Build changes:
    - Updated bootstrap AWS modules from `4.1.621` to `4.1.700`
    - Switched `wf_Linux` and `wf_Windows` from CodeBuild actions to GitHub Actions runners due to performance issues with CB.

## [0.15.0]

- Module changes:
    - Amazon
        - Added support for Titan Image Generator G1 V2 - `amazon.titan-image-generator-v2:0`
            - Added new Conditioned Image Generation parameters to `Invoke-AmazonImageModel`
            - Added new Color Guided Content parameters to `Invoke-AmazonImageModel`
            - Added new Background removal parameters to `Invoke-AmazonImageModel`
    - Meta
        - Added support for Llama 3.1 405B Instruct - `meta.llama3-1-405b-instruct-v1:0`
        - Updated pricing to reflect current Meta Llama 3.1 prices
        - Corrected Meta Llama 3.1 models to show Multilingual support as `$true`
    - Mistral AI
        - Updated pricing to reflect current prices
- Build changes:
    - Updated tests to follow Pester 5 rules
    - Updated integration tests for newly added capabilities

## [0.9.1]

- Updated IconUri in manifest.

## [0.9.0]

### Added

- Initial release.
