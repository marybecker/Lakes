setwd("/home/mkozlak/Documents/Projects/GitHub/LakesAssessment/LakesAssessmentCalc")

library(ggplot2)
library(grid)
library(gridExtra)
library(rgdal)
library(sp)
library(sf)


##Read in Lakes Chem and Secchi data
lakes<-read.csv("LakeData17.csv",header=TRUE)
lakespoly<-read_sf("/home/mkozlak/Documents/Projects/GitHub/LakesAssessment/gis_data/nla_lakes17.geojson")

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

for (i in 1:dim(lakes)[1]){
l<- lakes[i,]

lakemapdata<-lakespoly[lakespoly$STA_SEQ==l$STA_SEQ,]
lakemap<-ggplot(lakemapdata)+
  geom_sf(colour="deepskyblue1",fill="midnightblue")+
  theme(panel.background=element_rect(fill="grey12",color="grey50"),
        panel.grid=element_blank())

img1<-readPNG("/home/mkozlak/Documents/Projects/GitHub/LakesAssessment/gis_data/15864.png")

gradient<-data.frame(x=c(0,1,2,3,4,5,6,7),
                     y=c(1,1,1,1,1,1,1,1),
                     z=c(1,1,2,3,4,5,6,6))

p1<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      scale_x_continuous(breaks=c(1,3,5,6),
                     label=c("Oligotrophic","Mesotrophic",
                             "Eutrophic","Highly Eutrophic"),position="top")+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(TAvg,1),shape=17,size=4)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),legend.position = "none",
        axis.text.x=element_text(face = "bold", color = "black", size = 9))

p2<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      # scale_x_continuous(breaks=c(1,3,5,6),
      #                label=c("Oligotrophic","Mesotrophic",
      #                        "Eutrophic","Highly Eutrophic"))+
      scale_x_continuous(breaks=c(1,3,5,6),
                     label=c("","",
                             "",""),position="top")+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(TPCAT,1),shape=17,size=4)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),axis.ticks.x=element_blank(),legend.position = "none")

p3<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      # scale_x_continuous(breaks=c(1,3,5,6),
      #                label=c("Oligotrophic","Mesotrophic",
      #                        "Eutrophic","Highly Eutrophic"))+
      scale_x_continuous(breaks=c(1,3,5,6),
                         label=c("","",
                                 "",""),position="top")+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(NCAT,1),shape=17,size=4)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
          axis.title=element_blank(), 
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),axis.ticks.x=element_blank(),legend.position = "none")

p4<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      # scale_x_continuous(breaks=c(1,3,5,6),
      #                label=c("Oligotrophic","Mesotrophic",
      #                        "Eutrophic","Highly Eutrophic"))+
      scale_x_continuous(breaks=c(1,3,5,6),
                         label=c("","",
                                 "",""),position="top")+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(CCAT,1),shape=17,size=4)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),axis.ticks.x=element_blank(),legend.position = "none")

p5<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      # scale_x_continuous(breaks=c(1,3,5,6),
      #                label=c("Oligotrophic","Mesotrophic",
      #                        "Eutrophic","Highly Eutrophic"))+
      scale_x_continuous(breaks=c(1,3,5,6),
                         label=c("","",
                                 "",""),position="top")+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(SCAT,1),shape=17,size=4)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),axis.ticks.x=element_blank(),legend.position = "none")



title <- textGrob(paste(l$Lake,"SID:",l$STA_SEQ,"Lake Assessment Summary",l$SampleDate),
                  gp=gpar(fontsize=14,fontface="bold", col="black"))#1
tcat<-textGrob(paste("Trophic Category:",l$Trophic),
               gp=gpar(fontsize=14,fontface="bold.italic", col="black"))#21
map<-lakemap#2
lakeimg1<-rasterGrob(img1)#3
infojust<-0
posx<-0.2
posy<-1
background<-textGrob("Lake Information",posx,posy,just=infojust,
                     gp=gpar(fontface="bold"))#4
location<-textGrob("Town: Town Name",posx,posy,just=infojust)#5
WArea<-textGrob(paste("Watershed Area (sq km):",lakemapdata$AreaSqKm),posx,posy,just=infojust)#6
LArea<-textGrob(paste("Lake Area (sq mi):",lakemapdata$LASqMI),posx,posy,just=infojust)#7
Slen<-textGrob(paste("Shore Perimeter (mi):",lakemapdata$PerMI),posx,posy,just=infojust)#8
Elevation<-textGrob(paste("Elevation (m)"),posx,posy,just=infojust)#9,
ldepth<-textGrob("Lake Depth",posx,posy,just=infojust)#10
ptjust<-"right"
p1t<-textGrob("Trophic State Index",just=ptjust)#11-12
p2t<-textGrob("Total Phosphorus",just=ptjust)#13-14
p3t<-textGrob("Total Nitrogen",just=ptjust)#15-16
p4t<-textGrob("Chlorophyll-a",just=ptjust)#17-18
p5t<-textGrob("Transparency",just=ptjust)#19-20

lay<-rbind(c(1,1,21),
           c(NA,NA,NA),
           c(2,3,4),
           c(2,3,5),
           c(2,3,6),
           c(2,3,7),
           c(2,3,8),
           c(2,3,9),
           c(2,3,10),
           c(2,3,10),
           c(2,3,NA),
           c(11,NA,NA),
           c(12,12,12),
           c(13,NA,NA),
           c(14,14,14),
           c(15,NA,NA),
           c(16,16,16),
           c(17,NA,NA),
           c(18,18,18),
           c(19,NA,NA),
           c(20,20,20))

laketest<-grid.arrange(title,map,lakeimg1,
                       background,location,Slen,WArea,LArea,Elevation,ldepth,
                       p1t,p1,p2t,p2,p3t,p3,p4t,p4,p5t,p5,tcat,
                       ncol=2,layout_matrix=lay,
                       heights=unit(c(0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,
                                      0.25,0.25,1.5,0.25,0.5,0.25,0.5,0.25,
                                      0.5,0.25,0.5,0.25,0.5),
                                    c("in","in","in","in","in","in","in",
                                      "in","in","in","in","in","in","in",
                                      "in","in","in","in","in","in","in")))
laketest

ggsave(paste0(i,".png"),laketest,width=11,height=8,units="in",dpi=72)

}




