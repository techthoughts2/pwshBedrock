# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.2.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
