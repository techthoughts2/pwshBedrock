BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    # if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    Describe 'Test-DeepSeekCustomConversation Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {
            BeforeEach {
                # Missing begin_of_sentence tag
                $missingBeginTag = '<｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>'

                # Missing end_of_sentence tag
                $missingEndTag = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜Assistant｜>'

                # Missing final Assistant tag
                $missingFinalAssistant = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜end_of_sentence｜>'

                # Missing User tag entirely
                $missingUserTag = '<｜begin_of_sentence｜>You are a helpful assistant.<｜Assistant｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>'

                # Consecutive User tags
                $consecutiveUserTags = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜User｜>And what about 3 + 3?<｜Assistant｜>The answers are 4 and 6.<｜end_of_sentence｜><｜Assistant｜>'

                # Consecutive Assistant tags
                $consecutiveAssistantTags = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜Assistant｜>Did that answer your question?<｜end_of_sentence｜><｜Assistant｜>'

                # Malformed tag
                $malformedTag = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜AssistantTypo｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>'

                # Empty string
                $emptyString = ''

                # Null string
                $nullString = $null
            } #beforeEach

            It 'Should return false when begin_of_sentence tag is missing' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $missingBeginTag
                $result | Should -Be $false
            } #it

            It 'Should return false when end_of_sentence tag is missing' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $missingEndTag
                $result | Should -Be $false
            } #it

            It 'Should return false when final Assistant tag is missing' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $missingFinalAssistant
                $result | Should -Be $false
            } #it

            It 'Should return false when User tag is missing entirely' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $missingUserTag
                $result | Should -Be $false
            } #it

            It 'Should return false when there are consecutive User tags' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $consecutiveUserTags
                $result | Should -Be $false
            } #it

            It 'Should return false when there are consecutive Assistant tags' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $consecutiveAssistantTags
                $result | Should -Be $false
            } #it

            It 'Should return false when there is a malformed tag' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $malformedTag
                $result | Should -Be $false
            } #it

            It 'Should return false when there is an invalid tag type' {
                # Create a conversation with an invalid tag type
                $invalidTagType = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜InvalidForTest｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>'
                $result = Test-DeepSeekCustomConversation -CustomConversation $invalidTagType
                $result | Should -Be $false
            } #it

            It 'Should return false for an empty string' {
                { Test-DeepSeekCustomConversation -CustomConversation $emptyString } | Should -Throw
            } #it

            It 'Should throw an error for a null string' {
                { Test-DeepSeekCustomConversation -CustomConversation $nullString } | Should -Throw
            } #it
        } #context_Error

        Context 'Success' {
            BeforeEach {
                # Valid complete conversation with system prompt, user message, and assistant response
                $validCompleteConversation = '<｜begin_of_sentence｜>You are a helpful assistant.<｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>'

                # Valid conversation with multiple exchanges
                $validMultipleExchanges = '<｜begin_of_sentence｜>You are a helpful assistant.<｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜User｜>Can you explain why?<｜Assistant｜>Let''s break it down: 2 represents two units, and adding another two units gives us four units total. So, 2 + 2 = 4.<｜end_of_sentence｜><｜Assistant｜>'

                # Valid conversation without system prompt
                $validNoSystemPrompt = '<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜Assistant｜>2 + 2 equals 4.<｜end_of_sentence｜><｜Assistant｜>'

                # Minimal valid conversation
                $minimalValidConversation = '<｜begin_of_sentence｜><｜User｜>Hello<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>'
            } #beforeEach

            It 'Should return true for a valid complete conversation' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $validCompleteConversation
                $result | Should -Be $true
            } #it

            It 'Should return true for a valid conversation with multiple exchanges' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $validMultipleExchanges
                $result | Should -Be $true
            } #it

            It 'Should return true for a valid conversation without system prompt' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $validNoSystemPrompt
                $result | Should -Be $true
            } #it

            It 'Should return true for a minimal valid conversation' {
                $result = Test-DeepSeekCustomConversation -CustomConversation $minimalValidConversation
                $result | Should -Be $true
            } #it
        } #context_Success

    } #describe_Test-DeepSeekCustomConversation
} #inModule
