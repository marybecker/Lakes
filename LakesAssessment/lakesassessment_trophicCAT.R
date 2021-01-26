setwd("")

library(dplyr)

##Read in Lakes Chem and Secchi data
lakes<-read.csv("data/lakedata14_16_exampleData.csv",header=TRUE)

lakes$summer<-ifelse(lakes$Season=="Summer",1,0)
lakes$spring<-ifelse(lakes$Season=="Spring",1,0)

#Only calc trophic cat for lakes that have both spring and summer (within one year)
#could include a summer sample in one year and spring sample in the next year
lakestouse<- lakes %>%
  group_by(STA_SEQ,Year) %>%
  summarise(TotalSeason=sum(c(summer,spring)))

lakestouse<-lakestouse[lakestouse$TotalSeason==2,]
lake_samples<-merge(lakes,lakestouse,by=c("STA_SEQ","Year"))

lake_nut_avg<- lake_samples %>%
    group_by(STA_SEQ,Year) %>%
    summarise(Phosphorus=mean(Phosphorus),Nitrogen=mean(Nitrogen))

lake_summer<- lake_samples[lake_samples$Season=="Summer",]
lake_summer<-lake_summer[,c(1:3,5:7,10)]

lakes<-merge(lake_summer,lake_nut_avg,by=c("STA_SEQ","Year"))
lakes$Phosphorus<-lakes$Phosphorus/1000
lakes$Nitrogen<-lakes$Nitrogen/1000


##Calculate Trophic Score for Each Parameter (TP, TN, Chlor a, Transparency)
lakes$TPCAT<-ifelse(lakes$Phosphorus<=0.010,1,
                    ifelse(lakes$Phosphorus>0.010 & lakes$Phosphorus<=0.015,2,
                           ifelse(lakes$Phosphorus>0.015 & lakes$Phosphorus<=0.025,3,
                                  ifelse(lakes$Phosphorus>0.025 & lakes$Phosphorus<=0.030,4,
                                         ifelse(lakes$Phosphorus>0.030 & lakes$Phosphorus<=0.050,5,
                                                ifelse(lakes$Phosphorus > 0.050,6,NA))))))

lakes$NCAT<-ifelse(lakes$Nitrogen<=0.2,1,
                    ifelse(lakes$Nitrogen>0.2 & lakes$Nitrogen<=0.3,2,
                           ifelse(lakes$Nitrogen>0.3 & lakes$Nitrogen<=0.5,3,
                                  ifelse(lakes$Nitrogen>0.5 & lakes$Nitrogen<=0.6,4,
                                         ifelse(lakes$Nitrogen>0.6 & lakes$Nitrogen<=1,5,
                                                ifelse(lakes$Nitrogen > 1,6,NA))))))

lakes$CCAT<-ifelse(lakes$Chlorophyll.a<=2,1,
                   ifelse(lakes$Chlorophyll.a>2 & lakes$Chlorophyll.a<=5,2,
                          ifelse(lakes$Chlorophyll.a>5 & lakes$Chlorophyll.a<=10,3,
                                 ifelse(lakes$Chlorophyll.a>10 & lakes$Chlorophyll.a<=15,4,
                                        ifelse(lakes$Chlorophyll.a>15 & lakes$Chlorophyll.a<=30,5,
                                               ifelse(lakes$Chlorophyll.a > 30,6,NA))))))

lakes$SCAT<-ifelse(lakes$Secchi>=6,1,
                        ifelse(lakes$Secchi<6 & lakes$Secchi>=4,2,
                               ifelse(lakes$Secchi<4 & lakes$Secchi>=3,3,
                                      ifelse(lakes$Secchi<3 & lakes$Secchi>=2,4,
                                             ifelse(lakes$Secchi<2 & lakes$Secchi>=1,5,
                                                    ifelse(lakes$Secchi < 1,6,NA))))))

#Average the Trophic Scores and Assign a Trophic Category
lakes$TAvg<-rowMeans(subset(lakes,select=c(TPCAT,NCAT,CCAT,SCAT)),na.rm=TRUE)

lakes$Trophic<- ifelse(lakes$TAvg<=2,"Oligotrophic",
                       ifelse(lakes$TAvg>2 & lakes$TAvg<=3,"Early Mesotrophic",
                              ifelse(lakes$TAvg>3 & lakes$TAvg<=4,"Mesotrophic",
                                     ifelse(lakes$TAvg>4 & lakes$TAvg<=5,"Late Mesotrophic",
                                            ifelse(lakes$TAvg>5 & lakes$TAvg<6,"Eutrophic",
                                                   ifelse(lakes$TAvg == 6,"Highly Eutrophic",NA))))))

