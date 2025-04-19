BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    Describe 'Get-ModelCostEstimate Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            It 'should return the expected cost results for <_.Model>' -Foreach $script:anthropicModelInfo {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach ($script:amazonModelInfo | Where-Object { $_.Vision -eq $false }) {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach ($script:amazonModelInfo | Where-Object { $_.Vision -eq $false }) {
                $ImageCount = 1
                $ModelID = $_.ModelID
                [float]$imageCost = $_.ImageCost
                $ExpectedCost = [PSCustomObject]@{
                    ImageCost = $imageCost
                }
                $eval = Get-ModelCostEstimate -ImageCount $ImageCount -ModelID $ModelID
                $eval.ImageCost | Should -BeExactly $ExpectedCost.ImageCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach $script:ai21ModelInfo {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach $script:cohereModelInfo {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach $script:deepseekModelInfo {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach $script:lumaModelInfo {
                $ImageCount = 1
                $Steps = 2
                $ModelID = $_.ModelID
                [float]$imageCost = $_.ImageCost.SevenTwenty
                $ExpectedCost = [PSCustomObject]@{
                    ImageCost = $imageCost
                }
                $eval = Get-ModelCostEstimate -ImageCount $ImageCount -Steps $Steps -ModelID $ModelID
                $eval.ImageCost | Should -BeExactly $ExpectedCost.ImageCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach $script:metaModelInfo {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected cost results for <_.ModelID>' -Foreach $script:mistralAIModelInfo {
                $InputTokenCount = 1000
                $OutputTokenCount = 1000
                $ModelID = $_.ModelID
                [float]$inputCost = $_.InputTokenCost
                [float]$outputCost = $_.OutputTokenCost
                [float]$total = $inputCost + $outputCost
                $ExpectedCost = [PSCustomObject]@{
                    Total      = $total
                    InputCost  = $inputCost
                    OutputCost = $outputCost
                }
                $eval = Get-ModelCostEstimate -InputTokenCount $InputTokenCount -OutputTokenCount $OutputTokenCount -ModelID $ModelID
                $eval.Total | Should -BeExactly $ExpectedCost.Total
                $eval.InputCost | Should -BeExactly $ExpectedCost.InputCost
                $eval.OutputCost | Should -BeExactly $ExpectedCost.OutputCost
            } #it

            It 'should return the expected low step cost results for <_.ModelID>' -Foreach $script:stabilityAIModelInfo {
                $ImageCount = 1
                $Steps = 40
                $ModelID = $_.ModelID
                [float]$imageCost = $_.ImageCost.Under50Steps
                $ExpectedCost = [PSCustomObject]@{
                    ImageCost = $imageCost
                }
                $eval = Get-ModelCostEstimate -ImageCount $ImageCount -Steps $Steps -ModelID $ModelID
                $eval.ImageCost | Should -BeExactly $ExpectedCost.ImageCost
            } #it

            It 'should return the expected high step cost results for <_.ModelID>' -Foreach $script:stabilityAIModelInfo {
                $ImageCount = 1
                $Steps = 60
                $ModelID = $_.ModelID
                [float]$imageCost = $_.ImageCost.Over50Steps
                $ExpectedCost = [PSCustomObject]@{
                    ImageCost = $imageCost
                }
                $eval = Get-ModelCostEstimate -ImageCount $ImageCount -Steps $Steps -ModelID $ModelID
                $eval.ImageCost | Should -BeExactly $ExpectedCost.ImageCost
            } #it

            It 'should return the expected video cost results for amazon.nova-reel-v1:1' {
                $Duration = 30
                $ModelID = 'amazon.nova-reel-v1:1'
                # Get the model info to calculate expected cost
                $modelInfo = $script:amazonModelInfo | Where-Object { $_.ModelID -eq $ModelID }
                [float]$videoCost = $Duration * $modelInfo.ImageCost
                $ExpectedCost = [PSCustomObject]@{
                    VideoCost = $videoCost
                }
                $eval = Get-ModelCostEstimate -Duration $Duration -ModelID $ModelID
                $eval.VideoCost | Should -BeExactly $ExpectedCost.VideoCost
            } #it

        } #context_Success

    } #describe_Get-ModelCostEstimate
} #inModule
