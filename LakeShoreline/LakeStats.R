setwd("C:/Users/kevin/Documents/Projects/GitHub/LakesCalculations")

bufferStats<-read.csv("CT Lakes/lakes_buffer.csv",header=TRUE)
imperviousStats<-read.csv("CT Lakes/impervious_stats.csv",header = TRUE)
##lakeRoads<-(read.csv("CT Lakes/roads_stats.csv", header = TRUE))
Buildings<-(read.csv("CT Lakes/buffer_building_stats.csv", header = TRUE))
impPercent<-(read.csv("CT Lakes/LakesData1.csv", header = TRUE))

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


##write.csv(lakesData, "CT Lakes/LakesData.csv", row.names = FALSE)


##boxplot lakesData
library(ggplot2)
library(scales)
library(ggrepel)


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
    aes(label = round(stat(y), 0)),
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

Lakechem<-(read.csv("CT Lakes/lakesSumSummer_12_17.csv", header = TRUE))

Lakechem

lakesDf2 <- impPercent %>%
  left_join(Lakechem, by = "GNIS_ID") 

lakesDf3 <- data.frame(na.omit(lakesDf2))


TrophicBoxplot <- ggplot(lakesDf3, aes(x= Trophic_Simple, y= total_impervious_percent, fill = Trophic_Simple)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development by Trophic Category",x="\nTrophic Classification\n", y="\nPercent Impervious Cover\n")+
  geom_text_repel(data = subset(lakesDf3, total_impervious_percent > 24), aes(label = GNIS_Name))+
  scale_x_discrete(limits = rev(levels(as.factor(lakesDf3$Trophic_Simple))))+
  scale_fill_manual(values = c("Oligotrophic" = "#99CCFF",
                               "Mesotrophic" = "gray",
                               "Eutrophic" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(axis.text.x = element_text(hjust = 0.5))+
  theme(legend.position="none")

TrophicBoxplot


TPBoxplot <- ggplot(lakesDf3, aes(x= TPCAT, y= total_impervious_percent, group = TPCAT)) + 
  geom_boxplot(aes(fill = factor(TPCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development TPCAT",x="\nChem Grouping (TPCAT)\n", y="\nPercent Impervious Cover\n")+
  geom_text_repel(data = subset(lakesDf3, total_impervious_percent > 15), aes(label = GNIS_Name))+
  stat_summary(
    aes(label = round(stat(y), 0)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(lakesDf3$TPCAT), max(lakesDf3$TPCAT), by = 1),1))

TPBoxplot


NBoxplot <- ggplot(lakesDf3, aes(x= NCAT, y= total_impervious_percent, group = NCAT)) + 
  geom_boxplot(aes(fill = factor(NCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development NCAT",x="\nChem Grouping (NCAT)\n", y="\nPercent Impervious Cover\n")+
  stat_summary(
    aes(label = round(stat(y), 0)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(lakesDf3$NCAT), max(lakesDf3$NCAT), by = 1),1))

NBoxplot


CBoxplot <- ggplot(lakesDf3, aes(x= CCAT, y= total_impervious_percent, group = CCAT)) + 
  geom_boxplot(aes(fill = factor(CCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development CCAT",x="\nChem Grouping (CCAT)\n", y="\nPercent Impervious Cover\n")+
  geom_text_repel(data = subset(lakesDf3, total_impervious_percent > 20), aes(label = GNIS_Name))+
  stat_summary(
    aes(label = round(stat(y), 0)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(lakesDf3$CCAT), max(lakesDf3$CCAT), by = 1),1))

CBoxplot


SBoxplot <- ggplot(lakesDf3, aes(x= SCAT, y= total_impervious_percent, group = SCAT)) + 
  geom_boxplot(aes(fill = factor(SCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development SCAT",x="\nChem Grouping (SCAT)\n", y="\nPercent Impervious Cover\n")+
  stat_summary(
    aes(label = round(stat(y), 0)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(lakesDf3$SCAT), max(lakesDf3$SCAT), by = 1),1))

SBoxplot


##scatterplots

Lakechem_df <- subset(lakesDf3, select = c("GNIS_ID", 
                                           "GNIS_Name",
                                           "total_impervious_percent",
                                           "TPCAT",
                                           "Phosphorus",
                                           "Nitrogen",
                                           "Chlorophyll.a",
                                           "Secchi"))


##write.csv(Lakechem_df, "CT Lakes/Lakechem_df2.csv", row.names = FALSE)
Lakechem_df2 <- (read.csv("CT Lakes/Lakechem_df2.csv", header = TRUE))

d2 <- data.frame(Lakechem_df2, row.names = 2)

d <- d2
d$GNIS_Name <- rownames(d)

ChemPlot_Phosphorus <- ggplot(Lakechem_df2, aes(x=total_impervious_percent, y=Phosphorus))+ 
  geom_point(size = 3, shape = 19, color = "blue")+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE, color = "black", linetype = "dashed")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  labs(title = "Lakes Development Phosphorus",x="\nTotal Impervious Percent\n", y="\nPhosphorus (mg/L)\n")+
  geom_text_repel(data = subset(d, Phosphorus > 0.05), aes(label = GNIS_Name))


ChemPlot_Phosphorus


ChemPlot_Nitrogen <- ggplot(Lakechem_df, aes(x=total_impervious_percent, y=Nitrogen))+ 
  geom_point(size = 3, shape = 19, color = "orange")+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE, color = "black", linetype = "dashed")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  labs(title = "Lakes Development Nitrogen",x="\nTotal Impervious Percent\n", y="\nNitrogen(mg/L)\n")+
  geom_text_repel(data = subset(d, Nitrogen > 1.2), aes(label = GNIS_Name))



ChemPlot_Nitrogen


ChemPlot_Chloro <- ggplot(Lakechem_df, aes(x=total_impervious_percent, y=Chlorophyll.a))+ 
  geom_point(size = 3, shape = 19, color = "dark blue")+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE, color = "black", linetype = "dashed")+
  ##geom_density_2d(color = "red")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  labs(title = "Lakes Development Chlorophyll a",x="\nTotal Impervious Percent\n", y="\nChlorophyll a (μg/L)\n")+
  geom_text_repel(data = subset(d, Chlorophyll.a > 60), aes(label = GNIS_Name))


ChemPlot_Chloro


ChemPlot_Secchi <- ggplot(Lakechem_df, aes(x=total_impervious_percent, y=Secchi))+ 
  geom_point(size = 3, shape = 19, color = "red")+
  ##geom_smooth(method=lm, se=FALSE, fullrange=TRUE, color = "black", linetype = "dashed")+
  ##geom_density_2d(color = "red")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  labs(title = "Lakes Development Secchi",x="\nTotal Impervious Percent\n", y="\nSecchi (m)\n")+
  geom_text_repel(data = subset(d, Secchi > 6), aes(label = GNIS_Name))


ChemPlot_Secchi

###Buildings area graphics


Buildings

lakechem

buildingStats <- Lakechem %>%
  left_join(Buildings, by = "GNIS_ID")

buildingStats[is.na(buildingStats)] <- 0

##write.csv(buildingStats, "CT Lakes/buildingStats.csv", row.names = FALSE)

TPBoxplotB <- ggplot(buildingStats, aes(x= TPCAT, y= FREQUENCY, group = TPCAT)) + 
  geom_boxplot(aes(fill = factor(TPCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  geom_text_repel(data = subset(buildingStats, FREQUENCY > 200), aes(label = locationName))+
  labs(title = "Lakes Development TPCAT",x="\nChem Grouping (TPCAT)\n", y="\nNumber of Lakeshore Buildings\n")+
  stat_summary(
    aes(label = round(stat(y), 0)),
    geom = "text", 
    fun= function(y) { o <- boxplot.stats(y)$out; if(length(o) == 0) NA else o },
    size = 2.5,
    hjust = 0.5,
    vjust = -1)+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(buildingStats$TPCAT), max(buildingStats$TPCAT), by = 1),1))

TPBoxplotB

NBoxplotB <- ggplot(buildingStats, aes(x= NCAT, y= FREQUENCY, group = NCAT)) + 
  geom_boxplot(aes(fill = factor(NCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development NCAT",x="\nChem Grouping (NCAT)\n", y="\nNumber of Lakeshore Buildings\n")+
  geom_text_repel(data = subset(buildingStats, FREQUENCY > 200), aes(label = locationName))+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(buildingStats$NCAT), max(buildingStats$NCAT), by = 1),1))

NBoxplotB

CBoxplotB <- ggplot(buildingStats, aes(x= CCAT, y= FREQUENCY, group = CCAT)) + 
  geom_boxplot(aes(fill = factor(CCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development CCAT",x="\nChem Grouping (CCAT)\n", y="\nNumber of Lakeshore Buildings\n")+
  geom_text_repel(data = subset(buildingStats, FREQUENCY > 200), aes(label = locationName))+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(buildingStats$CCAT), max(buildingStats$CCAT), by = 1),1))

CBoxplotB

SBoxplotB <- ggplot(buildingStats, aes(x= SCAT, y= FREQUENCY, group = SCAT)) + 
  geom_boxplot(aes(fill = factor(SCAT)),outlier.colour="black", outlier.shape=8,
               outlier.size=2)+
  labs(title = "Lakes Development SCAT",x="\nChem Grouping (SCAT)\n", y="\nNumber of Lakeshore Buildings\n")+
  geom_text_repel(data = subset(buildingStats, FREQUENCY > 200), aes(label = locationName))+
  scale_fill_manual(values = c("1" = "#99CCFF",
                               "2" = "gray",
                               "3" = "gray",
                               "4" = "gray",
                               "5" = "#FF9966",
                               "6" = "#FF9966"))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_summary(fun = mean, geom="point", shape=23, size=3)+
  stat_boxplot(geom = 'errorbar', width = 0.1)+
  theme(legend.position="none")+
  scale_x_continuous(breaks = round(seq(min(buildingStats$SCAT), max(buildingStats$SCAT), by = 1),1))

SBoxplotB
