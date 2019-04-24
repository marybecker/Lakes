library("rmarkdown")

setwd("P:/Projects/2018/Lakes/LakesAssessmentCalc")

lakes<-read.csv("LakeData17.csv",header=TRUE)

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

lakes$TAvg<-rowMeans(subset(lakes,select=c(TPCAT,NCAT,CCAT,SCAT)),na.rm=TRUE)

lakes$Trophic<- ifelse(lakes$TAvg<=2,"Oligotrophic",
                       ifelse(lakes$TAvg>2 & lakes$TAvg<=3,"Early Mesotrophic",
                              ifelse(lakes$TAvg>3 & lakes$TAvg<=4,"Mesotrophic",
                                     ifelse(lakes$TAvg>4 & lakes$TAvg<=5,"Late Mesotrophic",
                                            ifelse(lakes$TAvg>5 & lakes$TAvg<6,"Eutrophic",
                                                   ifelse(lakes$TAvg == 6,"Highly Eutrophic",NA))))))

for (i in 1:dim(lakes)[1]){
  l <- lakes[i,]
  render("template.rmd",output_file = paste0('report.', l$Lake, '.html'))    
}



