library(shiny)
library(leaflet)
library(ggplot2)
# Define UI for application that draws a histogram



navbarPage("Airbnb Shiny App Project",
           ######Page 1 ##################
           
           tabPanel("page 1",
                    
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                        #leafletOutput("map", width = "100%", height = "100%"), 
                        #^^^ uncomment this line to load MAP in the UI; will work when leaflet in the server.R is fixed
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 50, left = 0, right = 40, bottom = "auto",
                                      width = 300, height = "auto", h3("Please Specify:"),
                                      selectInput("Neighborhoods", label = h4("Neighborhoods"), 
                                                  choices = list("all neighborhoods", "Central Harlem", 
                                                                 "Chelsea and Clinton",
                                                                 "East Harlem", 
                                                                 "Gramercy Park and Murray Hill",
                                                                 "Greenwich Village and Soho", 
                                                                 "Lower Manhattan",
                                                                 "Lower East Side", 
                                                                 "Upper East Side", 
                                                                 "Upper West Side",
                                                                 "Inwood and Washington Heights"), selected = "All Days"),
                                      
                                      sliderInput("Price", "$/night", label = "What is your nightly price range?",
                                                  min = 0, max = 500, value = 100, step=1)
                                      
                                      )
                        
                    
                        
                          
                        )

                    
                    
      
                    
                    
           ),
           
           tabPanel("page 2"
                    
                    ####### INSERT CONTENT HERE ###########
                    
                    
                    
                    
                    
                    
                    #######################################
                    )
           
           
           
           
           
           
           
)