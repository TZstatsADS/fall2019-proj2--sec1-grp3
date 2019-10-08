### INSERT DEPENDENCIES

library(shiny)
library(choroplethr)
library(dplyr)
library(leaflet)
library(maps)
library(rgdal)
library(tigris)
library(geojsonio)


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
  
  ##
  
  
  output$page_map <- renderLeaflet({
    map_load2 <-  rest_cult_data # %>% filter(Discipline == 'Music')
    leaflet(map_load2) %>% addTiles()%>% addProviderTiles("CartoDB.Positron")%>% addCircles(lng = ~Longitude, lat = ~Latitude)
    
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



