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
                Reset-ModelTally -AllModels
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
                foreach ($model in $eval) {
                    if ($null -ne $model.ImageCount) {
                        $model.ImageCount | Should -BeExactly 0
                        $model.ImageCost | Should -BeExactly 0
                    }
                    else {
                        $model.TotalCost | Should -BeExactly 0
                        $model.InputTokenCount | Should -BeExactly 0
                        $model.OutputTokenCount | Should -BeExactly 0
                        $model.InputTokenCost | Should -BeExactly 0
                        $model.OutputTokenCost | Should -BeExactly 0
                    }
                }
            } #it

            It 'should get the total cost' {
                $eval = Get-ModelTally -JustTotalCost
                $eval | Should -BeExactly 0
            } #it

        } #context_Success

    } #describe_Get-ModelTally
} #inModule
