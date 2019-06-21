library(shiny)
ui <- fluidPage(
  titlePanel("CensusVis"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with information from 2010 US Census"),
      
      selectInput("var",
                  label = "Choose a variable to display",
                  choices = c("Percent White",
                              "Percent Black",
                              "Percent Hispanic",
                              "Percent Asian"),
                  selected = "Percent White"),
      
      sliderInput("range",
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0,100))
    ),
    
    mainPanel(
      textOutput("selected_var"),
      textOutput("selected_var_range")
    )
  )
)

server <- function(input, output){
  
  output$selected_var <- renderText({
    paste("You have selected", input$var)
  })
  
  output$selected_var_range <- renderText({
    paste("You have chosen a range from", input$range[1], "to", input$range[2]) 
  })
}

shinyApp(ui, server)