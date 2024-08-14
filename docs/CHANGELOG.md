# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.2.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.14.0]

- Module changes:
    - Amazon
        - Added support for Titan Image Generator G1 V2 - `amazon.titan-image-generator-v2:0`
            - Added new Conditioned Image Generation parameters to `Invoke-AmazonImageModel`
            - Added new Color Guided Content parameters to `Invoke-AmazonImageModel`
    - Meta
        - Added support for Llama 3.1 405B Instruct - `meta.llama3-1-405b-instruct-v1:0`
        - Updated pricing to reflect current Meta Llama 3.1 prices
        - Corrected Meta Llama 3.1 models to show Multilingual support as `$true`
- Build changes:
    - Updated tests to follow Pester 5 rules

## [0.9.1]

- Updated IconUri in manifest.

## [0.9.0]

### Added

- Initial release.
