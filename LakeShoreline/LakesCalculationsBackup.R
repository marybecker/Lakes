setwd("C:/Users/kevin/Documents/Projects/GitHub/LakesCalculations")
stats<-read.csv("CT Lakes/lakes_buffer_building.csv",header=TRUE)
imperviousStats<-read.csv("CT Lakes/lakes_impervious_stats.csv",header = TRUE)
lakeRoads<-(read.csv("CT Lakes/lakes_roads.csv", header = TRUE))


db_path <- paste0(getwd(),'/CT Lakes/')
#db <- dbConnect(SQLite(), dbname=paste(db_path,"",sep=''));

imperviousStats1 <- imperviousStats[,c(2,4:7)]
names(imperviousStats1)[names(imperviousStats1) == "SUM_area_b"] <- "buffer acres"
names(imperviousStats1)[names(imperviousStats1) == "SUM_area_a"] <- "building acres"
names(imperviousStats1)[names(imperviousStats1) == "SUM_area_r"] <- "Roads acres"
names(imperviousStats1)[names(imperviousStats1) == "SUM_area_o"] <- "OtherImp acres"
imperviousStats2 <- na.omit(imperviousStats)

SumAcres = sum(imperviousStats1$`buffer acres`)
Total_sq_ft = SumAcres * 43560

CountBuilding = sum(stats$SUM_Join_C)

##Number of buildings per lake shore area (N/sqft)
"Number of buildings per lake shore area" = print(CountBuilding/Total_sq_ft)
##Avg buildings per lake shore
"Average buildings per lake shore" = print(CountBuilding/(length(imperviousStats1$GNIS_ID)))
##percent of lake shore area covered by buildings 
"Percent lake shore covered by buildings" = print((sum(imperviousStats2$SUM_area_a)/sum(imperviousStats2$SUM_area_b)) * 100)
##Number of roads per lake shore area (N/sqft)
SumRoads = sum(lakeRoads$Join_Cou_1)
"Number of roads per lake shore area" = print(SumRoads/Total_sq_ft)
##Percent of lake shore area covered by road
"Percent lake shore area covered by road" = print((sum(imperviousStats2$SUM_area_r)/sum(imperviousStats2$SUM_area_b)) * 100)
##Percent of lake shore area covered by impervious surface (buildings,road,&other)
totalImperviousCover<-sum(imperviousStats2$SUM_area_a)+
  sum(imperviousStats2$SUM_area_r)+
  sum(imperviousStats2$SUM_area_o)
"Percent of lake shore area covered by impervious surfaces" = print((totalImperviousCover/(sum(imperviousStats2$SUM_area_b))) * 100)