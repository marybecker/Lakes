setwd("/home/mkozlak/Documents/Projects/GitHub/Lakes/LakesAssessment")

library(ggplot2)
library(grid)
library(gridExtra)
library(rgdal)
library(sp)
library(sf)
library(png)
library(tmap)
library(dplyr)


##Read in Lakes Chem and Secchi data
lakes<-read.csv("data/lakedata14_16.csv",header=TRUE)
lakespoly<-read_sf("data/Lake_Site_Poly_12_17.geojson")
lakespts<-read_sf("data/Lake_Site_Point_12_17.geojson")
cttownspoly<-read_sf("data/CTTowns.geojson")

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

#Automate rpt for each lake that includes trophic plots, map, and info 
for (i in 1:dim(lakes)[1]){
l<- lakes[i,]

##Parse out the lake data that you are interested in
lakemappt<-lakespts[lakespts$STA_SEQ==l$STA_SEQ,]
lakemappoly<-lakespoly[lakespoly$HydroID==lakemappt$HydroID,]

##Make a map of the parsed lake data
smap<-  tm_shape(cttownspoly)+
          tm_polygons(col="gray",border.col="white",lwd=2)+
        tm_shape(lakemappt)+
          tm_symbols(col="black")+
        tm_layout(bg.color="midnightblue")
lmap<-  tm_shape(lakemappoly)+
          tm_polygons(col="deepskyblue1",border.col="white",lwd=3,border.alpha=0.7)+
        tm_shape(lakemappt)+
          tm_symbols(col="black")+
        tm_layout(bg.color="midnightblue")

wmap<-tmap_arrange(smap,lmap)

tmap_save(wmap,paste0(l$STA_SEQ,l$Year,"map.png"),width=600,height=400,dpi=72)

gradient<-data.frame(x=c(0,1,2,3,4,5,6,7),
                     y=c(1,1,1,1,1,1,1,1),
                     z=c(1,1,2,3,4,5,6,6))

p1<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      #scale_x_continuous(breaks=c(1,3,5,6),
      #               label=c("Oligotrophic","Mesotrophic",
      #                       "Eutrophic","Highly Eutrophic"),position="top")+
      scale_x_continuous(breaks=c(1,3,5,6),
                     label=c("","",
                             "",""),position="top")+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(TAvg,1),shape=17,size=5)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),axis.ticks.x=element_blank(),legend.position = "none")

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
      geom_point(data=l,aes(TPCAT,1),shape=17,size=5)+
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
      geom_point(data=l,aes(NCAT,1),shape=17,size=5)+
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
      geom_point(data=l,aes(CCAT,1),shape=17,size=5)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),axis.ticks.x=element_blank(),legend.position = "none")

p5<-  ggplot()+
      xlim(0,7)+
      ylim(0.5,1.5)+
      scale_x_continuous(breaks=c(1,3,5,6),
                      label=c("Oligotrophic","Mesotrophic",
                              "Eutrophic","Highly Eutrophic"))+
      geom_raster(data=gradient,aes(x,y,fill=z),interpolate=TRUE)+
      scale_fill_gradientn(colours = c("blue","cyan","chartreuse"))+
      geom_point(data=l,aes(SCAT,1),shape=17,size=5)+
      theme(panel.background = element_rect(fill = "white", colour = "white"),
        axis.title=element_blank(), 
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),legend.position = "none",
        axis.text.x=element_text(face = "bold", color = "black", size = 14))




tcat<-textGrob(paste("Trophic Category:",l$Trophic),
               gp=gpar(fontsize=20,fontface="bold", col="black"))#21
ptjust<-"left"
ptposx<-0.2
ptposy<-0.5
fsize<-14
p1t<-textGrob("Trophic State Index",just=ptjust,ptposx,ptposy,
              gp=gpar(fontsize=fsize))#11-12
p2t<-textGrob("Total Phosphorus",just=ptjust,ptposx,ptposy,
              gp=gpar(fontsize=fsize))#13-14
p3t<-textGrob("Total Nitrogen",just=ptjust,ptposx,ptposy,
              gp=gpar(fontsize=fsize))#15-16
p4t<-textGrob("Chlorophyll-a",just=ptjust,ptposx,ptposy,
              gp=gpar(fontsize=fsize))#17-18
p5t<-textGrob("Transparency",just=ptjust,ptposx,ptposy,
              gp=gpar(fontsize=fsize))#19-20

# lay<-rbind(c(1,NA,NA),
#            c(1,NA,NA),
#            c(2,NA,NA),
#            c(3,3,3),
#            c(4,NA,NA),
#            c(5,5,5),
#            c(6,NA,NA),
#            c(7,7,7),
#            c(8,NA,NA),
#            c(9,9,9),
#            c(10,NA,NA),
#            c(11,11,11))

lay<-rbind(c(1,NA,NA),
           c(2,2,2),
           c(3,NA,NA),
           c(4,4,4),
           c(5,NA,NA),
           c(6,6,6),
           c(7,NA,NA),
           c(8,8,8),
           c(9,NA,NA),
           c(10,10,10))



laketrophicplot<-grid.arrange(
                       p1t,p1,p2t,p2,p3t,p3,p4t,p4,p5t,p5,
                       ncol=1,layout_matrix=lay,
                       heights=unit(c(0.25,0.5,0.25,0.5,0.25,
                                      0.5,0.25,0.5,0.25,0.5),
                                    c("in","in","in","in","in","in","in","in",
                                      "in","in","in","in")))
#grid.draw(laketrophicplot)

ggsave(paste0(l$STA_SEQ,l$Year,".png"),laketrophicplot,width=20,height=5,units="in",dpi=72)

##Write html to generate a slide for each lake assessment year##
l1<-paste0('<section data-background-image="LakesAssessment/data/15864.png" data-background-opacity=0.5 id="',l$STA_SEQ,'">')
l2<-paste0('<div id="left">')
l3<-paste0('<p style="text-align:left;">',l$Lake,' SID: ',l$STA_SEQ,'<br> Lake Assessment ',l$Year,'</p>')
l4<-paste0('<b>Lake Information</b>')
l5<-paste0('<ul style=font-size:medium;>')
l6<-paste0('Town: ')
l7<-paste0('<br>Shore Perimeter: ')
l8<-paste0('<br>Watershed Area: ')
l9<-'</ul>'
l10<-'</div>'
l11<-paste0('<div id="right"><img src="LakesAssessment/',l$STA_SEQ,l$Year,'map.png" alt="Lake Data">')
l12<-'</div>'
l13<-paste0('Trophic Category:',l$Trophic)
l13<-paste0('<img src="LakesAssessment/',l$STA_SEQ,l$Year,'.png" alt="Lake Data" style="opacity-0.8">')
l14<-'</section>'
write(c(l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14),"lakeslides.txt",append=TRUE)

}




