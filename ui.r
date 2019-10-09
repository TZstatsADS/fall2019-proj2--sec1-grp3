library(shiny)
library(leaflet)
library(ggplot2)
# Define UI for application that draws a histogram



navbarPage("Tourist Recommendations",
           ######Page 1 ##################
           
           tabPanel("Cultural Centers and Restaurants",
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 20px; right: 0; bottom: 0; overflow: hidden; padding: 0; opacity: 0.92}"),
                        leafletOutput("map1",height = 800, width = 'auto'),
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = 10, right = 40, bottom = "auto",
                                      width = 300, height = "auto", h3("Please Specify:"),
                                      selectInput("Centers", label = h4("Centers"), 
                                                  choices = list("All Cultural Centers",
                                                                 "Museum",
                                                                 "Music", 
                                                                 "Theater",
                                                                 "Visual Arts"), selected = "All Days"),
                                      selectInput("Rest_sel", label = h4("Restaurants"), 
                                                  choices = list("All Cuisines",
                                                                 "American", 
                                                                 "Chinese",
                                                                 "Healthy",
                                                                 "Indian",
                                                                 "Italian",
                                                                 "Japanese",
                                                                 "Korean",
                                                                 "Mexican",
                                                                 "Pizza",
                                                                 "Seafood",
                                                                 "Thai",
                                                                 "Vietnamese"), selected = "All Days"),
                                      #sliderInput("Price", "$/night", label = "What is your nightly price range?",
                                      #            min = 0, max = 500, value = 100, step=1)
                        ))),
           tabPanel("Dining Options",
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 20px; right: 0; bottom: 0; overflow: hidden; padding: 0; opacity: 0.92}"),
                        leafletOutput("page_map",height = 800, width = 'auto'),
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 50, left = 0, right = 40, bottom = "auto",
                                      width = 300, height = "auto", h3("Select:"),
                                      checkboxInput("rest_checkbox", label = "View Restauraunts", 
                                                    value = TRUE),
                                      checkboxInput("cult_checkbox", label = "View Cultural Centers?", 
                                                    value = TRUE),
                                      selectInput("Cuisine", label = h4("Cuisine"), 
                                                  choices = list("All Cuisine",
                                                                 "American", "Mexican", "Chinese", "Korean", "Japanese",
                                                                 "Italian", "Vietnamese", "Healthy", "Pizza", "Thai"), selected = "All Days"),
                                      
                                      selectInput("Centers", label = h4("Centers"), 
                                                  choices = list("All Cultural Centers",
                                                                 "Music", 
                                                                 "Theater",
                                                                 "Visual Arts", "Museum"), selected = "All Days")
                        ))),
           ######Page 2 ##################
           tabPanel("Customization",
                    
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 20px; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                        leafletOutput("mymap2",height = 800, width = 'auto'),
                        
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
                                      
                                      sliderInput("price_range", label = h4("Price($/night)"),
                                                  min = 0, max = 1000, value = c(0, 300)),
                                      selectInput("Room_Type", label = h4("Room Type"), 
                                                  choices = list("None Selected",
                                                                 "All Types", 
                                                                 "Entire home/apt", 
                                                                 "Private room",
                                                                 "Shared room"
                                                  ), selected = "None Selected"),
                                      selectInput("night", label = h4("Nights to stay"), 
                                                  choices = list("1 night",
                                                                 "Weekend", 
                                                                 "10 nights", 
                                                                 "30 nights",
                                                                 "Long stay: > 50 nights"
                                                  ), selected = "Weekend")                                     
                                      #            sliderInput("rating_range", label = h4("Rating"),
                                      #                       min = 0, max = 1, value = c(0, 0.8))
                        ))), 
           
           tabPanel("Contact",fluidPage(
             sidebarLayout(
               sidebarPanel(h1("Contact Information")),
               mainPanel(
                 # only the last output works
                 
                 hr(),
                 h1(("If you are interested in our project, please contact us.")),
                 hr(),
                 h5(("Xiwen Chen")),
                 h5(("xc2463@columbia.edu")),
                 h5(("Daniel Weiss")),
                 h5(("dmw2180@columbia.edu")),
                 h5(("Nichole Yao")),
                 h5(("yy2860@columbia.edu")),
                 h5(("Justine Zhang")),
                 h5(("yz3420@columbia.edu")),
                 h5(("Jerry Zhang")),
                 h5(("jz2966@columbia.edu"))))
           ))
           
)