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
    Describe 'Save-ModelContext Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            It 'should throw if a non supported model is provided' {
                { Save-ModelContext -ModelID 'fakeModelID' -FilePath 'C:\temp' } | Should -Throw
            } #it

            It 'should throw if the file path is not a folder' {
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
                { Save-ModelContext -ModelID 'anthropic.claude-v2:1' -FilePath 'C:\temp\file.txt' } | Should -Throw
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
                { Save-ModelContext -ModelID 'anthropic.claude-v2:1' -FilePath 'C:\temp\doesnotexist' } | Should -Throw
            } #it

            It 'should throw if an error is encountered outputting the file' {
                Mock -CommandName Get-ModelContext -MockWith { return 'context' }
                Mock -CommandName ConvertTo-Clixml -MockWith { return 'contextXML' }
                Mock -CommandName Out-File -MockWith { throw 'error' }
                { Save-ModelContext -ModelID 'anthropic.claude-v2:1' -FilePath $env:TEMP } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $tempPath = [System.IO.Path]::GetTempPath()
            } #beforeEach

            It 'should not save the context if the model context is null' {
                Mock -CommandName Get-ModelContext -MockWith { return $null }
                Mock -CommandName ConvertTo-Clixml -MockWith { return $null }
                Mock -CommandName Out-File -MockWith { return $null }
                Save-ModelContext -ModelID 'anthropic.claude-v2:1' -FilePath $tempPath
                Should -Invoke -CommandName Get-ModelContext -Exactly 1
                Should -Invoke -CommandName ConvertTo-Clixml -Exactly 0
                Should -Invoke -CommandName Out-File -Exactly 0
            } #it

            It 'should save the context if the model context is not null' {
                Mock -CommandName Get-ModelContext -MockWith { return 'context' }
                Mock -CommandName ConvertTo-Clixml -MockWith { return 'contextXML' }
                Mock -CommandName Out-File -MockWith { return $null }
                Save-ModelContext -ModelID 'anthropic.claude-v2:1' -FilePath $tempPath
                Should -Invoke -CommandName Get-ModelContext -Exactly 1
                Should -Invoke -CommandName ConvertTo-Clixml -Exactly 1
                Should -Invoke -CommandName Out-File -Exactly 1
            } #it

        } #context_Success

    } #describe_Save-ModelContext
} #inModule
