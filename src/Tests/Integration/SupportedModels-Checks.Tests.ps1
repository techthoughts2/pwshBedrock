#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------

Describe 'Supported Models Checks' -Tag Integration {
    BeforeDiscovery {
        $supportedModels = @(
            'ai21.jamba-instruct-v1:0'
            'ai21.jamba-1-5-mini-v1:0',
            'ai21.jamba-1-5-large-v1:0',
            'amazon.nova-pro-v1:0',
            'amazon.nova-lite-v1:0',
            'amazon.nova-micro-v1:0',
            'amazon.nova-canvas-v1:0',
            'amazon.nova-reel-v1:1',
            'amazon.titan-image-generator-v1'
            'amazon.titan-image-generator-v2:0'
            'amazon.titan-text-express-v1'
            'amazon.titan-text-lite-v1'
            'amazon.titan-text-premier-v1:0'
            'amazon.titan-tg1-large'
            'anthropic.claude-v2:1'
            # 'anthropic.claude-v2'
            'anthropic.claude-3-haiku-20240307-v1:0'
            'anthropic.claude-3-5-haiku-20241022-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0'
            'anthropic.claude-3-sonnet-20240229-v1:0'
            'anthropic.claude-3-5-sonnet-20241022-v2:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0'
            'anthropic.claude-3-7-sonnet-20250219-v1:0'
            # 'anthropic.claude-instant-v1'
            'cohere.command-text-v14'
            'cohere.command-light-text-v14'
            'cohere.command-r-v1:0'
            'cohere.command-r-plus-v1:0'
            'deepseek.r1-v1:0'
            'luma.ray-v2:0',
            'meta.llama3-70b-instruct-v1:0'
            'meta.llama3-8b-instruct-v1:0'
            'meta.llama3-1-8b-instruct-v1:0'
            'meta.llama3-1-70b-instruct-v1:0'
            'meta.llama3-1-405b-instruct-v1:0'
            'meta.llama3-2-1b-instruct-v1:0',
            'meta.llama3-2-3b-instruct-v1:0',
            'meta.llama3-2-11b-instruct-v1:0',
            'meta.llama3-2-90b-instruct-v1:0',
            'meta.llama3-3-70b-instruct-v1:0',
            'mistral.mistral-7b-instruct-v0:2'
            'mistral.mistral-large-2402-v1:0'
            'mistral.mistral-large-2407-v1:0',
            'mistral.pixtral-large-2502-v1:0',
            'mistral.mistral-small-2402-v1:0'
            'mistral.mixtral-8x7b-instruct-v0:1'
            'stability.stable-diffusion-xl-v1',
            'stability.stable-image-ultra-v1:0',
            'stability.stable-image-core-v1:0'
            'stability.sd3-large-v1:0',
            'stability.sd3-5-large-v1:0'
        )
        $filesWithAllModelsReferences = @(
            'Add-ModelCostEstimate.ps1'
        )
    }
    Context 'Add-ModelCostEstimate.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Add-ModelCostEstimate.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Private', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Get-ModelContext.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Get-ModelContext.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Get-ModelCostEstimate.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Get-ModelCostEstimate.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Get-ModelInfo.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Get-ModelInfo.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Get-ModelTally.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Get-ModelTally.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Reset-ModelContext.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Reset-ModelContext.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Reset-ModelTally.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Reset-ModelTally.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

    Context 'Save-ModelContext.ps1' {

        BeforeAll {
            $ModuleName = 'pwshBedrock'
            $file = 'Save-ModelContext.ps1'

            Set-Location -Path $PSScriptRoot
            $pathToSrcFiles = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', $ModuleName)

            $filePath = [System.IO.Path]::Combine($pathToSrcFiles, 'Public', $file)
            $fullFilePath = [System.IO.Path]::GetFullPath($filePath)

            $fileContent = Get-Content -Path $fullFilePath -Raw

        }

        It 'Should have support for <_>' -ForEach $supportedModels {
            $fileContent | Should -Match $_
        }

    } #context_file_checks

} #describe
