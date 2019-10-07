library(shiny)
library(leaflet)
library(ggplot2)
# Define UI for application that draws a histogram



navbarPage("Airbnb Shiny App Project",
           ######Page 1 ##################
           
           tabPanel("page 1",
                    
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 20px; right: 0; bottom: 0; overflow: hidden; padding: 0; opacity: 0.92}"),
                        
                        
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
           
           tabPanel("page 2",
                    leafletOutput("mymap2",height = 800, width = 'auto'),
                    
                    ####### INSERT CONTENT HERE ###########
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 20px; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                        
                        
                        absolutePanel(id = "controls", class = "panel panel-default",
                                      style="padding: 0 20px 20px 20px;",
                                      style = "opacity: 0.75",
                                      fixed = TRUE,
                                      draggable = TRUE, top = 50, left = 0, right = 40, bottom = "auto",
                                      width = 330, height = "auto", h3("Select:"),
                                      selectInput("Neighbor", label = h4("Neighborhoods"), 
                                                  choices = list("None Selected",
                                                                 "All Neighborhoods", 
                                                                 "Bronx", 
                                                                 "Brooklyn",
                                                                 "Manhattan", 
                                                                 "Queens",
                                                                 "Staten Island"), selected = "None Selected"),
                                      
                                      sliderInput("price_range", label = "Price:",
                                                  min = 0, max = 1000, value = c(100, 400)),
                                      selectInput("Room_Type", label = h4("Room Type"), 
                                                  choices = list("None Selected",
                                                                 "All Types", 
                                                                 "Entire home/apt", 
                                                                 "Private room",
                                                                 "Shared room"
                                                  ), selected = "None Selected")
                                      
                                      
                                      
                                      
                        )
                        
                        
                        
                    )
                    
                    #######################################
           )
           
           
           
           
           
           
           
)