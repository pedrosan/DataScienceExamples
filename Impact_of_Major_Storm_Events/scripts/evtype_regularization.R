
## ---- regularization

cat("# Entering 'evtype_regularization' script\n")
TESTvec <- good$EVTYPE

TESTvec <- gsub("^SNOW$", "HEAVY SNOW", TESTvec, perl=TRUE)
TESTvec <- gsub("^WIND$", "HIGH WIND", TESTvec, perl=TRUE)
TESTvec <- gsub("^WINDS$", "HIGH WIND", TESTvec, perl=TRUE)
TESTvec <- gsub("^ICE$", "ICE STORM", TESTvec, perl=TRUE)
TESTvec <- gsub("^UNSEASONABLY WARM$", "HEAT", TESTvec, perl=TRUE)
TESTvec <- gsub("^TORNDAO$", "TORNADO", TESTvec, perl=TRUE)
TESTvec <- gsub("^WAYTERSPOUT$", "WATERSPOUT", TESTvec, perl=TRUE)
TESTvec <- gsub("^EXTREME HEAT$", "EXCESSIVE HEAT", TESTvec, perl=TRUE)
TESTvec <- gsub("^LIGHT FREEZING RAIN$", "SLEET", TESTvec, perl=TRUE)
TESTvec <- gsub("^UNSEASONABLY DRY$", "DROUGHT", TESTvec, perl=TRUE)
TESTvec <- gsub("^TSTM HEAVY RAIN$", "HEAVY RAIN", TESTvec, perl=TRUE)
TESTvec <- gsub("^SMALL HAIL$", "HAIL", TESTvec, perl=TRUE)
TESTvec <- gsub("^$EXCESSIVE SNOW", "HEAVY SNOW", TESTvec, perl=TRUE)

TESTvec[grepl("^ASTRONOMICAL", TESTvec, perl=TRUE)] <- "ASTRONOMICAL LOW TIDE"
TESTvec[grepl("^AVALA", TESTvec, perl=TRUE)] <- "AVALANCHE"
TESTvec[grepl("^BEACH", TESTvec, perl=TRUE)] <- "COASTAL FLOOD"
TESTvec[grepl("^BITTER", TESTvec, perl=TRUE)] <- "EXTREME COLD/WIND CHILL"
TESTvec[grepl("^BLIZZARD", TESTvec, perl=TRUE)] <- "BLIZZARD"
TESTvec[grepl("^BRUSH FIRE", TESTvec, perl=TRUE)] <- "WILDFIRE"
TESTvec[grepl("^COASTAL", TESTvec, perl=TRUE)] <- "COASTAL FLOOD"
TESTvec[grepl("^DROUGHT", TESTvec, perl=TRUE)] <- "DROUGHT"
TESTvec[grepl("^DUST D", TESTvec, perl=TRUE)] <- "DUST DEVIL"
TESTvec[grepl("^EXCESSIVE H", TESTvec, perl=TRUE)] <- "EXCESSIVE HEAT"
TESTvec[grepl("^EXTREME [CW]", TESTvec, perl=TRUE)] <- "EXTREME COLD/WIND CHILL"
TESTvec[grepl("^FLASH", TESTvec, perl=TRUE)] <- "FLASH FLOOD"
TESTvec[grepl("^FLO.*FLA", TESTvec, perl=TRUE)] <- "FLASH FLOOD"
TESTvec[grepl("^HYP", TESTvec, perl=TRUE)] <- "EXTREME COLD/WIND CHILL"
TESTvec[grepl("^LIGHT[A-Z]", TESTvec, perl=TRUE)] <- "LIGHTNING"
TESTvec[grepl("^LANDSL", TESTvec, perl=TRUE)] <- "DEBRIS FLOW"
TESTvec[grepl("^HAIL", TESTvec, perl=TRUE)] <- "HAIL"
TESTvec[grepl("^HEAT WAVE", TESTvec, perl=TRUE)] <- "EXCESSIVE HEAT"
TESTvec[grepl("^HEAVY PR", TESTvec, perl=TRUE)] <- "HEAVY RAIN"
TESTvec[grepl("^HEAVY RAIN", TESTvec, perl=TRUE)] <- "HEAVY RAIN"
TESTvec[grepl("^HEAVY SNOW", TESTvec, perl=TRUE)] <- "HEAVY SNOW"
TESTvec[grepl("^HEAVY SURF", TESTvec, perl=TRUE)] <- "HIGH SURF"
TESTvec[grepl("^HIGH S[UW]", TESTvec, perl=TRUE)] <- "HIGH SURF"
TESTvec[grepl("^MARINE T", TESTvec, perl=TRUE)] <- "MARINE THUNDERSTORM WIND"
TESTvec[grepl("^MINOR FL", TESTvec, perl=TRUE)] <- "FLOOD"
TESTvec[grepl("^MIXED PR", TESTvec, perl=TRUE)] <- "SLEET"
TESTvec[grepl("^MUD", TESTvec, perl=TRUE)] <- "DEBRIS FLOW"
TESTvec[grepl("^RECORD C", TESTvec, perl=TRUE)] <- "EXTREME COLD/WIND CHILL"
TESTvec[grepl("^RECORD H", TESTvec, perl=TRUE)] <- "EXCESSIVE HEAT"
TESTvec[grepl("^RECORD WA", TESTvec, perl=TRUE)] <- "EXCESSIVE HEAT"
TESTvec[grepl("^RIP", TESTvec, perl=TRUE)] <- "RIP CURRENT"
TESTvec[grepl("^R.*FLOOD", TESTvec, perl=TRUE)] <- "FLOOD"
TESTvec[grepl("^SEVERE TH", TESTvec, perl=TRUE)] <- "THUNDERSTORM WIND"
TESTvec[grepl("^SLEET", TESTvec, perl=TRUE)] <- "SLEET"
TESTvec[grepl("^SMALL STR", TESTvec, perl=TRUE)] <- "FLOOD"
TESTvec[grepl("^STRONG W", TESTvec, perl=TRUE)] <- "STRONG WIND"
TESTvec[grepl("^TIDAL FL", TESTvec, perl=TRUE)] <- "COASTAL FLOOD"
TESTvec[grepl("^TORRENTIAL", TESTvec, perl=TRUE)] <- "HEAVY RAIN"
TESTvec[grepl("^TROPICAL STORM", TESTvec, perl=TRUE)] <- "TROPICAL STORM"
TESTvec[grepl("^TSTM W", TESTvec, perl=TRUE)] <- "THUNDERSTORM WIND"
TESTvec[grepl("^URBAN", TESTvec, perl=TRUE)] <- "FLOOD"
TESTvec[grepl("^UNSEASO.* CO", TESTvec, perl=TRUE)] <- "COLD/WIND CHILL"
TESTvec[grepl("^WINTER ST", TESTvec, perl=TRUE)] <- "WINTER STORM"
TESTvec[grepl("^WINTER W", TESTvec, perl=TRUE)] <- "WINTER WEATHER"
TESTvec[grepl("^WATER", TESTvec, perl=TRUE)] <- "WATERSPOUT"
TESTvec[grepl("^WILD", TESTvec, perl=TRUE)] <- "WILDFIRE"
TESTvec[grepl("^WIND CHILL", TESTvec, perl=TRUE)] <- "COLD/WIND CHILL"
TESTvec[grepl("^VOLCANIC", TESTvec, perl=TRUE)] <- "VOLCANIC ASH"


TESTvec[grepl("[VF]OG", TESTvec, perl=TRUE)] <- "FOG GENERAL"
TESTvec[grepl("TYPHOON", TESTvec, perl=TRUE)] <- "HURRICANE"
TESTvec[grepl("SMOKE", TESTvec, perl=TRUE)] <- "DENSE SMOKE"
TESTvec[grepl("FIRES", TESTvec, perl=TRUE)] <- "WILDFIRE"
TESTvec[grepl("SQUALL", TESTvec, perl=TRUE)] <- "HEAVY SNOW"
TESTvec[grepl("EROSION", TESTvec, perl=TRUE)] <- "COASTAL FLOOD"
TESTvec[grepl("^SNOW.*ICE", TESTvec, perl=TRUE)] <- "ICE STORM"
TESTvec[grepl("^SNOW.*SLEET", TESTvec, perl=TRUE)] <- "SLEET"
TESTvec[grepl("^SNOW.*RAIN", TESTvec, perl=TRUE)] <- "SLEET"
TESTvec[grepl("LAKE.*SNOW", TESTvec, perl=TRUE)] <- "LAKE-EFFECT SNOW"
TESTvec[grepl("LAKE.*FLOOD", TESTvec, perl=TRUE)] <- "LAKESHORE FLOOD"
TESTvec[grepl("HURRICANE-GENERATED SWELLS", TESTvec, perl=TRUE)] <- "STORM SURGE"

TESTvec[grepl("^HURRICANE", TESTvec, perl=TRUE)] <- "HURRICANE"             # after |HURRICANE-GENERATED SWELLS

TESTvec[grepl("^ICE[ /S][A-EO-T]", TESTvec, perl=TRUE)] <- "ICE STORM"      # after |[VF]OG
TESTvec[grepl("^FREEZING [DR]", TESTvec, perl=TRUE)] <- "SLEET"             # after |[VF]OG
TESTvec[grepl("^WINT.* MIX", TESTvec, perl=TRUE)] <- "SLEET"                # after |^WINTER W
TESTvec[grepl("SURGE", TESTvec, perl=TRUE)] <- "STORM SURGE"                # after |^COASTAL
TESTvec[grepl("FUNNEL", TESTvec, perl=TRUE)] <- "FUNNEL CLOUD"              # after |^WATER
TESTvec[grepl("TORNADO", TESTvec, perl=TRUE)] <- "TORNADO"                  # after |^WATER
TESTvec[grepl("DUST", TESTvec, perl=TRUE)] <- "DUST STORM"                  # after |^DUST D
TESTvec[grepl("^HIGH WIN", TESTvec, perl=TRUE)] <- "HIGH WIND"              # after |DUST
TESTvec[grepl("^FLOOD", TESTvec, perl=TRUE)] <- "FLOOD"                     # after |^FLO.*FLA

TESTvec[grepl("^COLD", TESTvec, perl=TRUE)] <- "COLD/WIND CHILL"            # after |FUNNEL  , |TORNADO
TESTvec[grepl("^THUNDERSTORM", TESTvec, perl=TRUE)] <- "THUNDERSTORM WIND"  # after |FUNNEL
TESTvec[grepl("^THU.*TOR.*WI", TESTvec, perl=TRUE)] <- "THUNDERSTORM WIND"  # after |FUNNEL

cat("# Leaving 'evtype_regularization' script\n")

## ---- end-of-regularization

