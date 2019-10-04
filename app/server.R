### INSERT DEPENDENCIES

library(shiny)
library(choroplethr)
library(choroplethrZip)
library(dplyr)
library(leaflet)
library(maps)
library(rgdal)

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
listings_data=
  listings_data%>%
  mutate(region=as.character(neighbourhood))

count.df=listings_data%>%
  group_by(neighbourhood)%>%
  summarise(
    value=n()
  )
names(count.df)[1] <- "region"

########### PAGE 1 SCRIPTS ###############


shinyServer(function(input, output) {

  
  output$map <- renderLeaflet({
    count.df.sel=count.df
    if(input$nbhd>0){
      count.df.sel=count.df%>%
        filter(region %in% zip.nbhd[[as.numeric(input$nbhd)]])
    }
    
    # From https://data.cityofnewyork.us/Business/Zip-Code-Boundaries/i8iw-xf4u/data
    NYCzipcodes <- readOGR("../data/ZIP_CODE_040114.shp",
                           #layer = "ZIP_CODE", 
                           verbose = FALSE)
    
    selZip <- subset(NYCzipcodes, NYCzipcodes$ZIPCODE %in% count.df.sel$region)
    
    # ----- Transform to EPSG 4326 - WGS84 (required)
    subdat<-spTransform(selZip, CRS("+init=epsg:4326"))
    
    # ----- save the data slot
    subdat_data=subdat@data[,c("ZIPCODE", "POPULATION")]
    subdat.rownames=rownames(subdat_data)
    subdat_data=
      subdat_data%>%left_join(count.df, by=c("ZIPCODE" = "region"))
    rownames(subdat_data)=subdat.rownames
    
    # ----- to write to geojson we need a SpatialPolygonsDataFrame
    subdat<-SpatialPolygonsDataFrame(subdat, data=subdat_data)
    
    # ----- set uo color pallette https://rstudio.github.io/leaflet/colors.html
    # Create a continuous palette function
    pal <- colorNumeric(
      palette = "Blues",
      domain = subdat$POPULATION
    )
    
    leaflet(subdat) %>%
      addTiles()%>%
      addPolygons(
        stroke = T, weight=1,
        fillOpacity = 0.6,
        color = ~pal(POPULATION)
      )
  })
  
})







########### PAGE 2 SCRIPTS ###############










##########################################











