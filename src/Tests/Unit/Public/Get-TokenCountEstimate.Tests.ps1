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
    Describe 'Get-TokenCountEstimate Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll
        # Context 'Error' {

        # } #context_Error
        Context 'Success' {

            BeforeEach {
            } #beforeEach

            It 'should return the expected results' {
                Get-TokenCountEstimate -Text 'You broke your little ships.' | Should -BeExactly 7
            } #it

            It 'should return the expected token count for a long string' {
                $text = @'
His nose should pant,
And his lip should curl,
His cheeks should flame,
And his brow should furl,
His bosom should heave,
And his heart should glow,
And his fist be ever ready for a knock-down blow.
'@
                Get-TokenCountEstimate -Text $text | Should -BeExactly 50
            } #it

        } #context_Success

    } #describe_Get-TokenCountEstimate
} #inModule
