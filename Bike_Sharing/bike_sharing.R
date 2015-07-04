#---------------------------------------------------------------------------------------------------
# posted at https://github.com/pedrosan/DaInCh
#---------------------------------------------------------------------------------------------------
library("lubridate")
library("plyr")
library("ggplot2")

#---------------------------------------------------------------------------------------------------
Classes <- c("character", "character", "character", "character", "character")
data <- read.csv("bike_sharing_data.csv.gz", colClasses = Classes, nrows = 1804000, strip.white = TRUE)
colnames(data) <- c("bike", "station2", "station1", "time1", "time2")

# re-ordering columns
data <- data[, c(1,3,2,4,5)]

# converting strings into times
data$time1 <- ymd_hms(data$time1, tz = "US/Eastern")
data$time2 <- ymd_hms(data$time2, tz = "US/Eastern")

# adding trip duration in seconds
data$dt <- difftime(data$time2, data$time1, units = "secs")

# Sorting the data frame by bike and time1
i.sort <- order(data$bike, data$time1)
data <- data[i.sort, ]

row.names(data) <- NULL
#----------------------------------------------------------

# checking for NA
sum(is.na(data))

# checking number of "levels" 
length(unique(data$bike))      # 6549
length(unique(data$station1))  #  329 330?
length(unique(data$station2))  #  330 329?

# arrays of unique values for bike, station1, station2 IDs
bikes <- unique(data$bike)
stations1 <- unique(data$station1)
stations2 <- unique(data$station2)

# check station lists
stations1 %in% stations2  # all true
stations2 %in% stations1  # 1 false? the last one : "c564e3"
 
#===================================================================================================
# (A) AVERAGE TRIP DURATION (in seconds)
#----------------------------------------------------------
summary(as.numeric(data$dt))

#===================================================================================================
# (B) MINIMUM FRACTION OF MISSING DATA
#----------------------------------------------------------

# finding mis-matching stations over the full data set
bike.stats <- ddply(data, .(bike), summarize, 
                    Ntrips = length(time1),
                    mismatches = sum(station1[-1] != station2[1:(length(time1)-1)]), 
                    fraction = mismatches/Ntrips)

N.mismatches <- sum(bike.stats$mismatches)   ## 215592 total mismatches 
cat("## Number of non-matching consecutive stations : ", N.mismatches)

# Minimum-Original-Total = Existing data + Number of mismatches
min.missing.fraction <- N.mismatches / ( nrow(data) + N.mismatches )
cat("## Minimum fraction of data that must be missing from original data set : ", min.missing.fraction)

#===================================================================================================
# (C) AVERAGE TIME A BIKE SPENDS AT A STATION (in seconds)
#----------------------------------------------------------

# WHY ARE THERE NEGATIVE "PARKING" DURATION FOR OTHERWISE FINE-LOOKING TRIPS?!?!?!

# on the full dataset
main <- data[-nrow(data), ]
main$tdiff <- difftime(data$time1[-1], data$time2[-nrow(data)])
main$flag.combined <- (data$station1[-1] == data$station2[-nrow(data)]) & (data$bike[-1] == data$bike[-nrow(data)])
main$flag.station <- c(main$station1[-1] == main$station2[-nrow(main)], NA)
main[main$flag.combined & as.numeric(main$tdiff) < 0, ]

# There are 43 valid (same bike, same station) parking intervals with NEGATIVE DURATION
neg.rows <- (1:nrow(main))[main$flag.combined & as.numeric(main$tdiff) < 0]
rows2check <- sort(c(neg.rows, (neg.rows-1), (neg.rows+1)))
main[rows2check, ]

# I guess I can ignore them... 43/1.8M
good.tdiff <- main$tdiff[main$flag.combined & as.numeric(main$tdiff) > 0]
length(good.tdiff)
## 1580813

summary(as.numeric(good.tdiff))
##   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##     1     433    1721   10090    7115 4088000  


#===================================================================================================
# (D) MAJOR QUALITATIVE USAGE PATTERNS FOR STATION 'fe2a5f' AND HOW IT DIFFERS FROM STATION 'fec8ff'
#----------------------------------------------------------
sid1 <- "fe2a5f"
sid2 <- "fec8ff"

# station 1
st1 <- subset(data, station1 == sid1 | station2 == sid1)
st1$t1hc <- (hour(st1$time1)*60 + minute(st1$time1))/60.0
st1$t2hc <- (hour(st1$time2)*60 + minute(st1$time2))/60.0
temp <- wday(st1$time1) - 1 
st1$wday1 <- ifelse(temp == 0, 7, temp)
temp <- wday(st1$time2) - 1 
st1$wday2 <- ifelse(temp == 0, 7, temp)
st1$flag_day <- ifelse(st1$wday1 <= 5, "M-F", "WeekEnd")

st1$flag_out <- st1$station1 == sid1
st1$flag_in  <- st1$station2 == sid1
st1$flag_both <- (st1$station1 == sid1) & (st1$station2 == sid1)
st1$type <- NA
st1$type[st1$flag_in] <- 'in'
st1$type[st1$flag_out] <- 'out'

st1$ID <- sid1

# station 2
st2 <- subset(data, station1 == sid2 | station2 == sid2)
st2$t1hc <- (hour(st2$time1)*60 + minute(st2$time1))/60.0
st2$t2hc <- (hour(st2$time2)*60 + minute(st2$time2))/60.0
temp <- wday(st2$time1) - 1 
st2$wday1 <- ifelse(temp == 0, 7, temp)
temp <- wday(st2$time2) - 1 
st2$wday2 <- ifelse(temp == 0, 7, temp)
st2$flag_day <- ifelse(st2$wday1 <= 5, "M-F", "WeekEnd")

st2$flag_out <- st2$station1 == sid2
st2$flag_in  <- st2$station2 == sid2
st2$flag_both <- (st2$station1 == sid2) & (st2$station2 == sid2)
st2$type <- NA
st2$type[st2$flag_in] <- 'in'
st2$type[st2$flag_out] <- 'out'

st2$ID <- sid2

# combine them
both <- rbind(st1, st2)
both$ID <- as.factor(both$ID)
both$type <- as.factor(both$type)
both$flag_day <- as.factor(both$flag_day)

#---------
# PLOTS

mycolors1 <- c("violetred1", "darkgreen")
mycolors2 <- c("red2", "gold")

### by hour
p1  <- ggplot(data = both, aes(x = t1hc, fill = ID)) + theme_bw() + xlab("hour of the day") + theme(legend.position="none") 
p1b <- ggplot(data = both, aes(x = t1hc, fill = type)) + theme_bw() + xlab("hour of the day")
p1c <- ggplot(data = subset(both, flag_day == "M-F"), aes(x = t1hc, fill = type)) + theme_bw() + xlab("hour of the day")

# density plot
png(file = "by_hour.png", height = 1024, width = 1024, res = 144)
p1 + geom_density(alpha = 0.3) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")
p1b + geom_density(alpha = 0.3) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Dark2")
p1b + geom_density(alpha = 0.3) + facet_wrap(~ ID, ncol = 1) + scale_fill_manual(values = c("red", "navyblue"))

p1c + geom_density(alpha = 0.3) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")
p1b + geom_density(alpha = 0.3) + facet_wrap(~ flag_day + ID, ncol = 2) + scale_fill_brewer(palette = "Set1")
dev.off()

# histogram
p1 +  geom_histogram(colour = "grey50", binwidth = 0.5, alpha = 0.5) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")
p1b +  geom_histogram(colour = "grey50", binwidth = 0.5, alpha = 0.5) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")
p1c +  geom_histogram(colour = "grey50", binwidth = 0.5, alpha = 0.5) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")

### by week day
p2 <- ggplot(data = both, aes(x = as.factor(wday1), fill = ID)) + theme_bw() + xlab("day of the week") + theme(legend.position="none") 

# histogram
png(file = "by_wday.png", height = 1024, width = 1024, res = 144)
p2 +  geom_bar(stat = "bin", alpha = 0.5, width = 0.8) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")
dev.off()

# histogram w/ free Y-scale
png(file = "by_wday_alt.png", height = 1024, width = 1024, res = 144)
p2 +  geom_bar(stat = "bin", alpha = 0.8, width = 0.8) + facet_wrap(~ ID, ncol = 1, scale = "free_y") + scale_fill_brewer(palette = "Set2")
dev.off()


#===================================================================================================
# (E) ESTIMATE THE NUMBER OF BIKES AT STATIONS '8f0f64' and '4a4b61' FOR EACH HOUR ON THE HOUR 
#     OF 2013/10/30
#----------------------------------------------------------

# want to work with a new data frame
T_at_St <- data[, c(1, 3, 5, 2, 4)]
colnames(T_at_St) <- c("bike", "St_in", "T_in", "St_out", "T_out")

nl <- nrow(T_at_St)
jj <- c( seq(2, nl), 1 )

# shifting columns to align time and stations of the potential arrive-depart intervals
T_at_St$St_out <- T_at_St$St_out[jj]
T_at_St$T_out  <- T_at_St$T_out[jj]
T_at_St <- T_at_St[-nl, ]

T_at_St$T_park <- difftime(T_at_St$T_out, T_at_St$T_in)
T_at_St$flag.station <- T_at_St$St_in == T_at_St$St_out

bound1 <- force_tz(ymd_hms("2013-10-30 00:00:00"), "US/Eastern")
bound2 <- force_tz(ymd_hms("2013-10-30 23:59:59"), "US/Eastern")
interval <- as.interval(86399, bound1)

sid1 <- "8f0f64" 
sid2 <- "4a4b61"

oct30 <- T_at_St[T_at_St$T_in %within% interval | T_at_St$T_out %within% interval, ]
st1 <- subset(oct30, (St_in == sid1 | St_out == sid1) )
st2 <- subset(oct30, (St_in == sid2 | St_out == sid2) )

st1$flag.in  <- st1$St_in  == sid1
st1$flag.out <- st1$St_out == sid1
st1$flag.within <- st1$flag.in & st1$flag.out
st1$check <- 1*st1$flag.in + 2*st1$flag.out + 4*st1$flag.within

st1$flag.T.in  <- st1$T_in  >= bound1
st1$flag.T.out <- st1$T_out <= bound2
st1$flag.T.within <- st1$flag.T.in & st1$flag.T.out 
st1$check.T <- 1*st1$flag.T.in + 2*st1$flag.T.out + 4*st1$flag.T.within

st2$flag.in  <- st2$St_in  == sid2
st2$flag.out <- st2$St_out == sid2
st2$flag.within <- st2$flag.in & st2$flag.out
st2$check <- 1*st2$flag.in + 2*st2$flag.out + 4*st2$flag.within

st2$flag.T.in  <- st2$T_in  >= bound1
st2$flag.T.out <- st2$T_out <= bound2
st2$flag.T.within <- st2$flag.T.in & st2$flag.T.out 
st2$check.T <- 1*st2$flag.T.in + 2*st2$flag.T.out + 4*st2$flag.T.within

st1.condition1 <- st1$check == 7 & st1$check.T == 7 
st1.cond.xbad  <- (st1$check + st1$check.T) == 3
st1.cond.clean <- st1$check == 7 & st1$check.T == 7

st2.condition1 <- st2$check == 7 & st2$check.T == 7 
st2.cond.xbad  <- (st2$check + st2$check.T) == 3
st2.cond.clean <- st2$check == 7 & st2$check.T == 7

# Some combinations of In/Out stations and times (e.g. out of the bounds of 10/30)
# that would give open intervals, or intervals with undefined left/right boundaries
# could be handled by making some assumptions about how long a bicycle could have been there 
# or could have stayed there.
# For simplicity I kept only intervals with the same In/Out station and with In/Out times
# fully within the chosen date.
best1 <- st1[st1.cond.clean, ]
best2 <- st2[st2.cond.clean, ]

# Finally preparing the presence stats...
st1.x1 <- hour(best1$T_in) + 1 + 1
st1.x2 <- hour(best1$T_out) + 1
st1.x1 <- ifelse(st1.x1 > 24, 23, st1.x1)
st1.x2 <- ifelse(st1.x2 > 24, 23, st1.x2)

presence1 <- matrix(0, nrow = nrow(best1), ncol = 24)
for(j in 1:nrow(best1)) {
    presence1[j, st1.x1[j]:st1.x2[j]] <- 1
}
byHour1 <- colSums(presence1)

st2.x1 <- hour(best2$T_in) + 1 + 1
st2.x2 <- hour(best2$T_out) + 1
st2.x1 <- ifelse(st2.x1 > 24, 23, st2.x1)
st2.x2 <- ifelse(st2.x2 > 24, 23, st2.x2)

presence2 <- matrix(0, nrow = nrow(best2), ncol = 24)
for(j in 1:nrow(best2)) {
    presence2[j, st2.x1[j]:st2.x2[j]] <- 1
}
byHour2 <- colSums(presence2)

df1 <- data.frame(ID = sid1, hour = 0:23, number = byHour1)
df2 <- data.frame(ID = sid2, hour = 0:23, number = byHour2)
df <- rbind(df1, df2)

p3 <- ggplot(data = df, aes(x = hour, y = number, fill = ID)) + theme_bw() + xlab("hour") + theme(legend.position="none") 

# histogram
png(file = "bikes_at_stations_by_hour.png", height = 1024, width = 1024, res = 144)
p3 +  geom_bar(stat = "identity", alpha = 0.5, width = 0.8) + facet_wrap(~ ID, ncol = 1) + scale_fill_brewer(palette = "Set1")
dev.off()

df.wide <- data.frame(hour = 0:23, station1 = byHour1, station2 = byHour2)
colnames(df.wide) <- c("hour", sid1, sid2)

write.csv(df, file = "presence_by_hour_v2.csv", row.names = FALSE, quote = FALSE)

#===================================================================================================
# (F) PREDICT THE NUMBER OF BICYCLES ARRIVING AT STATIONS "912d97" "2da8d7" "010d01" "36ba2f" "fa4911"
# ON 2013-11-26 IN EACH HOUR
#----------------------------------------------------------

sid1 <- "912d97"
sid2 <- "2da8d7"
sid3 <- "010d01"
sid4 <- "36ba2f"
sid5 <- "fa4911"

