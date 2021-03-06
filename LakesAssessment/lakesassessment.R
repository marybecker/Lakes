setwd("C:/Users/deepuser/Documents/Projects")

##Read in Lakes Chem and Secchi data
sites<-read.csv("Stations.csv",header=TRUE)
sites<-sites[,c(1,2)]
colnames(sites)[1]<-"AWQ"
lakes<-read.csv("LakesSummerChem.csv",header=TRUE)
lakes<-lakes[,c(3,4,5,6,8)]
lakes<- aggregate(lakes,by = list(lakes$AWQ),FUN = mean)
lakes<-lakes[,2:6]
lakes$Phosphorus<-lakes$Phosphorus/1000
lakes$Nitrogen<-lakes$Nitrogen/1000
GNIS<-read.csv("lakesptsGNIS_ID.csv",header=TRUE)
colnames(GNIS)[1]<-"AWQ"
GNIS<-GNIS[,c(1,9)]

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

lakes<-merge(lakes,sites,by="AWQ")
lakes<-merge(lakes,GNIS,by="AWQ")

write.csv(lakes,"lakesSumSummer_12_17.csv",row.names=FALSE)

