setwd("C:/Users/kevin/Documents/Projects/GitHub/LakesCalculations")

bufferStats<-read.csv("CT Lakes/lakes_buffer.csv",header=TRUE)
imperviousStats<-read.csv("CT Lakes/impervious_stats.csv",header = TRUE)
##lakeRoads<-(read.csv("CT Lakes/roads_stats.csv", header = TRUE))
Buildings<-(read.csv("CT Lakes/buffer_building_stats.csv", header = TRUE))
impPercent<-(read.csv("CT Lakes/LakesData.csv", header = TRUE))
Lakechem<-(read.csv("CT Lakes/lakesSumSummer_12_17.csv", header = TRUE))

lakeRoads<-(read.csv("CT Lakes/lakes_poly_Buffer_roads.csv", header = TRUE))

db_path <- paste0(getwd(),'/CT Lakes/')
#db <- dbConnect(SQLite(), dbname=paste(db_path,"",sep=''));
  
SumAcres = sum(bufferStats$area_buffe)
  Total_sq_ft = SumAcres * 43560

CountBuilding = sum(Buildings$FREQUENCY)

options(digits = 3, scipen = 999)

##Number of buildings per lake shore area (N/sqft)
"Number of buildings per lake shore sqft" = print(CountBuilding/Total_sq_ft)
"Number of buildings per lake shore acre" = print(CountBuilding/SumAcres)

##Avg buildings per lake shore
"Average buildings per lake shore" = print(CountBuilding/(length(bufferStats$GNIS_ID)))

##percent of lake shore area covered by buildings 
"Percent lake shore covered by buildings" = print((sum(Buildings$SUM_area_b)/sum(bufferStats$area_buffe)) * 100)

##Number of roads per lake shore area (N/sqft)
SumRoads = sum(lakeRoads$SUM_Join_C)
"Number of roads per lake shore sqft" = print(SumRoads/Total_sq_ft)
"Number of roads per lake shore acres" = print(SumRoads/SumAcres)

##Percent of lake shore area covered by road
"Percent lake shore area covered by road" = print((sum(lakeRoads$SUM_area_r)/(SumAcres)) * 100)

##Percent of lake shore area covered by impervious surface (buildings,road,&other)
totalImpervious<-sum(imperviousStats$SUM_area_o)+
  sum(lakeRoads$SUM_area_r)+
  sum(Buildings$SUM_area_b)
"Percent of lake shore area covered by impervious surfaces" = print((totalImpervious/(SumAcres)) * 100)



library(dplyr)
library(plyr)
library(tidyr)

##TOTAL impervious by lake site 
Lakes <- subset(bufferStats, select = c("GNIS_ID","GNIS_Name"))
##List <- list(bufferStats,Buildings,lakeRoads,imperviousStats)

lakeRoads <-subset(lakeRoads, select = c("GNIS_ID", "SUM_area_r"))

##bind_rows(List, .id = "G") %>%
##spread(G, Value, fill = 0)

lakesDf1 <- bufferStats %>%
  left_join(Buildings, by = "GNIS_ID") %>%
  left_join(imperviousStats, by = "GNIS_ID") %>%
  left_join(lakeRoads, by = "GNIS_ID")


# rename and set NAs to 0
lakesDf1[is.na(lakesDf1)] <- 0


lakesDf1 <- subset(lakesDf1, select = c("GNIS_ID",
                                        "GNIS_Name",
                                        "area_acre",
                                        "area_buffe",
                                        "SUM_area_b",
                                        "SUM_area_r",
                                        "SUM_area_o"))

lakesDf2 <-as.data.frame.matrix(lakesDf1)
lakesData <-cbind(lakesDf2, total = rowSums(lakesDf1[5:7]))

names(lakesData)[names(lakesData) == "SUM_area_b"] <- "building_acres"
names(lakesData)[names(lakesData) == "SUM_area_r"] <- "road_acres"
names(lakesData)[names(lakesData) == "SUM_area_o"] <- "other_impervious_acres"
names(lakesData)[names(lakesData) == "total"] <- "total_impervious_acres"
options(digits = 3)
options(scipen=999)

lakesData


write.csv(lakesData, "CT Lakes/LakesData.csv", row.names = FALSE)


##boxplot lakesData
library(ggplot2)
library(scales)


data_summ <- function(x) {
  m <- mean(x)
  ymin <- m-sd(x)
  ymax <- m+sd(x)
  return(c(y=m,ymin=ymin,ymax=ymax))
}


med = median(lakesPercent$total_impervious_percent)


LakesState <- subset(lakesData, select = c("total_impervious_acres"))
LakesState['Statewide'] = 'Statewide'

##
lakesPercent <- data.frame(impPercent)

lakesPercent

library(ggplot2)
statewide_percents <- subset(lakesPercent, select = c("total_impervious_percent"))
statewide_percents['Statewide'] = 'Statewide'

##outlier labels
  stat_summary(
  aes(label = round(stat(y), 1)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+

quantile(statewide_percents$total_impervious_percent, probs = c(0.25, 0.75))

bp1 <- ggplot(statewide_percents, aes(Statewide,total_impervious_percent))+
  geom_boxplot(outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  geom_text(data = statewide_percents, aes(Statewide, med,label = sprintf("%0.2f", round(med, digits = 3))), 
            position = position_dodge(width = 0.8), size = 4, vjust = -12, hjust = 0.58)+
  stat_summary(
    aes(label = round(stat(y), 1)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+
  annotate("text", x = 0.6, y = 2.64, label = c("25Q"))+
  annotate("text", x = 0.6, y = 11.69, label = c("75Q"))+
  coord_flip()+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  ##geom_jitter(width = 0.5, cex=1.2,shape=1)+
  labs(title = "CT Lakes Impervious Surface Cover",x="Statewide Lakes", y="\nPercent Impervious Cover\n")+
  theme_bw()+
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank())+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_y_continuous(breaks = round(seq(min(statewide_percents$total_impervious_percent), max(statewide_percents$total_impervious_percent), by = 5),1))


bp1

##Shoreline dev + chem

Lakechem
