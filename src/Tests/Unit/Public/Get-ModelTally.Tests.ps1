#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Get-ModelTally Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
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
        } #beforeAll

        Context 'Error' {

            It 'should throw if multiple parameters are provided' {
                { Get-ModelTally -ModelID 'anthropic.claude-v2:1' -AllModels } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedRockSessionCostEstimate = 1
                # $Global:pwshBedRockSessionModelTally = @(
                #     [PSCustomObject]@{
                #         ModelId          = 'anthropic.claude-v2:1'
                #         TotalCost        = 1
                #         InputTokenCount  = 1
                #         OutputTokenCount = 1
                #         InputTokenCost   = 1
                #         OutputTokenCost  = 1
                #     }
                #     [PSCustomObject]@{
                #         ModelId          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                #         TotalCost        = 1
                #         InputTokenCount  = 1
                #         OutputTokenCount = 1
                #         InputTokenCost   = 1
                #         OutputTokenCost  = 1
                #     }
                # )
            } #beforeEach

            It 'should get the tally for a single model' {
                $eval = Get-ModelTally -ModelID 'anthropic.claude-v2:1'
                ($eval | Measure-Object).Count | Should -BeExactly 1
                $eval.TotalCost | Should -BeExactly 0
                $eval.InputTokenCount | Should -BeExactly 0
                $eval.OutputTokenCount | Should -BeExactly 0
                $eval.InputTokenCost | Should -BeExactly 0
                $eval.OutputTokenCost | Should -BeExactly 0
            } #it

            It 'should get the tally for all models' {
                $eval = Get-ModelTally -AllModels
                $eval.Count | Should -BeExactly 32
                (($eval.TotalCost | Where-Object { $_ -eq 0 }) | Measure-Object).Count | Should -BeExactly 30
                (($eval.InputTokenCount | Where-Object { $_ -eq 0 }) | Measure-Object).Count | Should -BeExactly 30
                (($eval.OutputTokenCount | Where-Object { $_ -eq 0 }) | Measure-Object).Count | Should -BeExactly 30
                (($eval.InputTokenCost | Where-Object { $_ -eq 0 }) | Measure-Object).Count | Should -BeExactly 30
                (($eval.OutputTokenCost | Where-Object { $_ -eq 0 }) | Measure-Object).Count | Should -BeExactly 30
            } #it

            It 'should get the total cost' {
                $eval = Get-ModelTally -JustTotalCost
                $eval | Should -BeExactly 1
            } #it

        } #context_Success

    } #describe_Get-ModelTally
} #inModule
