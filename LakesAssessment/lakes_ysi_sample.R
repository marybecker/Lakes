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


##Read in Lakes ysi and geospatial data"

ysi<-read.csv("data/YSILakes2018.csv",header=TRUE)
samples<-unique(ysi[c("awq","date")])
lakespoly<-read_sf("data/uncas_test_lakepoly.geojson")
lakespts<-read_sf("data/uncas_test.geojson")
cttownspoly<-read_sf("data/CTTowns.geojson")

st<-samples[1,1]
dt<-samples[1,2]

s<-ysi[which(ysi$awq==st&ysi$date==dt),]
s<-s[order(s$depth),]

p1<-  ggplot(s,aes(temp,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,max(s$temp))+
        labs(y="Depth (m)",x="Temperature (°C)",title="Temperature (°C)")+
        theme_classic()+
        theme(text=element_text(size=16))

p2<-  ggplot(s,aes(do_mgl,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,max(s$do_mgl))+
        labs(y="Depth (m)",x="Dissolved Oxygen (mg/L)",title="Dissolved Oxygen (mg/L)")+
        theme_classic()+
        theme(text=element_text(size=16))

p3<-  ggplot(s,aes(cond,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,max(s$cond))+
        labs(y="Depth (m)",x=expression(paste("Conductivity (",mu,"g/L)")),
             title=expression(paste("Conductivity (",mu,"g/L)")))+
        theme_classic()+
        theme(text=element_text(size=16))

p4<-  ggplot(s,aes(bga_microL,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,max(s$bga_microL))+
        labs(y="Depth (m)",x=expression(paste("Phycocyanin Blue-Green Algae (",mu,"g/L)")),
             title=expression(paste("Phycocyanin Blue-Green Algae (",mu,"g/L)")))+
        theme_classic()+
        theme(text=element_text(size=16))

##Parse out the lake data that you are interested in
lakemappt<-lakespts[lakespts$STA_SEQ==st,]
lakemappoly<-lakespoly[lakespoly$sta_seq==st,]

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
tmap_save(wmap,paste0(lakespts$STA_SEQ,"map.png"),width=600,height=400,dpi=72)
map<-readPNG(paste0(lakespts$STA_SEQ,"map.png"))


lay<-rbind(c(1,2),
           c(3,NA),
           c(4,NA),
           c(5,NA),
           c(6,7),
           c(8,9))

infojust<-0
posx<-0.2
posy<-1
title<-textGrob(lakespoly$LAKE,
                gp=gpar(fontsize=30,fontface="bold", col="black",just=-1))
acre<-textGrob(paste("Acreage:",round(lakespoly$ACREAGE,2)),posx,posy,just=infojust)
town<-textGrob(paste("Town:",lakemappt$Municipali),posx,posy,just=infojust)
basin<-textGrob(paste("Basin No:",lakemappt$SubBasin),posx,posy,just=infojust)
map<-rasterGrob(map)

laketest<-grid.arrange(title,map,acre,town,basin,p1,p2,p3,p4,
                       ncol=2,layout_matrix=lay,
                       heights=unit(c(3,0.25,0.25,0.25,2,2),
                                    c("in","in","in","in","in","in")))
laketest

ggsave("ysitest.png",laketest,width=8,height=11,units="in",dpi=72)


           
