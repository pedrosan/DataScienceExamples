
## ---- my_defs

tidy_df <- function( data ) {
    for(i in 8:159) { 
        data[,i] <- as.numeric(data[,i])
    }
    colnames(data) <- gsub("_picth", "_pitch", colnames(data), perl=TRUE)
    colnames(data) <- gsub("var_total_accel_", "var_accel_", colnames(data), perl=TRUE)
    colnames(data) <- gsub("roll_belt.1", "pitch_belt", colnames(data), perl=TRUE)
    return(data)
}

add_new_variables <- function( data ) { 
    data$classe <- as.factor(data$classe)
    data$timestamp <- data$raw_timestamp_part_1 + data$raw_timestamp_part_2
    data$date <- strptime(as.character(data$cvtd_timestamp), "%d/%m/%Y %H:%M")
    return(data)
}

select_proper_vars <- function( data ) {
    vec0 <- c("total_accel", "var_accel")
    
    nn1 <- c("avg", "stddev", "var", "kurtosis", "skewness", "min", "max", "amplitude")
    vec1 <- c("roll", paste(nn1, "roll", sep="_"), 
              "pitch", paste(nn1, "pitch", sep="_"), 
              "yaw", paste(nn1, "yaw", sep="_"))
    
    nn2 <- c("gyros", "accel", "magnet")
    vec2 <- paste( rep(nn2, each=3), "VVV", c("x","y","z"), sep="_")
    
    vec.VVV <- c(paste(c("total_accel", "var_accel", vec1), "VVV", sep="_"), vec2)
    vec.belt <- gsub("_VVV", "_belt", vec.VVV, perl=TRUE)
    vec.arm <- gsub("_VVV", "_arm", vec.VVV, perl=TRUE)
    vec.forearm <- gsub("_VVV", "_forearm", vec.VVV, perl=TRUE)
    vec.dumbbell <- gsub("_VVV", "_dumbbell", vec.VVV, perl=TRUE)
    i.classe <- which( colnames(data) == "classe")
    
    if( length(i.classe) > 0 ) {
        select <- data[, c("classe", vec.belt, vec.arm, vec.forearm, vec.dumbbell)]
    } else {
        select <- data[, c("problem_id", vec.belt, vec.arm, vec.forearm, vec.dumbbell)]
    }
    return(select)
}

# define color palettes
color1 <- colorRampPalette(c("#7F0000", "red", "#FF7F00", "yellow", "white", 
                             "cyan", "#007FFF", "blue", "#00007F"))

color2 <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7",
                           "#FFFFFF", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061"))	

color3 <- colorRampPalette(c("red", "white", "blue"))	

# correct answers
answers <- c("B", "A", "B", "A", "A", "E", "D", "B", "A", "A", 
             "B", "C", "B", "A", "E", "E", "A", "B", "B", "B")

## ---- end-of-my_defs

