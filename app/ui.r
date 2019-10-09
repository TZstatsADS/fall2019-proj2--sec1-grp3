
library(shiny)
library(leaflet)
library(ggplot2)
# Define UI for application that draws a histogram



navbarPage("Airbnb Recommendation",
           ######Page 1 ##################
           
           tabPanel("Dining + Activities",
                    div(class="outer",
                        tags$style(".outer {position: fixed; top: 41px; left: 20px; right: 0; bottom: 0; overflow: hidden; padding: 0; opacity: 0.92}"),
                        leafletOutput("page_map",height = 800, width = 'auto'),
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,style="padding: 0 20px 20px 20px;",
                                      style = "opacity: 0.75",
                                      draggable = TRUE, top = 50, left = 0, right = 40, bottom = "auto",
                                      width = 330, height = "auto", h3("Select:"),
                                      checkboxInput("rest_checkbox", label = "View Restauraunts", 
                                                    value = TRUE),
                                      
                                      selectInput("Cuisine", label = h4("Cuisine"), 
                                                  choices = list("All Cuisine",
                                                                 "American", "Mexican", "Chinese", "Korean", "Japanese",
                                                                 "Italian", "Vietnamese", "Healthy", "Pizza", "Thai"), selected = "All Cuisine"),
                                      sliderInput("yelp_slider", label = h4("Yelp Rating"),
                                                  min = 1, max = 5, value = c(3, 4)),
                                      
                                      checkboxInput("cult_checkbox", label = "View Cultural Centers?", 
                                                    value = TRUE),
                                      
                                      selectInput("Centers", label = h4("Centers"), 
                                                  choices = list("All Cultural Centers",
                                                                 "Music", 
                                                                 "Theater",
                                                                 "Visual Arts", "Museum"), selected = "All Cultural Centers"),
                                      
                                      checkboxInput("heatmap", label = h5("Heatmap: "), value= FALSE)
                        ))),
           
           ######Page 2 ##################
           tabPanel("Housing",
                    
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
                                                  ), selected = "Weekend"),                                     
                                      sliderInput("rating_range", label = h4("Rating"),
                                                  min = 0, max = 1, value = 0.8)
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