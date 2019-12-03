setwd("P:/Projects/GitHub_Prj/Lakes/LakesYSI")

library(ggplot2)
library(grid)
library(gridExtra)
library(rgdal)
library(sp)
library(sf)
library(png)
library(tmap)
library(dplyr)


##Read in Lakes ysi and secchi data"
ysi<-read.csv("data/2019_Lakes_YSI_09262019.csv",header=TRUE,stringsAsFactors = FALSE)
samples<-read.csv("data/samples_2019_111319.csv",header=TRUE,stringsAsFactors = FALSE)
ysisampleck<-unique(ysi[c("awq","date")])
samples<-merge(ysisampleck,samples,by=c("awq","date"))

##Read in Lakes geospatial data"
lakespoly<-read_sf("data/lakes_poly.geojson")
lakespts<-read_sf("data/lakes_pt.geojson")
cttownspoly<-read_sf("data/CTTowns.geojson")

##X axis limits - Max value for each parameter
maxtemp<- max(ysi$temp)
maxdo<-max(ysi$do_mgl)
maxchlor<-max(ysi$chlor_rfu)
maxbga<-max(ysi$bga_rfu)

##Generate a pdf for each lake in the dataset
for (i in 1:dim(samples)[1]){

st<-samples$awq[i]
dt<-samples$date[i]

s<-ysi[which(ysi$awq==st&ysi$date==dt),]
s<-s[order(s$depth),]

p1<-  ggplot(s,aes(temp,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,maxtemp)+
        labs(y="Depth (m)",x=expression(paste("Temperature (",degree,"C)")),
             title=expression(paste("Temperature (",degree,"C)")))+
        theme_classic()+
        theme(text=element_text(size=14))+
        theme(plot.margin=unit(c(1,1,1.5,1.5),"cm"))

p2<-  ggplot(s,aes(do_mgl,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,maxdo)+
        labs(y="Depth (m)",x="Dissolved Oxygen (mg/L)",title="Dissolved Oxygen (mg/L)")+
        theme_classic()+
        theme(text=element_text(size=14))+
        theme(plot.margin=unit(c(1,1,1.5,1.5),"cm"))

p3<-  ggplot(s,aes(chlor_rfu,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,maxchlor)+
        labs(y="Depth (m)",x="Chlorophyll (rfu)",
             title="Chlorophyll (rfu)")+
        theme_classic()+
        theme(text=element_text(size=14))+
        theme(plot.margin=unit(c(1,1,1.5,1.5),"cm"))

p4<-  ggplot(s,aes(bga_rfu,depth))+
        geom_path(size=1.5)+
        scale_y_reverse(limits=c(max(s$depth),0))+
        xlim(0,maxbga)+
        labs(y="Depth (m)",x="Phycocyanin Blue-Green Algae (rfu)",
             title="Phycocyanin (rfu)")+
        theme_classic()+
        theme(text=element_text(size=14))+
        theme(plot.margin=unit(c(1,1,1.5,1.5),"cm"))

##Parse out the lake data that you are interested in
lakemappt<-lakespts[which(lakespts$STA_SEQ==st),]
lakemappoly<-lakespoly[which(lakespoly$GNIS_ID==lakemappt$GNIS_ID),]

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
tmap_save(wmap,paste0("maps/",st,"map.png"),width=600,height=400,dpi=72)
map<-readPNG(paste0("maps/",st,"map.png"))


lay<-rbind(c(1,2),
           c(3,2),
           c(4,2),
           c(5,2),
           c(NA,2),
           c(NA,6),
           c(NA,7),
           c(NA,8),
           c(9,10),
           c(11,12))

infojust<-0
posx<-0.01
posy<-1
title<-textGrob(paste0(lakemappt$name," (SID ",samples$awq,")"),
                gp=gpar(fontsize=25,fontface="bold", col="black"),posx,posy,just=infojust)
sdate<-textGrob(paste("Sample Date:",dt),
                gp=gpar(fontsize=15,fontface="bold", col="black"),posx,posy,just=infojust)
secchi<-textGrob(paste("Secchi Depth (m):",format(round(samples$secchi_m[i],2),nsmall=2)),
                 gp=gpar(fontsize=15,fontface="bold", col="black"),posx,posy,just=infojust)
depth<-textGrob(paste("Total Depth (m):",format(round(samples$tdepth_m[i],2),nsmall=2)),
                 gp=gpar(fontsize=15,fontface="bold", col="black"),posx,posy,just=infojust)
acre<-textGrob(paste("Acres:",round(lakemappoly$area_acre,2)),posx,posy,just=infojust)
town<-textGrob(paste("Town:",lakemappt$town),posx,posy,just=infojust)
basin<-textGrob(paste("Drainage Basin:",lakemappt$sbas_nm),posx,posy,just=infojust)
map<-rasterGrob(map)

laketest<-grid.arrange(title,map,sdate,secchi,depth,acre,town,basin,p1,p2,p3,p4,
                       ncol=2,layout_matrix=lay,
                       heights=unit(c(0.5,0.5,0.5,0.5,1,0.25,0.25,0.25,3,3),
                                    c("in","in","in","in","in","in","in","in","in")))


ggsave(paste("ysipdf/",st,lakemappt$name,gsub('/','-',dt),"ysi.pdf"),laketest,width=8,height=11,units="in",dpi=72)

}
           
