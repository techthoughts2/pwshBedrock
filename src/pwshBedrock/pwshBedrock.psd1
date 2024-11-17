#
# Module manifest for module 'pwshBedrock'
#
# Generated by: Jake Morrison
#
# Generated on: 5/25/2024
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'pwshBedrock.psm1'

    # Version number of this module.
    ModuleVersion     = '0.30.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = 'b4f9e4dc-0229-44ef-99a1-08be4c5e81f2'

    # Author of this module
    Author            = 'Jake Morrison'

    # Company or vendor of this module
    CompanyName       = 'TechThoughts'

    # Copyright statement for this module
    Copyright         = '(c) Jake Morrison. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = "pwshBedrock enables interfacing with Amazon Bedrock foundational models, supporting direct on-demand model calls via InvokeModel and the Converse API for supported models. It allows sending messages, retrieving responses, managing message context, displaying model information, and estimating token counts and costs. Use PowerShell to integrate generative AI applications with Amazon Bedrock."

    # Minimum version of the PowerShell engine required by this module
    # PowerShellVersion = ''

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        @{
            ModuleName    = 'AWS.Tools.Common'
            ModuleVersion = '4.1.621'
        },
        @{
            ModuleName    = 'AWS.Tools.BedrockRuntime'
            ModuleVersion = '4.1.621'
        },
        @{
            ModuleName    = 'Convert'
            ModuleVersion = '1.5.0'
        }
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-ModelContext'
        'Get-ModelCostEstimate'
        'Get-ModelInfo'
        'Get-ModelTally'
        'Get-TokenCountEstimate'
        'Invoke-AI21LabsJambaModel'
        'Invoke-AmazonImageModel'
        'Invoke-AmazonTextModel'
        'Invoke-AnthropicModel'
        'Invoke-CohereCommandModel'
        'Invoke-CohereCommandRModel'
        'Invoke-ConverseAPI'
        'Invoke-MetaModel'
        'Invoke-MistralAIChatModel'
        'Invoke-MistralAIModel'
        'Invoke-StabilityAIImageModel'
        'Invoke-StabilityAIDiffusionXLModel'
        'Reset-ModelContext'
        'Reset-ModelTally'
        'Save-ModelContext'
        'Set-ModelContextFromFile'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    # CmdletsToExport = '*'

    # Variables to export from this module
    # VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    # AliasesToExport = '*'

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @(
                'AI',
                'AI21',
                'AI21Labs',
                'AIApplications',
                'AIAutomation',
                'AIIntegration',
                'AIModels',
                'AIPrompting',
                'AIUtilities',
                'Amazon',
                'AmazonTitan',
                'AmazonWebServices',
                'Anthropic',
                'ArtificialIntelligence',
                'AWS',
                'AWSBedrock',
                'Bedrock',
                'Claude',
                'Claude3',
                'CloudAI',
                'CloudML',
                'Cohere',
                'Command',
                'CommandR',
                'Converse',
                'ConverseAPI',
                'FMs',
                'FoundationModels',
                'GenerativeAI',
                'Haiku',
                'inpainting',
                'ImageGeneration',
                'Jamba',
                'Jurassic',
                'LanguageAI',
                'LanguageModels',
                'Llama',
                'Llama2',
                'Llama3',
                'MachineLearning',
                'MachineLearningModels',
                'Meta',
                'Mistral',
                'MistralAI',
                'ML',
                'MLModels',
                'MLTools',
                'Models',
                'outpainting',
                'PowerShellAI',
                'PowerShellML',
                'Prompt',
                'Sonnet',
                'StabilityAI',
                'TextGeneration',
                'Titan'
            )

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/techthoughts2/pwshBedrock/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/techthoughts2/pwshBedrock'

            # A URL to an icon representing this module.
            IconUri      = 'https://github.com/techthoughts2/pwshBedrock/raw/main/docs/assets/pwshBedrock_icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/techthoughts2/pwshBedrock/blob/main/docs/CHANGELOG.md'

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}



