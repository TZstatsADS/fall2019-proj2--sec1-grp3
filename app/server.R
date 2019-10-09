### INSERT DEPENDENCIES

library(shiny)
library(choroplethr)
library(dplyr)
library(leaflet)
library(maps)
library(rgdal)
library(tigris)
library(geojsonio)
library(hash)
library(leaflet.extras)


## LOAD DATA
## Page1
orig_cultural_data <-read.csv("CultureCenter.csv")
delete_cult_name <- c('State', 'City', 'Main.Phone..', 'Council.District', 'Census.Tract', 'BIN', 'BBL', 'NTA')
processed_cult_data <- orig_cultural_data[,!(names(orig_cultural_data) %in% delete_cult_name)]

## Page2
listings_data <- read.csv("listings_new.csv", header=TRUE, sep=",")
load('nyc_nbhd.RData')
bins <- c(80, 100, 120, 140, 160, 180,200)
bound<- geojsonio::geojson_read("Borough Boundaries.geojson", what = "sp")
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

########### PAGE 1 SCRIPTS ###############

rest_cult_data <-read.csv("../data/rest_and_cult_data.csv")
rest_data <- read.csv("../data/rest_data.csv")
cult_data <- read.csv("../data/cult_data.csv")

popup_rest = paste0('<strong>Name: </strong><br>', rest_data$Name, 
                    '<br><strong>Cuisine:</strong><br>', rest_data$Type,
                    '<br><strong>Yelp Rating:</strong><br>', rest_data$Rating,
                    '<br><strong>Address:</strong><br>', rest_data$Address)
popup_cult = paste0('<strong>Name: </strong><br>', cult_data$Name, 
                    '<br><strong>Type:</strong><br>', cult_data$Type,
                    '<br><strong>Address:</strong><br>', cult_data$Address)

cuis_opts <- c("All Cuisine",
             "American", "Mexican", "Chinese", "Korean", "Japanese",
             "Italian", "Vietnamese", "Healthy", "Pizza", "Thai")

rest_colors <- colorFactor("Set3",cuis_opts )

cult_opts <- c("All Cultural Centers",
               "Music", 
               "Theater",
               "Visual Arts", "Museum")

cult_colors <- colorFactor("Pastel1",cult_opts )


########### PAGE 2 SCRIPTS ###############

delete_name <- c('host_id', "host_name", "last_review", "reviews_per_month", 
                 "calculated_host_listings_count", "availability_365" )
listings <- listings_data[,!(names(listings_data) %in% delete_name)]
listings$room_size <- NA
listings<- listings %>% filter(rating > 0)
listings <- listings%>%
  mutate(room_size = ifelse(grepl('Entire', listings$room_type),10,
                            ifelse(grepl('Private', listings$room_type),5,
                                   ifelse(grepl('Shared', listings$room_type),3,room_size))))
nei_groups<- levels(listings$neighbourhood_group)
palc <- colorFactor(c("#FEB24C","#e7152a","#2766c9"), c(3,5,10))

long <- function(area){
  if(area == "Bronx"){
    return(-73.86641)
  }else if(area == "Brooklyn"){
    return(-73.949997)
  }else if(area == "Staten Island"){
    return(-74.151535)
  }else if(area == "Queens"){
    return(-73.769417)
  }else{
    return(-73.9808)
  }
}

lat <- function(area){
  if(area == "Bronx"){
    return(40.84985)
  }else if(area == "Brooklyn"){
    return(40.650002)
  }else if(area == "Staten Island"){
    return(40.579021)
  }else if(area == "Queens"){
    return(40.742054)
  }else{
    return(40.7648)
  }
}

zoom <- function(area){
  if(area == "All Neighborhoods"||area == "None Selected"){
    return(10)
  }else
    return(15)
}

mean_list <- c(1,2,3,4,5)
for(i in 1:length(nei_groups)){
  mean<- listings%>%filter(neighbourhood_group==nei_groups[i])%>%select(price)%>%summarise(mean(price))
  mean_list[i] <- mean[1,1]
}
h_2 <- data.frame("Neighbor" =nei_groups, "PriceMean" = mean_list)
borough_price <- geo_join(bound, h_2,"boro_name","Neighbor")
bins <- c(80, 100, 120, 140, 160, 180,200)
palc_price <- colorBin("YlOrRd", domain = borough_price$PriceMean, bins = bins)


labels <- sprintf(
  "Neighborhood: <strong>%s</strong><br/>Average Price: <strong>$%g/yr<sup></sup></strong>",
  borough_price$boro_name, borough_price$PriceMean
) %>% lapply(htmltools::HTML)

popup1 = paste0('<strong>Price($/night): </strong><br>', listings$price, 
                '<br><strong>Number of Reviews:</strong><br>', listings$number_of_reviews,
                '<br><strong>Airbnb URL:</strong><br>', listings$listing_url)



##########################################
shinyServer(function(input, output) {
  ## Panel 1: leaflet
  output$map1 <- renderLeaflet({
    map_load <-  processed_cult_data # %>% filter(Discipline == 'Music')
    
    #if (input$Centers )
    leaflet(map_load) %>% addTiles()%>% addProviderTiles("CartoDB.Positron")%>% addCircles(lng = ~Longitude, lat = ~Latitude)
    
  })
  
  ###########
  
  map_load2 <-  rbind(rest_data,cult_data)
  

  output$page_map <- renderLeaflet({
    
    if (input$Cuisine == 'American'){
      rest_data <- rest_data %>% filter(Type == 'american')
    }
    else if (input$Cuisine == 'Chinese'){
      rest_data <- rest_data %>% filter(Type == 'chinese')
    }
    else if (input$Cuisine == 'Korean'){
      rest_data <- rest_data %>% filter(Type == 'korean')
    }
    else if (input$Cuisine == 'Vietnamese'){
      rest_data <- rest_data %>% filter(Type == 'vietnamese')
    }
    else if (input$Cuisine == 'Pizza'){
      rest_data <- rest_data %>% filter(Type == 'pizza')
    }
    else if (input$Cuisine == 'Mexican'){
      rest_data <- rest_data %>% filter(Type == 'mexican')
    }
    else if (input$Cuisine == 'Japanese'){
      rest_data <- rest_data %>% filter(Type == 'japanese')
    }
    else if (input$Cuisine == 'Healthy'){
      rest_data <- rest_data %>% filter(Type == 'healthy')
    }
    else if (input$Cuisine == 'Italian'){
      rest_data <- rest_data %>% filter(Type == 'italian')
    }
    else if (input$Cuisine == 'Thai'){
      rest_data <- rest_data %>% filter(Type == 'thai')
    }
    
    if (input$Centers == 'Music'){
      cult_data <- cult_data %>% filter(Type == 'Music')
    }
    else if (input$Centers == 'Museum'){
      cult_data <- cult_data %>% filter(Type == 'Museum')
    }
    else if (input$Centers == 'Theater'){
      cult_data <- cult_data %>% filter(Type == 'Theater')
    }
    else if (input$Centers == 'Visual Arts'){
      cult_data <- cult_data %>% filter(Type == 'Visual Arts')
    }
    
    
    
    
    output$yelp_slider <- renderPrint({ input$yelp_slider })
    rest_data <- rest_data %>% filter(Rating >= input$yelp_slider[1])
    rest_data <- rest_data %>% filter(Rating <= input$yelp_slider[2])
    
    ~rest_colors(input$Cuisine)
    ~cult_colors(input$Centers)
    
    map_load2 <-  rbind(rest_data,cult_data)
    
    
    if (input$heatmap==FALSE){
      if (input$rest_checkbox == TRUE && input$cult_checkbox == FALSE) {
        leaflet(rest_data) %>%
          addTiles() %>%addProviderTiles("CartoDB.Positron") %>%
          addCircleMarkers(data = rest_data,
                           color = ~rest_colors(input$Cuisine), popup = popup_rest,
                           opacity = 0.5, radius = 0.5)
        
      }
      
      else if (input$cult_checkbox == TRUE && input$rest_checkbox == FALSE) {
        leaflet(cult_data) %>%
          addTiles() %>%addProviderTiles("CartoDB.Positron") %>%
          addCircleMarkers(data = cult_data,
                           color = ~cult_colors(input$Centers), popup = popup_cult,
                           opacity = 0.5, radius = 0.5)
        
      }  
      
      else {
        
        FILE1 <- rest_data
        FILE2 <- cult_data
        
        leaflet(rbind(FILE1, FILE2)) %>%
          addTiles() %>%addProviderTiles("CartoDB.Positron") %>%
          addCircleMarkers(data = FILE1,
                           color = ~rest_colors(input$Cuisine), popup = popup_rest,
                           opacity = 0.5, radius = 0.5) %>%
          addCircleMarkers(data = FILE2,
                           color = ~cult_colors(input$Centers), popup = popup_cult,
                           opacity = 0.5, radius = 0.5)
        
      }
    }
    else{
      if (input$rest_checkbox == TRUE && input$cult_checkbox == FALSE) {
        leaflet(rest_data) %>%
          addTiles()%>% addProviderTiles("CartoDB.Positron")%>%
          addWebGLHeatmap(opacity = 0.9,size=600)
      }
      else if (input$cult_checkbox == TRUE && input$rest_checkbox == FALSE) {
        leaflet(cult_data) %>%
          addTiles()%>% addProviderTiles("CartoDB.Positron")%>%
          addWebGLHeatmap(opacity = 0.9,size=600)
      }
      else {
        
        
        leaflet(rbind(rest_data, cult_data)) %>%
          addTiles()%>% addProviderTiles("CartoDB.Positron")%>%
          addWebGLHeatmap(opacity = 0.9,size=600)
      }
      
      
      
      
    }
    
    
    
    
    
    #leaflet(map_load2) %>% addTiles()%>% addProviderTiles("CartoDB.Positron")%>% addCircles(lng = ~Longitude, lat = ~Latitude)

  })
  
  
  ## Panel 2: leaflet
  output$mymap2 <- renderLeaflet({
    h <- listings
    if(input$Neighbor =="None Selected" & input$Room_Type=="None Selected"){
      h <- NULL
    }
    if (input$Neighbor != 'All Neighborhoods') 
    {h<- listings %>% filter(neighbourhood_group == input$Neighbor)}
    
    if (input$Room_Type != 'All Types')
    {h <- h %>% filter(room_type == input$Room_Type)}
    
    h <- h %>% filter(price > input$price_range[1] && price<input$price_range[2])
    
    if (input$night == '1 night') 
    {h<- h %>% filter(minimum_nights<=1)}
    else if (input$night == 'Weekend')
    {h<- h %>% filter(minimum_nights<=3)}
    else if (input$night == '10 nights')
    {h<- h %>% filter(minimum_nights<=10)}  
    else if (input$night == '30 nights')
    {h<- h %>% filter(minimum_nights<=30)}   
    
    h <- h %>% filter(rating >= input$rating_range)
    
    
    if(input$Neighbor =="None Selected" & input$Room_Type=="None Selected"){
      leaflet(borough_price) %>%
        addTiles()%>%
        addPolygons(fillColor = ~palc_price(PriceMean),
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    dashArray = "3",
                    fillOpacity = 0.7,
                    highlight = highlightOptions(
                      weight = 5,
                      color = "#666",
                      dashArray = "",
                      fillOpacity = 0.7,
                      bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "3px 8px"),
                      textsize = "15px",
                      direction = "auto"))%>%
        addProviderTiles("CartoDB.Positron")%>%
        addLegend(position = "topright",values = ~PriceMean, pal = palc_price , opacity = 1)
    } else if (input$Neighbor != "None Selected" & input$Room_Type=="All Types"){     
      leaflet(h) %>%
        setView(long(input$Neighbor), lat(input$Neighbor), zoom(input$Neighbor))%>%
        addProviderTiles("CartoDB.Positron") %>%
        addCircles(lng = ~longitude, lat = ~latitude, radius = ~room_size, color = ~palc(room_size), stroke = T)%>%
        addLegend(position = "topright",
                  colors = c("#FEB24C","#e7152a","#2766c9"),
                  labels = c('Shared Room','Private Room','Entire Home'),
                  opacity = 0.6,
                  title = 'Room Type')}else{leaflet(h) %>%
                      setView(long(input$Neighbor), lat(input$Neighbor), zoom(input$Neighbor))%>%
                      addProviderTiles("CartoDB.Positron") %>%
                      addCircles(lng = ~longitude, lat = ~latitude, popup = popup1, radius = ~room_size, color = ~palc(room_size), stroke = T)
                    
                  }    
  })
})

