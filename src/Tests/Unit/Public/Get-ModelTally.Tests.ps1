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
        } #beforeAll

        Context 'Error' {

            It 'should throw if multiple parameters are provided' {
                { Get-ModelTally -ModelID 'anthropic.claude-v2:1' -AllModels } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedRockSessionCostEstimate = 1
                $Global:pwshBedRockSessionModelTally = @(
                    [PSCustomObject]@{
                        ModelId          = 'anthropic.claude-v2:1'
                        TotalCost        = 1
                        InputTokenCount  = 1
                        OutputTokenCount = 1
                        InputTokenCost   = 1
                        OutputTokenCost  = 1
                    }
                    [PSCustomObject]@{
                        ModelId          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        TotalCost        = 1
                        InputTokenCount  = 1
                        OutputTokenCount = 1
                        InputTokenCost   = 1
                        OutputTokenCost  = 1
                    }
                )
            } #beforeEach

            It 'should get the tally for a single model' {
                $eval = Get-ModelTally -ModelID 'anthropic.claude-v2:1'
                ($eval | Measure-Object).Count | Should -BeExactly 1
                $eval.TotalCost | Should -BeExactly 1
                $eval.InputTokenCount | Should -BeExactly 1
                $eval.OutputTokenCount | Should -BeExactly 1
                $eval.InputTokenCost | Should -BeExactly 1
                $eval.OutputTokenCost | Should -BeExactly 1
            } #it

            It 'should get the tally for all models' {
                $eval = Get-ModelTally -AllModels
                $eval.Count | Should -BeExactly 2
                foreach ($model in $eval) {
                    $model.TotalCost | Should -BeExactly 1
                    $model.InputTokenCount | Should -BeExactly 1
                    $model.OutputTokenCount | Should -BeExactly 1
                    $model.InputTokenCost | Should -BeExactly 1
                    $model.OutputTokenCost | Should -BeExactly 1
                }
            } #it

            It 'should get the total cost' {
                $eval = Get-ModelTally -JustTotalCost
                $eval | Should -BeExactly 1
            } #it

        } #context_Success

    } #describe_Get-ModelTally
} #inModule
