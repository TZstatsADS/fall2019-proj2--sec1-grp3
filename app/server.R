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

#setwd("/Desktop/MS&E_3/Applied DS/fall2019-proj2--sec1-grp3/app")
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
palc <- colorFactor(c("#e6e715","#e7152a","#2766c9"), c(3,5,10))

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
     
      labels <- sprintf(
        "<strong>%s</strong><br/>%g $",
        borough_price$boro_name, borough_price$PriceMean
      ) %>% lapply(htmltools::HTML)
      
      
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
        addProviderTiles("CartoDB.Positron")
      } else{  
     leaflet(h) %>%
      setView(long(input$Neighbor), lat(input$Neighbor), zoom(input$Neighbor))%>%
      addProviderTiles("CartoDB.Positron") %>%
      addCircles(lng = ~longitude, lat = ~latitude, radius = ~room_size, color = ~palc(room_size), stroke = T)
      
      }    
  })
    
    # From https://data.cityofnewyork.us/Business/Zip-Code-Boundaries/i8iw-xf4u/data
  #   NYCzipcodes <- readOGR("../data/ZIP_CODE_040114.shp",
  #                          #layer = "ZIP_CODE",
  #                          verbose = FALSE)
  #   
  #   selZip <- subset(NYCzipcodes, NYCzipcodes$ZIPCODE %in% count.df.sel$region)
  #   
  #   # ----- Transform to EPSG 4326 - WGS84 (required)
  #   subdat<-spTransform(selZip, CRS("+init=epsg:4326"))
  #   
  #   # ----- save the data slot
  #   subdat_data=subdat@data[,c("ZIPCODE", "POPULATION")]
  #   subdat.rownames=rownames(subdat_data)
  #   subdat_data=
  #     subdat_data%>%left_join(count.df, by=c("ZIPCODE" = "region"))
  #   rownames(subdat_data)=subdat.rownames
  #   
  #   # ----- to write to geojson we need a SpatialPolygonsDataFrame
  #   subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)
  #   
  #   # ----- set uo color pallette https://rstudio.github.io/leaflet/colors.html
  #   # Create a continuous palette function
  #   pal <- colorNumeric(
  #     palette = "Blues",
  #     domain = subdat$POPULATION
  #   )
  #   
  #   leaflet(subdat) %>%
  #     addTiles()%>%
  #     addPolygons(
  #       stroke = T, weight=1,
  #       fillOpacity = 0.6,
  #       color = ~pal(POPULATION)
  #     )
  # })  

















  
})



# EXAMPLES 

# Define server logic required to draw a histogram
# shinyServer(function(input, output) {
# 
#   ## Neighborhood name
#   output$text = renderText({"Selected:"})
#   output$text1 = renderText({
#       paste("{ ", man.nbhd[as.numeric(input$nbhd)+1], " }")
#   })
# 
#   ## Panel 1: summary plots of time trends,
#   ##          unit price and full price of sales.
# 
#   output$distPlot <- renderPlot({
# 
#     ## First filter data for selected neighborhood
#     mh2009.sel=mh2009.use
#     if(input$nbhd>0){
#       mh2009.sel=mh2009.use%>%
#                   filter(region %in% zip.nbhd[[as.numeric(input$nbhd)]])
#     }
# 
#     ## Monthly counts
#     month.v=as.vector(table(mh2009.sel$sale.month))
# 
#     ## Price: unit (per sq. ft.) and full
#     type.price=data.frame(bldg.type=c("10", "13", "25", "28"))
#     type.price.sel=mh2009.sel%>%
#                 group_by(bldg.type)%>%
#                 summarise(
#                   price.mean=mean(sale.price, na.rm=T),
#                   price.median=median(sale.price, na.rm=T),
#                   unit.mean=mean(unit.price, na.rm=T),
#                   unit.median=median(unit.price, na.rm=T),
#                   sale.n=n()
#                 )
#     type.price=left_join(type.price, type.price.sel, by="bldg.type")
# 
#     ## Making the plots
#     layout(matrix(c(1,1,1,1,2,2,3,3,2,2,3,3), 3, 4, byrow=T))
#     par(cex.axis=1.3, cex.lab=1.5,
#         font.axis=2, font.lab=2, col.axis="dark gray", bty="n")
# 
#     ### Sales monthly counts
#     plot(1:12, month.v, xlab="Months", ylab="Total sales",
#          type="b", pch=21, col="black", bg="red",
#          cex=2, lwd=2, ylim=c(0, max(month.v,na.rm=T)*1.05))
# 
#     ### Price per square foot
#     plot(c(0, max(type.price[,c(4,5)], na.rm=T)),
#          c(0,5),
#          xlab="Price per square foot", ylab="",
#          bty="l", type="n")
#     text(rep(0, 4), 1:4+0.5, paste(c("coops", "condos", "luxury hotels", "comm. condos"),
#                                   type.price$sale.n, sep=": "), adj=0, cex=1.5)
#     points(type.price$unit.mean, 1:nrow(type.price), pch=16, col=2, cex=2)
#     points(type.price$unit.median, 1:nrow(type.price),  pch=16, col=4, cex=2)
#     segments(type.price$unit.mean, 1:nrow(type.price),
#               type.price$unit.median, 1:nrow(type.price),
#              lwd=2)
# 
#     ### full price
#     plot(c(0, max(type.price[,-1], na.rm=T)),
#          c(0,5),
#          xlab="Sales Price", ylab="",
#          bty="l", type="n")
#     text(rep(0, 4), 1:4+0.5, paste(c("coops", "condos", "luxury hotels", "comm. condos"),
#                                    type.price$sale.n, sep=": "), adj=0, cex=1.5)
#     points(type.price$price.mean, 1:nrow(type.price), pch=16, col=2, cex=2)
#     points(type.price$price.median, 1:nrow(type.price),  pch=16, col=4, cex=2)
#     segments(type.price$price.mean, 1:nrow(type.price),
#              type.price$price.median, 1:nrow(type.price),
#              lwd=2)
#   })
# 
#   ## Panel 2: map of sales distribution
#   output$distPlot1 <- renderPlot({
#     count.df.sel=count.df
#     if(input$nbhd>0){
#       count.df.sel=count.df%>%
#         filter(region %in% zip.nbhd[[as.numeric(input$nbhd)]])
#     }
#     # make the map for selected neighhoods
# 
#     zip_choropleth(count.df.sel,
#                    title       = "2009 Manhattan housing sales",
#                    legend      = "Number of sales",
#                    county_zoom = 36061)
#   })
# 
#   ## Panel 3: leaflet
#   output$map <- renderLeaflet({
#     count.df.sel=count.df
#     if(input$nbhd>0){
#       count.df.sel=count.df%>%
#         filter(region %in% zip.nbhd[[as.numeric(input$nbhd)]])
#     }
# 
#     # From https://data.cityofnewyork.us/Business/Zip-Code-Boundaries/i8iw-xf4u/data
#     NYCzipcodes <- readOGR("../data/ZIP_CODE_040114.shp",
#                            #layer = "ZIP_CODE",
#                            verbose = FALSE)
# 
#     selZip <- subset(NYCzipcodes, NYCzipcodes$ZIPCODE %in% count.df.sel$region)
# 
#     # ----- Transform to EPSG 4326 - WGS84 (required)
#     subdat<-spTransform(selZip, CRS("+init=epsg:4326"))
# 
#     # ----- save the data slot
#     subdat_data=subdat@data[,c("ZIPCODE", "POPULATION")]
#     subdat.rownames=rownames(subdat_data)
#     subdat_data=
#       subdat_data%>%left_join(count.df, by=c("ZIPCODE" = "region"))
#     rownames(subdat_data)=subdat.rownames
# 
#     # ----- to write to geojson we need a SpatialPolygonsDataFrame
#     subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)
# 
#     # ----- set uo color pallette https://rstudio.github.io/leaflet/colors.html
#     # Create a continuous palette function
#     pal <- colorNumeric(
#       palette = "Blues",
#       domain = subdat$POPULATION
#     )
# 
#     leaflet(subdat) %>%
#       addTiles()%>%
#       addPolygons(
#         stroke = T, weight=1,
#         fillOpacity = 0.6,
#         color = ~pal(POPULATION)
#       )
#   })
# })
