library(rvest)
library(tidyverse)
library(stringr)
library(purrr)
library(scales)
library(ggplot2)
library(numbers)
library(textreuse) 
library(kableExtra)
library(shiny)
library(DT)

source("links.R")

ui <- fluidPage(
  # current time
  h5(textOutput("current_time")),
  
  textOutput("artist_summary"),
  
  # app title
  titlePanel(" Similar Sounding Songs"),

  DT::dataTableOutput("mytable"),
  
  sidebarLayout(
    
    # sidebar panels for inputs
    sidebarPanel(
      textInput(inputId = "artist",
                label = "Artist:")
      ),
    mainPanel(
      
      # artist name
      h3(textOutput("artist", container = span))
    )
  )
)


server <- function(input, output, session){
  
  # display current time
  output$current_time <- renderText({
    invalidateLater(1000, session)
    paste(Sys.time())
  })
  
  output$mytable <- DT::renderDataTable({
    get_links(input$artist)
  })
}

shinyApp(ui, server)