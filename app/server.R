### INSERT DEPENDENCIES

library(shiny)
library(choroplethr)
#library(choroplethrZip)
library(dplyr)
library(leaflet)
library(maps)
library(rgdal)
library(tigris)
library(geojsonio)

#setwd("../app")
## Define Manhattan's neighborhood
man.nbhd=c("all neighborhoods", "Central Harlem", 
           "Chelsea and Clinton",
           "East Harlem", 
           "Gramercy Park and Murray Hill",
           "Greenwich Village and Soho", 
           "Lower Manhattan",
           "Lower East Side", 
           "Upper East Side", 
           "Upper West Side",
           "Inwood and Washington Heights")
zip.nbhd=as.list(1:length(man.nbhd))
zip.nbhd[[1]]=as.character(c(10026, 10027, 10030, 10037, 10039))
zip.nbhd[[2]]=as.character(c(10001, 10011, 10018, 10019, 10020))
zip.nbhd[[3]]=as.character(c(10036, 10029, 10035))
zip.nbhd[[4]]=as.character(c(10010, 10016, 10017, 10022))
zip.nbhd[[5]]=as.character(c(10012, 10013, 10014))
zip.nbhd[[6]]=as.character(c(10004, 10005, 10006, 10007, 10038, 10280))
zip.nbhd[[7]]=as.character(c(10002, 10003, 10009))
zip.nbhd[[8]]=as.character(c(10021, 10028, 10044, 10065, 10075, 10128))
zip.nbhd[[9]]=as.character(c(10023, 10024, 10025))
zip.nbhd[[10]]=as.character(c(10031, 10032, 10033, 10034, 10040))

## LOAD DATA
listings_data <- read.csv("../data/airbnb-open-data-in-nyc/listings.csv", header=TRUE, sep=",")
load('nyc_nbhd.RData')
bins <- c(80, 100, 120, 140, 160, 180,200)
bound<- geojsonio::geojson_read("Borough Boundaries.geojson", what = "sp")
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)
########### PAGE 1 SCRIPTS ###############








########### PAGE 2 SCRIPTS ###############
delete_name <- c('host_id', "host_name", "last_review", "reviews_per_month", 
                 "calculated_host_listings_count", "availability_365" )
listings <- listings_data[,!(names(listings_data) %in% delete_name)]
listings$room_size <- NA
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

##########################################
shinyServer(function(input, output) {
  ## Panel 3: leaflet
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

 #     h <- h %>% filter(rating > input$rating_range[1] && rating<input$rating_range[2])
      
      
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
        addLegend(position = "bottomright",values = ~PriceMean, pal = palc_price , opacity = 1)
      } else if (input$Neighbor != "None Selected" & input$Room_Type=="All Types"){     
          leaflet(h) %>%
          setView(long(input$Neighbor), lat(input$Neighbor), zoom(input$Neighbor))%>%
          addProviderTiles("CartoDB.Positron") %>%
          addCircles(lng = ~longitude, lat = ~latitude, radius = ~room_size, color = ~palc(room_size), stroke = T)%>%
          addLegend(position = "bottomright",
                    colors = c("#FEB24C","#e7152a","#2766c9"),
                    labels = c('Shared Room','Private Room','Entire Home'),
                    opacity = 0.6,
                    title = 'Room Type')}else{leaflet(h) %>%
                      setView(long(input$Neighbor), lat(input$Neighbor), zoom(input$Neighbor))%>%
                      addProviderTiles("CartoDB.Positron") %>%
                      addCircles(lng = ~longitude, lat = ~latitude, radius = ~room_size, color = ~palc(room_size), stroke = T)
      
      }    
  })
})



