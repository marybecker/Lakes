library(ggplot2)
library(reshape2)

lc <- read.csv('SedimentDiatoms/data/sediment_diatom_final_sites_historical_lc_040622.csv',header=TRUE)

###### Changing Land Cover ######
year <- c("1990","1995","2002","2006","2010","2015")

# Calculate differences in 85 lc to other time periods

for (i in 1:length(year)){
  y <- year[i]
  c <- i + 14
  lc$chgCF <- lc[,c] - lc[,14]
  colnames(lc)[dim(lc)[2]] <- paste0("chgCF_",y)
}


for (i in 1:length(year)){
  y <- year[i]
  c <- i + 21
  lc$chgCF <- lc[,c] - lc[,21]
  colnames(lc)[dim(lc)[2]] <- paste0("chgDev_",y)
}


colnames(lc)[14:20]<-c("CFPct_1985","CFPct_1990","CFPct_1995","CFPct_2002","CFPct_2006","CFPct_2010","CFPct_2015")
colnames(lc)[21:27]<-c("DevPct_1985","DevPct_1990","DevPct_1995","DevPct_2002","DevPct_2006","DevPct_2010","DevPct_2015")

# Manipulate data for boxplots (long to wide) for boxplots
CF <- reshape(lc[,c(2,14:20)],direction="long",idvar="staSeq",
                  varying=2:ncol(lc[,c(2,14:20)]),sep="_")

Dev <- reshape(lc[,c(2,21:27)],direction="long",idvar="staSeq",
              varying=2:ncol(lc[,c(2,21:27)]),sep="_")

CFDiff <- reshape(lc[,c(2,28:33)],direction="long",idvar="staSeq",
                  varying=2:ncol(lc[,c(2,28:33)]),sep="_")

DevDiff <- reshape(lc[,c(2,34:39)],direction="long",idvar="staSeq",
                   varying=2:ncol(lc[,c(2,34:39)]),sep="_")

# Set the variables for the boxplot.  df org as STA_SEQ,time,x_value - from reshape
i<- 1

cf_colors<-c("#005824","#238b45","#41ae76","#66c2a4","#99d8c9","#ccece6","#edf8fb")
dev_colors<-c("#fee5d9","#fcbba1","#fc9272","#fb6a4a","#ef3b2c","#cb181d","#99000d")
list_of_df<- list(CFDiff,DevDiff,CF,Dev)
df <- list_of_df[[i]] #choose the df to use
y_label_list<- list("% Core Forest Difference Since 1985",
                    "% Development Difference Since 1985",
                    "% Core Forest",
                    "% Development")
y_label<- y_label_list[[i]] #choose the y label
bplt_colors <- list(cf_colors,dev_colors,cf_colors,dev_colors)
colors <- bplt_colors[[i]]

# boxplot - change from 1985
lc_plt <- ggplot(df,aes(as.factor(time),df[,3]*100))+
  geom_boxplot(fill=colors[1:length(unique(df$time))],alpha=0.8)+
  labs(y=y_label[[1]],x="Year")+
  theme_bw()

lc_plt

file <- paste0("SedimentDiatoms/plots/",names(df[3]),".png")
ggsave(plot=lc_plt,file,width=5,height=5,units="in")

CFPct_ForMap <- merge(CF,lc[,c(1,2,8,9,13:15,18,38,44)],by="staSeq")
write.csv(CFPct_ForMap,"diatom_site_selection_sites.csv",row.names = FALSE)



################################################################################
####lc 2016#####################################################################
################################################################################

state_lc <- data.frame("staSeq" = "State", "ic_pct" =0.090909013, 
                       "devos_pct" = 0.099190734,"ag_pct" = 0.039572029,
                       "for_pct" =0.580557885,"wet_pct" = 0.046130951, 
                       type = "State")

lc_16 <- read.csv('SedimentDiatoms/data/sediment_diatom_final_sites_040622.csv', 
                  header = TRUE)
lc_16 <- lc_16[,c(1,12:16)]
lc_16$type <- "Site"

lc_16 <- rbind(lc_16, state_lc)

lc_16_long <- melt(lc_16, measure.vars=2:6, variable.name="lc", 
                   value.name="pct")

lc_agg <- aggregate(pct ~ lc + type, data = lc_16_long, FUN = "median")

ggplot(lc_agg, aes(lc,pct), fill = factor(type)) +
  geom_col(position = "dodge2",na.rm = TRUE)

lc16_plt <- ggplot(lc_16_long[lc_16_long$type = "site",],aes(as.factor(lc),pct*100))+
  geom_boxplot(alpha=0.8)+
  theme_bw()

lc16_plt