#---------------------------------------------------------------------------------------------------
# install.packages("plyr")
library("plyr")

#-----------------------------
# data <- read.csv(file="./StormData.csv", nrows=5)
# classes <- sapply(data, class)
# names(classes)

col.cl <- read.csv("readin_classes.csv", stringsAsFactors=FALSE, strip.white=TRUE)
data <- read.csv("StormData.csv", colClasses= col.cl$newclass2, nrows=1300000, strip.white=TRUE)
bzdata <- read.csv("StormData_DL.csv.bz2", colClasses= col.cl$newclass2, nrows=1300000, strip.white=TRUE)

# cleaning spaces in REMARKS and EVTYPE
data$REMARKS <- gsub("^ *", "", data$REMARKS, perl=TRUE)
data$REMARKS <- gsub(" *$", "", data$REMARKS, perl=TRUE)
data$REMARKS <- gsub("[ ]{2,}", " ", data$REMARKS, perl=TRUE)

data$EVTYPE <- gsub("^ *", "", data$EVTYPE, perl=TRUE)
data$EVTYPE <- gsub(" *$", "", data$EVTYPE, perl=TRUE)
data$EVTYPE <- gsub("[ ]{2,}", " ", data$EVTYPE, perl=TRUE)

data$COUNTYNAME <- toupper(data$COUNTYNAME)
data$EVTYPE <- toupper(data$EVTYPE)
data$PROPDMGEXP <- toupper(data$PROPDMGEXP)
data$CROPDMGEXP <- toupper(data$CROPDMGEXP)

# overkill to fix a 'O' mixed-in as a "0" 
gsub("([0-9])O(.*)([^M])$","\\1x\\2\\3",test, perl=TRUE)
data$BGN_TIME <- gsub("([0-9])O(.*)([^M])$","\\10\\2\\3", data$BGN_TIME, perl=TRUE)
# or... 
data$BGN_TIME[248542] <- "1300"

# making BGN and END dates dates
data$BGN_DATE.new <- strptime(as.character(data$BGN_DATE), "%m/%d/%Y %H:%M:%S")
data$END_DATE.new <- strptime(as.character(data$END_DATE), "%m/%d/%Y %H:%M:%S")

# setting "missing" coordinates to NA
data$LATITUDE[data$LATITUDE <= 0]  <- NA
data$LONGITUDE[data$LONGITUDE <= 0]  <- NA

# # sorting data chronologically 
# data <- data[order(data$BGN_DATE.new), ]

# create a 4-digit year factor variable
data$YEAR <- as.factor(substr(as.character(data$BGN_DATE.new),0,4))

#-----------------------------

emptyCounts <- sapply(data, function(x) sum(x == ""))
missingCounts <- sapply(data, function(x) sum(is.na(x)))

#-----------------------------
# sel.columns.c <- c("REFNUM", "STATE", "COUNTY", "BGN_DATE", "BGN_TIME", "END_DATE", "END_TIME", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
# sel.columns.n <- c( 37, 7, 5, 2, 3, 12, 13, 8, 23, 24, 25, 26, 27, 28)
sel.columns.n <- c( 37, 7, 5, 40, 38, 39, 8, 23, 24, 25, 26, 27, 28, 2, 3, 12, 13)

all_names <- colnames(data)
all_names[sel.columns.n]


good <- data[, sel.columns.n]

colnames(good)[14:17] <- paste("old", colnames(good)[14:17], sep=".")
colnames(good)[5] <- "BGN_DATE"
colnames(good)[6] <- "END_DATE"

# sorting data chronologically 
good <- good[order(good$BGN_DATE), ]

#---------------------------------------------------------------------------------------------------
# tornados <- data[,c(7,5,8,19:22)]
#---------------------------------------------------------------------------------------------------

EVTYPE.by.year <- tapply(good$EVTYPE, good$YEAR, function(x) table(x), simplify=TRUE)
sapply(EVTYPE.by.year, names)
sapply(EVTYPE.by.year, function(x) length(names(x)))

write.csv(EVTYPE.by.year[["2011"]], file="2011.csv")
write.csv(EVTYPE.by.year[["2010"]], file="2010.csv")
write.csv(EVTYPE.by.year[["2009"]], file="2009.csv")
write.csv(EVTYPE.by.year[["2008"]], file="2008.csv")
write.csv(EVTYPE.by.year[["2007"]], file="2007.csv")
write.csv(EVTYPE.by.year[["2006"]], file="2006.csv")
write.csv(EVTYPE.by.year[["2005"]], file="2005.csv")
write.csv(EVTYPE.by.year[["2004"]], file="2004.csv")
write.csv(EVTYPE.by.year[["2003"]], file="2003.csv")
write.csv(EVTYPE.by.year[["2002"]], file="2002.csv")
write.csv(EVTYPE.by.year[["2001"]], file="2001.csv")
write.csv(EVTYPE.by.year[["2000"]], file="2000.csv")
write.csv(EVTYPE.by.year[["1999"]], file="1999.csv")
write.csv(EVTYPE.by.year[["1998"]], file="1998.csv")
write.csv(EVTYPE.by.year[["1997"]], file="1997.csv")
write.csv(EVTYPE.by.year[["1996"]], file="1996.csv")

PROPDMGEXP.by.year <- tapply(good$PROPDMGEXP, good$YEAR, function(x) table(x), simplify=TRUE)
sapply(PROPDMGEXP.by.year, function(x) length(names(x)))
sapply(PROPDMGEXP.by.year, names)

CROPDMGEXP.by.year <- tapply(good$CROPDMGEXP, good$YEAR, function(x) table(x), simplify=TRUE)
sapply(CROPDMGEXP.by.year, function(x) length(names(x)))
sapply(CROPDMGEXP.by.year, names)

#=====================================
# ===>  HERE CALL gsub.R
#=====================================

colnames(good)[7] <- "old.EVTYPE"
good$EVTYPE <- TESTvec

#--- directly on data frame "good" -----------------------------------------
good$PDEXP <- good$PROPDMGEXP
good$PDEXP[good$PDEXP == "B"] <- 9
good$PDEXP[good$PDEXP == "M"] <- 6
good$PDEXP[good$PDEXP == "K"] <- 3
good$CDEXP <- good$CROPDMGEXP
good$CDEXP[good$CDEXP == "B"] <- 9
good$CDEXP[good$CDEXP == "M"] <- 6
good$CDEXP[good$CDEXP == "K"] <- 3

colnames(good)[11] <- "old.PROPDMGEXP"
colnames(good)[13] <- "old.CROPDMGEXP"
colnames(good)[19] <- "PROPDMGEXP"
colnames(good)[20] <- "CROPDMGEXP"

recent <- subset(good, BGN_DATE > as.POSIXlt("1996-01-01"))[,c(1:6, 18, 8:10, 19, 12, 20, 14:17, 7, 11, 13)]

#--- OR with an intermediate data frame "good.recent" -----------------------
good.recent <- subset(good, BGN_DATE > as.POSIXlt("1996-01-01"))

good.recent$PDEXP <- good.recent$PROPDMGEXP
good.recent$PDEXP[good.recent$PDEXP == "B"] <- 9
good.recent$PDEXP[good.recent$PDEXP == "M"] <- 6
good.recent$PDEXP[good.recent$PDEXP == "K"] <- 3
good.recent$CDEXP <- good.recent$CROPDMGEXP
good.recent$CDEXP[good.recent$CDEXP == "B"] <- 9
good.recent$CDEXP[good.recent$CDEXP == "M"] <- 6
good.recent$CDEXP[good.recent$CDEXP == "K"] <- 3

colnames(good.recent)[11] <- "old.PROPDMGEXP"
colnames(good.recent)[13] <- "old.CROPDMGEXP"
colnames(good.recent)[19] <- "PROPDMGEXP"
colnames(good.recent)[20] <- "CROPDMGEXP"

recent <- good.recent[,c(1:6, 18, 8:10, 19, 12, 20, 14:17, 7, 11, 13)]

# pp.crop <- recent$CROPDMG[recent$CROPDMGEXP == ""]
# pp.prop <- recent$PROPDMG[recent$PROPDMGEXP == ""]
# table(pp.crop)
# table(pp.prop)
# # all the "" values match DMG=0, so it seems safe to change them to 0's

#---------------------------------------------------------------------------------------------------

recent$PROPDMGEXP[recent$PROPDMGEXP == ""] <- 0
recent$CROPDMGEXP[recent$CROPDMGEXP == ""] <- 0
recent$PROPDMGEXP <- as.numeric(recent$PROPDMGEXP)
recent$CROPDMGEXP <- as.numeric(recent$CROPDMGEXP)

cat("## computing actual values for damages\n")
PropDamage <- recent$PROPDMG * 10^recent$PROPDMGEXP
CropDamage <- recent$CROPDMG * 10^recent$CROPDMGEXP

#---------------------------------------------------------------------------------------------------
cat("## checking highest damage event\n")
which.max(PropDamage)

recent[which.max(PropDamage),]
data$REMARKS[data$REFNUM == recent$REFNUM[which.max(PropDamage)]]

# correct NAPA flood cost exponent
recent$PROPDMGEXP[which.max(PropDamage)] <- 6
PropDamage <- recent$PROPDMG * 10^recent$PROPDMGEXP

data$REMARKS[data$REFNUM == recent$REFNUM[which.max(PropDamage)]]

#
recent[which.max(CropDamage),]
data$REMARKS[data$REFNUM == recent$REFNUM[which.max(CropDamage)]]

cat("## adding new columns to 'recent' data frame, with computed values for damages\n")
recent$PropDamage <- PropDamage
recent$CropDamage <- CropDamage

#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
lean <- recent[c(1,2,4,7,8,9,21,22)]
lean$YEAR <- substr(as.character(lean$BGN_DATE),0,4)
lean$BGN_DATE <- NULL
#lean.m <- melt(lean, id=c("REFNUM","STATE","YEAR","EVTYPE"), measured=c("FATALITIES","INJURIES","PropDamage","CropDamage"))

df1 <- ddply(lean, .(EVTYPE), summarize, fatalities=sum(FATALITIES), injuries=sum(INJURIES), 
             PropDmg=sum(PropDamage), CropDmg=sum(CropDamage), 
             flag= (sum(FATALITIES) + sum(INJURIES) + sum(PropDamage) +sum(CropDamage))>0 ) 

human <- ddply(lean, .(EVTYPE), summarize, 
               N.tot=length(FATALITIES), 
               N.with.fatalities=length(FATALITIES[FATALITIES>0]), 
               fatalities.tot=sum(FATALITIES), 
               fatalities.avrg=sum(FATALITIES)/length(FATALITIES[FATALITIES>0]), 
               N.with.injuries=length(INJURIES[INJURIES>0]), 
               injuries.tot=sum(INJURIES), 
               injuries.avrg=sum(INJURIES)/length(INJURIES[INJURIES>0]), 
               flag= (sum(FATALITIES) + sum(INJURIES))>0 ) 

economic <- ddply(lean, .(EVTYPE), summarize, 
                  N.tot=length(PropDamage), 
                  N.with.PropDmg=length(PropDamage[PropDamage>0]),
                  PropDmg.tot=sum(PropDamage), 
                  PropDmg.avrg=sum(PropDamage)/length(PropDamage[PropDamage>0]),
                  N.with.CropDmg=length(CropDamage[CropDamage>0]),
                  CropDmg.tot=sum(CropDamage), 
                  CropDmg.avrg=sum(CropDamage)/length(CropDamage[CropDamage>0]),
                  flag= (sum(PropDamage) + sum(CropDamage))>0 ) 

df1b <- df1[df1$flag,]
df1b[order(df1b$PropDmg),]
head(df1b[order(df1b$PropDmg, decreasing=TRUE),],10)

# HUMAN
human[order(human$fatalities.tot, decreasing=TRUE),][1:20,]
print(human[order(human$fatalities.tot, decreasing=TRUE),][1:10,c(1:6)], quote=FALSE, row.names=FALSE)
print(human[order(human$pct.with.fatalities, decreasing=TRUE),][1:10,c(1:6)], quote=FALSE, row.names=FALSE)
# better
print(human[order(human$fatalities.tot, decreasing=TRUE),][1:10,c(1,5,2,3,4)], quote=FALSE, row.names=FALSE)
print(human[order(human$pct.with.fatalities, decreasing=TRUE),][1:10,c(1,4,2,3,5)], quote=FALSE, row.names=FALSE)

print(human[order(human$injuries.tot, decreasing=TRUE),][1:10,c(1,9,2,7,8)], quote=FALSE, row.names=FALSE)
print(human[order(human$pct.with.injuries, decreasing=TRUE),][1:10,c(1,8,2,7,9)], quote=FALSE, row.names=FALSE)

# ECONOMIC
#print(economic[order(economic$fatalities.tot, decreasing=TRUE),][1:10,c(1:6)], quote=FALSE, row.names=FALSE)
#print(economic[order(economic$fatalities.tot, decreasing=TRUE),][1:10,c(1:2,7:10)], quote=FALSE, row.names=FALSE)
print(economic[order(economic$pct.with.PropDmg, decreasing=TRUE),][1:10,c(1,4,2,3,5)], quote=FALSE, row.names=FALSE)
print(economic[order(economic$PropDmg.tot, decreasing=TRUE),][1:10,c(1,5,2,3,4)], quote=FALSE, row.names=FALSE)

print(economic[order(economic$CropDmg.tot, decreasing=TRUE),][1:10,c(1,9,2,7,8)], quote=FALSE, row.names=FALSE)
print(economic[order(economic$pct.with.CropDmg, decreasing=TRUE),][1:10,c(1,8,2,7,9)], quote=FALSE, row.names=FALSE)

#----------------------------------------------------------------------------
hum20ft <- human[order(human$F.tot, decreasing=TRUE),][1:20,]
hum20fp <- human[order(human$pct.with.F, decreasing=TRUE),][1:20,]
hum20it <- human[order(human$I.tot, decreasing=TRUE),][1:20,]
hum20ip <- human[order(human$pct.with.I, decreasing=TRUE),][1:20,]

ph.ft <- ggplot(data=hum20ft, aes(x=EVTYPE)) + theme_bw()
ph.fp <- ggplot(data=hum20fp, aes(x=EVTYPE)) + theme_bw()

hplot.f1 <- ph.ft + geom_bar(stat="identity", aes(y=F.tot), fill="red2") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Fatalities Count") + 
    ggtitle("Events Causing Fatalities")

hplot.f2 <- ph.fp + geom_bar(stat="identity", aes(y=pct.with.F), fill="red2") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Percentage") + ylim(c(-5,75)) +
    ggtitle("Fraction of Events Causing Fatalities")

grid.draw(rbind(ggplotGrob(hplot.f1), ggplotGrob(hplot.f2),  size="last"))
#----------------------------------------------------------------------------

eco20pt <- economic[order(economic$PrDmg.tot, decreasing=TRUE),][1:20,]
eco20pp <- economic[order(economic$pct.with.PrDmg, decreasing=TRUE),][1:20,]
eco20ct <- economic[order(economic$CrDmg.tot, decreasing=TRUE),][1:20,]
eco20cp <- economic[order(economic$pct.with.CrDmg, decreasing=TRUE),][1:20,]

pe.pt <- ggplot(data=eco20pt, aes(x=EVTYPE)) + theme_bw()
pe.pp <- ggplot(data=eco20pp, aes(x=EVTYPE)) + theme_bw()

eplot.p1 <- pe.pt + geom_bar(stat="identity", aes(y=F.tot), fill="red2") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Fatalities Count") + 
    ggtitle("Events Causing Fatalities")

eplot.p2 <- pe.pp + geom_bar(stat="identity", aes(y=pct.with.F), fill="red2") + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Percentage") + ylim(c(-5,75)) +
    ggtitle("Fraction of Events Causing Fatalities")

grid.draw(rbind(ggplotGrob(hplot.f1), ggplotGrob(hplot.f2),  size="last"))
#----------------------------------------------------------------------------
eco20plot <- economic[order(economic$PropDmg.tot, decreasing=TRUE),][1:20,]
eco20plot <- economic[order(economic$PropDmg.tot, decreasing=TRUE),][1:20,]
order.pdt <- order(eco20plot$PrDmg.tot, decreasing=TRUE)
order.pdp <- order(eco20plot$pct.with.PrDmg, decreasing=TRUE)
order.cdt <- order(eco20plot$CrDmg.tot, decreasing=TRUE)
order.cdp <- order(eco20plot$pct.with.CrDmg, decreasing=TRUE)
eco20plot$PrDmg.tot.rank <- rep(0,20) ;  eco20plot$PrDmg.tot.rank[order.pdt] <- 1:20
eco20plot$PrDmg.pct.rank <- rep(0,20) ;  eco20plot$PrDmg.pct.rank[order.pdp] <- 1:20
eco20plot$CrDmg.tot.rank <- rep(0,20) ;  eco20plot$CrDmg.tot.rank[order.cdt] <- 1:20
eco20plot$CrDmg.pct.rank <- rep(0,20) ;  eco20plot$CrDmg.pct.rank[order.cdp] <- 1:20
eco20plot$PrDmg.tot.rank <- factor(eco20plot$PrDmg.tot.rank, levels=1:20, ordered=TRUE)
eco20plot$PrDmg.pct.rank <- factor(eco20plot$PrDmg.pct.rank, levels=1:20, ordered=TRUE)
eco20plot$CrDmg.tot.rank <- factor(eco20plot$CrDmg.tot.rank, levels=1:20, ordered=TRUE)
eco20plot$CrDmg.pct.rank <- factor(eco20plot$CrDmg.pct.rank, levels=1:20, ordered=TRUE)

#------------------------------------------------
library("ggplot2")
library("grid")
library("RColorBrewer")
cols <- brewer.pal(3, "OrRd")
cols <- brewer.pal(3, "BuGn")
cols <- brewer.pal(10, "RdYlBu")
pal1 <- colorRampPalette(cols)
pal3 <- colorRampPalette(c("orange","red2"))
pal4 <- colorRampPalette(c("blue2","red2"))
pal5 <- colorRampPalette(c("red4","orange2","blue3"))

mypalette5 <- c("black","#D7191C","#FDDE41","#92C5DE","#0571B0")
pal2 <- colorRampPalette(mypalette5)

#-------------------------------------------------------
p <- ggplot(data=eco20plot, aes(x=EVTYPE)) + theme_bw()
#-------------------------------------------------------

p + geom_bar(stat="identity", aes(y=(PropDmg.tot/1e6))) + 
    xlab("Event Type") + ylab("Total Property Damages, Million of Dollars") + coord_flip()

#---------------------------------------------------------
ecoplot1 <- p + geom_bar(stat="identity", aes(y=(PrDmg.tot/1e6))) + coord_flip() + 
    xlab("Event Type") + ylab("Total Property Damages, Million of Dollars")

ecoplot1 <- p + geom_bar(stat="identity", aes(y=(PrDmg.tot)), fill="red2") + scale_y_log10() +
    xlab("Event Type") + ylab("Total Property Damages, Million of Dollars") + coord_flip(ylim=c(1e7,1e11))

ecoplot1c <- p + geom_bar(stat="identity", aes(y=PrDmg.tot/1.0e6, fill=PrDmg.tot.rank)) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    scale_y_log10() + coord_cartesian(ylim=c(1e1, 3e5)) +
    xlab("") + ylab("Damages (Million of Dollars)") +
    ggtitle("Total Property Damages by Event Type") 

# scale_fill_manual(values=pal2(20)) + 
# theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

ecoplot1b <- ecoplot1 +  coord_flip(ylim=c(1e7,1e11))

#---------------------------------------------------------
ecoplot2 <- p + geom_bar(stat="identity", aes(y=(PrDmg.pct)), fill="blue2") + scale_y_log10() +
    xlab("Event Type") + ylab("Average (per event) Property Damages, Dollars") + coord_flip(ylim=c(1e3,1e10))

ecoplot2 <- p + geom_bar(stat="identity", aes(y=(PrDmg.pct), fill=PrDmg.pct.rank)) + scale_y_log10() +
    xlab("Event Type") + ylab("Fraction of event") 

ecoplot2b <- ecoplot2 + coord_flip(ylim=c(1e3,1e10))

#  fix20col <- c("")
ecoplot2c <- p + geom_bar(stat="identity", aes(y=pct.with.PrDmg, bg=pal5(20), fill=PrDmg.pct.rank)) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Average (per event) Property Damages, Dollars")

ecoplot2c <- p + geom_bar(stat="identity", aes(y=pct.with.PrDmg, fill=PrDmg.pct.rank)) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Percentage") + ylim(c(-5,105)) +
    ggtitle("Fraction of Events Causing Damages")

#    scale_y_log10() + coord_cartesian(ylim=c(1e3, 1e10))+ 
#    scale_fill_manual(values=pal5(20)) + 
#   scale_fill_brewer(palette="Set1") + 

grid.draw(cbind(ggplotGrob(ecoplot1), ggplotGrob(ecoplot2),  size="last"))
grid.draw(rbind(ggplotGrob(ecoplot1c), ggplotGrob(ecoplot2c),  size="last"))

#--------------
p <- ggplot(data=eco20plot, aes(x=EVTYPE)) + theme_bw()
ecoplot2c <- p + geom_bar(stat="identity", aes(y=pct.with.PrDmg, fill=PrDmg.pct.rank)) + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none") + 
    xlab("Event Type") + ylab("Percentage") + ylim(c(-5,105)) +
    ggtitle("Fraction of Events Causing Damages")

#-----------------------------------------------------------
# plain-er plots [https://rpubs.com/kakahu/19842]

# par(mfrow=c(2,1))
# barplot(topFatal$x, names.arg = topFatal$Group.1, main = "Fatalities", cex.axis = 0.8, cex.names = 0.7, las = 2)
# barplot(topInjuries$x, names.arg = topInjuries$Group.1, main = "Injuries", cex.axis = 0.8, cex.names = 0.7, las = 2)
# par(mfrow=c(2,1))
# barplot(topPropLoss$x, names.arg = topPropLoss$Group.1, main = "Property Loss", cex.axis = 0.8, cex.names = 0.7, las = 2)
# barplot(topCropLoss$x, names.arg = topCropLoss$Group.1, main = "Crop Loss", cex.axis = 0.8, cex.names = 0.7, las = 2)

#-----------------------------------------------------------
# side-by-side with other package [https://rpubs.com/rvsh/stormdata]
library(grid)
library(gridExtra)

plot1 <- ggplot(fatalities, aes(x = reorder(EVTYPE, -FATALITIES), y = FATALITIES)) + 
         geom_bar(stat = "identity") + theme(axis.text.x=element_text(angle=90)) + xlab("Event Type") + 
	 ylab("Fatalities")
plot2 <- ggplot(injuries, aes(x = reorder(EVTYPE, -INJURIES), y = INJURIES)) + 
         geom_bar(stat = "identity") + theme(axis.text.x=element_text(angle=90)) + xlab("Event Type") + 
	 ylab("Injuries")
grid.arrange(plot1, plot2, ncol=2, main="Impact of Storm Events on Population Health")

#-----------------------------------------------------------
# plotted quantity SORTED [https://rpubs.com/bakebrain/storm]
library(lattice)
require(gridExtra)

storm.by_type <- storm.by_type[with(storm.by_type, order(-property.damage)), ]
property_damage.cumsum <- cumsum(storm.by_type$property.damage)
prop.cutoff <- max(which(property_damage.cumsum < (sum(storm.by_type$property.damage) / 100) * 90))
storm.prop <- storm.by_type[1:prop.cutoff,]

d1 <- barchart( property.damage/1000000000 ~ reorder(EVTYPE, -property.damage), 
         data=storm.prop, ylab="Damage in billion $", main="Property",
         scales=list(x=list(rot=45)))

storm.by_type <- storm.by_type[with(storm.by_type, order(-crop.damage)), ]
crop_damage.cumsum <- cumsum(storm.by_type$crop.damage)
crop.cutoff <- max(which(crop_damage.cumsum < (sum( storm.by_type$crop.damage) / 100) * 90))
storm.crop <- storm.by_type[1:crop.cutoff,]

d2 <- barchart(crop.damage/1000000000 ~ reorder(EVTYPE, -crop.damage), 
         data=storm.crop, ylab="Damage in billion $",  main="Crop",
         scales=list(x=list(rot=45)))

grid.arrange(d1, d2, ncol=2, main="Economic Damage")


