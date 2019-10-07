if (!require("DT")) install.packages('DT')
if (!require("dtplyr")) install.packages('dtplyr')
if (!require("lubridate")) install.packages('lubridate')
if (!require("ggmap")) install.packages('ggmap')
#if (!require("choroplethrZip")) {
  # install.packages("devtools")
  #library(devtools)
  #install_github('arilamstein/choroplethrZip@v1.5.0')}
library(dtplyr)
library(dplyr)
library(DT)
library(lubridate)


airlist<-read.csv(file="../data/AirBnBlistings_ext.csv")
colnames(airlist, do.NULL = TRUE, prefix = "col")
airlist <- airlist %>%
  select('id','name','neighbourhood_cleansed','neighbourhood_group_cleansed','zipcode','latitude','longitude','property_type','room_type','accommodates','price','minimum_minimum_nights','maximum_maximum_nights','review_scores_rating')

summary(airlist)
airlist <-airlist[airlist$neighbourhood_group_cleansed %in% c('Manhattan','Bronx','Brooklyn','Queens','Staten Island'),]

save(airlist, file="../output/airbnbnew.RData")
