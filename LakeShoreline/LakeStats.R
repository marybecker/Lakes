setwd("C:/Users/kevin/Documents/Projects/GitHub/LakesCalculations")

bufferStats<-read.csv("CT Lakes/lakes_buffer.csv",header=TRUE)
imperviousStats<-read.csv("CT Lakes/impervious_stats.csv",header = TRUE)
lakeRoads<-(read.csv("CT Lakes/roads_stats.csv", header = TRUE))
Buildings<-(read.csv("CT Lakes/buffer_building_stats.csv", header = TRUE))


db_path <- paste0(getwd(),'/CT Lakes/')
#db <- dbConnect(SQLite(), dbname=paste(db_path,"",sep=''));
  
SumAcres = sum(bufferStats$area_buffe)
  Total_sq_ft = SumAcres * 43560

CountBuilding = sum(Buildings$FREQUENCY)

##Number of buildings per lake shore area (N/sqft)
"Number of buildings per lake shore area (sqft)" = print(CountBuilding/Total_sq_ft)

##Avg buildings per lake shore
"Average buildings per lake shore" = print(CountBuilding/(length(bufferStats$GNIS_ID)))

##percent of lake shore area covered by buildings 
"Percent lake shore covered by buildings" = print((sum(Buildings$SUM_area_b)/sum(bufferStats$area_buffe)) * 100)

##Number of roads per lake shore area (N/sqft)
SumRoads = sum(lakeRoads$SUM_Join_C)
"Number of roads per lake shore area (sqft)" = print(SumRoads/Total_sq_ft)
"Number of roads per lake shore area (acres)" = print(SumRoads/SumAcres)

##Percent of lake shore area covered by road
"Percent lake shore area covered by road" = print((sum(lakeRoads$SUM_area_r)/(SumAcres)) * 100)

##Percent of lake shore area covered by impervious surface (buildings,road,&other)
totalImpervious<-sum(imperviousStats$SUM_area_o)+
  sum(lakeRoads$SUM_area_r)+
  sum(Buildings$SUM_area_b)
"Percent of lake shore area covered by impervious surfaces" = print((totalImpervious/(SumAcres)) * 100)

