library(shiny)
library(ellmer)

# API Key
gemini_key <- Sys.getenv("gemini_api_key")

# Prompt setup
system_prompt_utm_1 <- paste(
  "Your task is to generate UTM parameters for tracking campaign performance.\n\n",
  "Please ensure that the UTM parameters adhere to the following guidelines:\n",
  "1. Follow industry best practices for constructing UTM parameters.\n",
  "2. Align with our internal naming conventions and formats.\n",
  "3. Conform to Google’s documentation for UTM parameters.\n\n",
  "Here is an example of correctly formed UTM parameters:\n",
  "utm_source=google&utm_medium=cpc&utm_campaign=spring_sale&utm_content=textlink&utm_term=spring_shoes\n\n",
  "You will be given a description about the campaign and a URL. Please provide:\n",
  "- A list of full UTM parameters\n",
  "- The full URL with UTM parameters\n",
  "- Each parameter in a table\n",
  "- A note on how to find this data in Google Analytics 4.\n\n",
  "utm_campaigns should always start with the marketing team and then snake_case the description.\n",
  "The 3 marketing teams are ad, el, acq.\n",
  "Example: utm_campaign=ad_spring_sale"
)

# gemini chat object

chat_gem_utm <- chat_google_gemini(
  api_key = gemini_key,
  system_prompt = system_prompt_utm_1,
  echo = "all"
)




# UI
ui <- fluidPage(
  titlePanel("UTM Generator (via Gemini + ellmer)"),
  sidebarLayout(
    sidebarPanel(
      textInput("url", "URL", placeholder = "https://example.com"),
      textAreaInput("description", "Campaign Description", rows = 4),
      selectInput("team", "Marketing Team", choices = c("ad", "el", "acq", "mktg"), selected = "ad"),
      actionButton("generate", "Generate UTM")
    ),
    mainPanel(
      h4("Generated UTM Output"),
      verbatimTextOutput("utm_output")
    )
  )
)

# Server
server <- function(input, output, session) {
  utm_result <- eventReactive(input$generate, {
    req(input$url, input$description, input$team)
    
    prompt_utm <- paste(
      "The marketing team is", input$team, ".",
      "The URL is", input$url,
      "and the campaign description is",
      input$description
    )
    
    response <- chat_gem_utm$chat(prompt_utm)
    return(response)
  })
  
  output$utm_output <- renderText({
    utm_result()
  })
}

shinyApp(ui = ui, server = server)