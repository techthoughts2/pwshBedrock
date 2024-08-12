BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    $allModelIDs = (Get-ModelInfo -AllModels).ModelID
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Set-ModelContextFromFile Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'ShouldProcess' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true } #endMock
                Mock -CommandName Set-ModelContextFromFile -MockWith { } #endMock
            } #end_beforeEach

            It 'Should process by default' {
                Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml"

                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" -Confirm }
                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Low'
                    Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml"
                }
                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" -WhatIf }
                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml"
                }
                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" -Force
                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 1
            } #it

            It 'Should process on force with All' {
                $ConfirmPreference = 'Medium'
                Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" -Force
                Should -Invoke Set-ModelContextFromFile -Scope It -Exactly -Times 1
            } #it

        } #context_shouldprocess

        Context 'Error' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Content -MockWith { return 'context' }
                Mock -CommandName ConvertFrom-Clixml -MockWith {
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-v2:1'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Claude v2.1 context'
                                    }
                                )
                            }
                        )
                    }
                }
            } #beforeEach

            It 'should throw if the file path is not a file' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $false
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $true
                    }
                }
                Mock -CommandName Test-Path -MockWith $mockInvoke
                { Set-ModelContextFromFile -FilePath "$env:TEMP" } | Should -Throw
            } #it

            It 'should throw if the file path does not exist' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                }
                Mock -CommandName Test-Path -MockWith $mockInvoke
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if an error is encountered reading the file' {
                Mock -CommandName Get-Content -MockWith { throw 'error' }
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if the file contents are null' {
                Mock -CommandName Get-Content -MockWith { return $null }
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if an error is encountered converting the file' {
                Mock -CommandName ConvertFrom-Clixml -MockWith { throw 'error' }
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if the context object is null' {
                Mock -CommandName ConvertFrom-Clixml -MockWith { $null }
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if the context object is missing the ModelID' {
                Mock -CommandName ConvertFrom-Clixml -MockWith { [PSCustomObject]@{ Context = 'context' } }
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if the context object is missing the Context' {
                Mock -CommandName ConvertFrom-Clixml -MockWith { [PSCustomObject]@{ ModelID = 'modelID' } }
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

            It 'should throw if the model ID does not match supported models' {
                Mock -CommandName ConvertFrom-Clixml -MockWith {
                    [PSCustomObject]@{
                        ModelID = 'unsupported.model'
                        Context = 'context'
                    }
                } #endMock
                { Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml" } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Content -MockWith { return 'context' }
                Mock -CommandName ConvertFrom-Clixml -MockWith {
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-v2:1'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Claude v2.1 context'
                                    }
                                )
                            }
                        )
                    }
                }
            } #beforeEach

            # 'anthropic.claude-v2:1'
            It 'Should set the model context from the file contents' {
                Set-ModelContextFromFile -FilePath "$env:TEMP\test.xml"
                $context = Get-ModelContext -ModelID 'anthropic.claude-v2:1'
                $context[0].role | Should -Be 'user'
                $context[0].content.type | Should -Be 'text'
                $context[0].content.text | Should -Be 'Claude v2.1 context'
            } #it

        } #context_Success
    } #describe_Set-ModelContextFromFile
} #inModule
