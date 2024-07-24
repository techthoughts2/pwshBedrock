# pwshBedrock - Advanced

-------------------

*Consider exploring the [pwshBedrock Basics](pwshBedrock-Basics.md) page first to gain a comprehensive understanding of the tool and its features before proceeding to the advanced page. This page is designed for users with prior experience with pwshBedrock who are interested in exploring its advanced capabilities.*

-------------------

## Tool Use with pwshBedrock

`pwshBedrock` supports tool usage, also known as function calling, with models that support this feature. This allows a model to request the use of an external tool to generate a response for a message. For a detailed overview, refer to the [Tool Use (function calling) AWS documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html).

At a high level, here's how it works:

1. **Defining the Tool**: By providing a PowerShell object that defines the tool, you can pass this to the model. The definition includes how the tool can help the model generate a response.

2. **ToolResponse**: When you send a message to the model, the model may respond with a `ToolResponse`, indicating that it needs to use the tool to generate a response. This response includes the input parameters needed to call the tool.

3. **Calling the Tool**: Based on the `ToolResponse`, you need to independently call the tool using the provided parameters. This could be an API, database query, Lambda function, or any other software implementation.

4. **Returning the ToolResult**: Once you have the result from the tool, you continue the conversation with the model by supplying the result as a `ToolResult`. This allows the model to include the tool's output in its final response.

`pwshBedrock` supports this workflow with Converse and the following direct models:

- Anthropic Claude 3 models
- Mistral AI Mistral Large and Mistral Small
- Cohere Command R and Command R+

**Example Workflow:**

1. **Defining the Tool**:

    ```powershell
    $toolDefinition = @(
        [PSCustomObject]@{
            name         = 'PopularSong'
            description  = 'Returns the most popular song for a specified radio station'
            input_schema = [PSCustomObject]@{
                type       = 'object'
                properties = [PSCustomObject]@{
                    Station = [PSCustomObject]@{
                        type        = 'string'
                        description = 'Radio station name.'
                    }
                }
                required   = @( 'Station' )
            }
        }
    )
    ```

2. **Sending the Message**:

    ```powershell
    $invokeAnthropicModelSplat = @{
        Message          = 'What is the most popular song on the radio station "KISS FM"?'
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        ReturnFullObject = $true
        Tools            = $toolDefinition
        ToolChoice       = 'tool'
        ToolName         = 'PopularSong'
        Credential       = $awsCredential
        Region           = 'us-west-2'
    }
    $response = Invoke-AnthropicModel @invokeAnthropicModelSplat
    ```

3. **Handling the ToolResponse**:

    ```powershell
    $station = $response.content.input.Station
    # Call the tool independently (e.g., API call to get the most popular song)
    $song = Get-MostPopularSong -Station $station

    # Return the ToolResult
    $toolResult = @(
        [PSCustomObject]@{
            tool_use_id = $response.content.id
            content     = $song
        }
    )
    $invokeAnthropicModelSplat = @{
        ToolsResults     = $toolResult
        Tools            = $toolDefinition
        ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
        Credential       = $awsCredential
        Region           = 'us-west-2'
        ReturnFullObject = $true
    }
    $finalResponse = Invoke-AnthropicModel @invokeAnthropicModelSplat -Verbose -Debug
    ```

By supporting these steps, `pwshBedrock` makes it easy to engage with models using tools, manage tool responses, and handle tool results using native PowerShell objects. This streamlines the process and reduces the complexity involved in integrating external tools with Amazon Bedrock models.

### Full Working Tool Use Examples

#### Converse Tool Example

```powershell
#------------------------------------------------------------------------------------------------
# declare the tool configuration
$toolConfig = [PSCustomObject]@{
    Name        = 'restaurant'
    Description = 'This tool will look up restaurant information in a provided geographic area.'
    Properties  = @{
        location = [PSCustomObject]@{
            type        = 'string'
            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
        }
        cuisine  = [PSCustomObject]@{
            type        = 'string'
            description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
        }
        budget   = [PSCustomObject]@{
            type        = 'string'
            description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
        }
        rating   = [PSCustomObject]@{
            type        = 'string'
            description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
        }
    }
    required    = @(
        'location'
    )
}
#------------------------------------------------------------------------------------------------
# make a call using the Converse API to the Anthropic model to get a restaurant recommendation and pass in the tool configuration
$invokeConverseAPISplat = @{
    Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
    ModelID          = 'mistral.mistral-large-2402-v1:0'
    SystemPrompt     = 'You are a savvy foodie who loves giving restaurant recommendations.'
    ReturnFullObject = $true
    Tools            = $toolConfig
    # ToolChoice       = 'tool'
    # ToolName         = 'restaurant'
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$response = Invoke-ConverseAPI @invokeConverseAPISplat

# $toolParametersJson = $response.Output.Message.Content.ToolUse.Input.AsDictionary() | ConvertTo-Json
# $toolParameters = $toolParametersJson | ConvertFrom-Json
# $location = $toolParameters.location
#------------------------------------------------------------------------------------------------
# use the ToolsResponse from Converse to look up restaurant information using the tool
$dictionaryToolUseInput = $response.Output.Message.Content.ToolUse.Input.AsDictionary()
$location = $dictionaryToolUseInput['location'].ToString()

$invokeGMapGeoCodeSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Address      = $location
}
$localInfo = Invoke-GMapGeoCode @invokeGMapGeoCodeSplat

$searchGMapNearbyPlaceSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Latitude     = $localInfo.Latitude
    Longitude    = $localInfo.Longitude
    Radius       = 5000
    Type         = "restaurant"

}
if ($arguments.cuisine) {
    $searchGMapNearbyPlaceSplat.Add('Keyword', $arguments.cuisine)
}

$restaurantQuery = Search-GMapNearbyPlace @searchGMapNearbyPlaceSplat

$results = $restaurantQuery | Select-Object -Property name, rating, price_level, Open
$topResult = $results | Sort-Object -Property rating -Descending | Select-Object -First 1
#------------------------------------------------------------------------------------------------
# format the tool response and send it back to the Converse API
$toolResult = [PSCustomObject]@{
    ToolUseId = $response.Output.Message.Content.ToolUse.ToolUseId
    Content   = [PSCustomObject]@{
        restaurant = $topResult
    }
    status    = 'success'
}

$invokeConverseAPISplat = @{
    ToolsResults     = $toolResult
    ModelID          = 'mistral.mistral-large-2402-v1:0'
    ReturnFullObject = $true
    Tools            = $toolConfig
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$finalResponse = Invoke-ConverseAPI @invokeConverseAPISplat
$finalResponse.Output.Message.Content
#------------------------------------------------------------------------------------------------
```

#### Anthropic Model Tool Example

```powershell
#------------------------------------------------------------------------------------------------
# declare the tool configuration
$toolConfig = @(
    [PSCustomObject]@{
        name         = 'restaurant'
        description  = 'This tool will look up restaurant information in a provided geographic area.'
        input_schema = [PSCustomObject]@{
            type       = 'object'
            properties = [PSCustomObject]@{
                location = [PSCustomObject]@{
                    type        = 'string'
                    description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                }
                cuisine  = [PSCustomObject]@{
                    type        = 'string'
                    description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
                }
                budget   = [PSCustomObject]@{
                    type        = 'string'
                    description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
                }
                rating   = [PSCustomObject]@{
                    type        = 'string'
                    description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
                }
            }
            required   = @( 'location' )
        }
    }
)
#------------------------------------------------------------------------------------------------
# make a call to the Anthropic model to get a restaurant recommendation and pass in the tool configuration
$invokeAnthropicModelSplat = @{
    Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    SystemPrompt     = 'You are a savvy foodie who loves giving restaurant recommendations.'
    ReturnFullObject = $true
    Tools            = $toolConfig
    ToolChoice       = 'tool'
    ToolName         = 'restaurant'
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$response = Invoke-AnthropicModel @invokeAnthropicModelSplat
#------------------------------------------------------------------------------------------------
# use the ToolsResponse from the Anthropic model to look up restaurant information using the tool
Import-Module -Name pwshPlaces
$invokeGMapGeoCodeSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Address      = $response.content.input.location
}
$localInfo = Invoke-GMapGeoCode @invokeGMapGeoCodeSplat

$searchGMapNearbyPlaceSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Latitude     = $localInfo.Latitude
    Longitude    = $localInfo.Longitude
    Radius       = 5000
    Type         = "restaurant"

}
if ($arguments.cuisine) {
    $searchGMapNearbyPlaceSplat.Add('Keyword', $arguments.cuisine)
}

$restaurantQuery = Search-GMapNearbyPlace @searchGMapNearbyPlaceSplat

$results = $restaurantQuery | Select-Object -Property name, rating, price_level, Open
$topResult = $results | Sort-Object -Property rating -Descending | Select-Object -First 1
#------------------------------------------------------------------------------------------------
# format the tool response and send it back to the Anthropic model
$toolConfigResults = @(
    [PSCustomObject]@{
        tool_use_id = $response.content.id
        content     = $topResult
    }
)
$invokeAnthropicModelSplat = @{
    ToolsResults     = $toolConfigResults
    Tools            = $toolConfig
    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
    Credential       = $awsCredential
    Region           = 'us-west-2'
    ReturnFullObject = $true
}
$finalResponse = Invoke-AnthropicModel @invokeAnthropicModelSplat
$finalResponse
#------------------------------------------------------------------------------------------------
```

#### Cohere Command R/R+ Tool Example

```powershell
#------------------------------------------------------------------------------------------------
# declare the tool configuration
$toolConfig = @(
    [PSCustomObject]@{
        name                  = 'restaurant'
        description           = 'This tool will look up restaurant information in a provided geographic area.'
        parameter_definitions = @{
            'location' = [PSCustomObject]@{
                description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                type        = 'string'
                required    = $true
            }
            'cuisine'  = [PSCustomObject]@{
                description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
                type        = 'string'
                required    = $false
            }
            'budget'   = [PSCustomObject]@{
                description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
                type        = 'string'
                required    = $false
            }
            'rating'   = [PSCustomObject]@{
                description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
                type        = 'string'
                required    = $false
            }
        }
    }
)
#------------------------------------------------------------------------------------------------
# make a call using the Cohere Command R/R+ model to get a restaurant recommendation and pass in the tool configuration
$invokeCohereCommandRModelSplat = @{
    Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
    ModelID          = 'cohere.command-r-plus-v1:0'
    Preamble         = 'You are a savvy foodie who loves giving restaurant recommendations.'
    ReturnFullObject = $true
    Tools            = $toolConfig
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$response = Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
#------------------------------------------------------------------------------------------------
# use the ToolsResponse from Cohere model to look up restaurant information using the tool
$invokeGMapGeoCodeSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Address      = $response.chat_history.tool_calls.parameters.location
}
$localInfo = Invoke-GMapGeoCode @invokeGMapGeoCodeSplat

$searchGMapNearbyPlaceSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Latitude     = $localInfo.Latitude
    Longitude    = $localInfo.Longitude
    Radius       = 5000
    Type         = "restaurant"

}
if ($arguments.cuisine) {
    $searchGMapNearbyPlaceSplat.Add('Keyword', $arguments.cuisine)
}

$restaurantQuery = Search-GMapNearbyPlace @searchGMapNearbyPlaceSplat

$results = $restaurantQuery | Select-Object -Property name, rating, price_level, Open
$topResult = $results | Sort-Object -Property rating -Descending | Select-Object -First 1
#------------------------------------------------------------------------------------------------
# format the tool response and send it back to the Cohere model
$toolResult = @(
    [PSCustomObject]@{
        call    = [PSCustomObject]@{
            name          = "top_restaurant"
            parameters    = [PSCustomObject]@{
                'location' = $response.chat_history.tool_calls.parameters.location
            }
            generation_id = $response.generation_id
        }
        outputs = @(
            $topResult
        )
    }
)
$invokeAmazonTextModelSplat = @{
    ModelID          = 'cohere.command-r-plus-v1:0'
    Preamble         = 'You are a savvy foodie who loves giving restaurant recommendations.'
    ReturnFullObject = $true
    Tools            = $toolConfig
    ToolsResults     = $toolResult
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$finalResponse = Invoke-CohereCommandRModel @invokeAmazonTextModelSplat
$finalResponse
#------------------------------------------------------------------------------------------------
```

#### Mistral AI Tool Example

```powershell
#------------------------------------------------------------------------------------------------
# make a call using the Mistral AI Chat model to get a restaurant recommendation and pass in the tool configuration
$invokeMistralAIChatModelSplat = @{
    Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
    ModelID          = 'mistral.mistral-large-2402-v1:0'
    SystemPrompt     = 'You are a savvy foodie who loves giving restaurant recommendations.'
    ReturnFullObject = $true
    Tools            = [PSCustomObject]@{
        type     = 'function'
        function = @{
            name        = 'restaurant'
            description = 'This tool will look up restaurant information in a provided geographic area.'
            parameters  = @{
                type       = 'object'
                properties = @{
                    location = @{
                        type        = 'string'
                        description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                    }
                    cuisine  = @{
                        type        = 'string'
                        description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
                    }
                    budget   = @{
                        type        = 'string'
                        description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
                    }
                    rating   = @{
                        type        = 'string'
                        description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
                    }
                }
                required   = @('location')
            }
        }
    }
    Credential       = $awsCredential
    Region           = 'us-west-2'
}
$response = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
#------------------------------------------------------------------------------------------------
# use the ToolsResponse from Mistral AI model to look up restaurant information using the tool
$id = $response.choices.message.tool_calls.id
$arguments = $response.choices.message.tool_calls.function.arguments | ConvertFrom-Json

$invokeGMapGeoCodeSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Address      = $arguments.location
}
$localInfo = Invoke-GMapGeoCode @invokeGMapGeoCodeSplat


$searchGMapNearbyPlaceSplat = @{
    GoogleAPIKey = $GoogleAPIKey
    Latitude     = $localInfo.Latitude
    Longitude    = $localInfo.Longitude
    Radius       = 5000
    Type         = "restaurant"

}
if ($arguments.cuisine) {
    $searchGMapNearbyPlaceSplat.Add('Keyword', $arguments.cuisine)
}

$restaurantQuery = Search-GMapNearbyPlace @searchGMapNearbyPlaceSplat

$results = $restaurantQuery | Select-Object -Property name, rating, price_level, Open
$topResult = $results | Sort-Object -Property rating -Descending | Select-Object -First 1
#------------------------------------------------------------------------------------------------
# format the tool response and send it back to the Mistral AI model
$toolResult = [PSCustomObject]@{
    role         = 'tool'
    tool_call_id = $id
    content      = $topResult
}
$invokeMistralAIChatModelSplat = @{
    ToolsResults     = $toolResult
    # ToolsResults     = $obj
    ModelID          = 'mistral.mistral-large-2402-v1:0'
    ReturnFullObject = $true
    Credential       = $awsCredential
    Region           = 'us-west-2'
    Verbose          = $false

}
$finalResponse = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
$finalResponse.choices[0].message
#------------------------------------------------------------------------------------------------
```
