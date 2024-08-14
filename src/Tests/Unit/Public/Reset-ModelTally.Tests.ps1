BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Reset-ModelTally Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'ShouldProcess' {

            BeforeEach {
                Mock -CommandName Reset-ModelTally -MockWith { } #endMock
            } #end_beforeEach

            It 'Should process by default' {
                Reset-ModelTally -ModelID 'anthropic.claude-v2:1'

                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Reset-ModelTally -ModelID 'anthropic.claude-v2:1' -Confirm }
                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Low'
                    Reset-ModelTally -ModelID 'anthropic.claude-v2:1'
                }
                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Reset-ModelTally -ModelID 'anthropic.claude-v2:1' -WhatIf }
                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Reset-ModelTally -ModelID 'anthropic.claude-v2:1'
                }
                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Reset-ModelTally -ModelID 'anthropic.claude-v2:1' -Force
                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 1
            } #it

            It 'Should process on force with All' {
                $ConfirmPreference = 'Medium'
                Reset-ModelTally -AllModels -Force
                Should -Invoke Reset-ModelTally -Scope It -Exactly -Times 1
            } #it

        } #context_shouldprocess

        Context 'Error' {

            It 'should throw if multiple parameters are provided' {
                { Reset-ModelTally -ModelID 'anthropic.claude-v2:1' -AllModels } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedRockSessionCostEstimate = 1
                $v21 = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq 'anthropic.claude-v2:1' }
                $v21.TotalCost = 1
                $v21.InputTokenCount = 1
                $v21.OutputTokenCount = 1
                $v21.InputTokenCost = 1
                $v21.OutputTokenCost = 1
                $v3 = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq 'anthropic.claude-3-sonnet-20240229-v1:0' }
                $v3.TotalCost = 1
                $v3.InputTokenCount = 1
                $v3.OutputTokenCount = 1
                $v3.InputTokenCost = 1
                $v3.OutputTokenCost = 1
            } #beforeEach
            AfterAll {
                Reset-ModelTally -AllModels
            }

            It 'should reset the tally for a single model' {
                Reset-ModelTally -ModelID 'anthropic.claude-v2:1'
                $eval = Get-ModelTally -ModelID 'anthropic.claude-v2:1'
                $eval.TotalCost | Should -BeExactly 0
                $eval.InputTokenCount | Should -BeExactly 0
                $eval.OutputTokenCount | Should -BeExactly 0
                $eval.InputTokenCost | Should -BeExactly 0
                $eval.OutputTokenCost | Should -BeExactly 0

                $eval2 = Get-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
                $eval2.TotalCost | Should -BeExactly 1
                $eval2.InputTokenCount | Should -BeExactly 1
                $eval2.OutputTokenCount | Should -BeExactly 1
                $eval2.InputTokenCost | Should -BeExactly 1
                $eval2.OutputTokenCost | Should -BeExactly 1
            } #it

            It 'should reset the tally for all models' {
                Reset-ModelTally -AllModels
                $Global:pwshBedRockSessionCostEstimate | Should -BeExactly 0
                foreach ($model in $Global:pwshBedRockSessionModelTally) {
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

        } #context_Success

    } #describe_Reset-ModelTally
} #inModule
