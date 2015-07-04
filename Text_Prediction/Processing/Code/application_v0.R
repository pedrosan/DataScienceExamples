#---------------------------------------------------------------------------------------------------
# LIBRARIES
#-------------------

library("plyr")
library("dplyr")

#---------------------------------------------------------------------------------------------------
# FUNCTIONS
#---------------------------------------------------------------------------------------------------
source("./scripts/my_functions.R")

# appData <- list(
#     all3 = all3, 
#     all4 = all4, 
#     all5 = all5,
#     all6 = all6,
#     word_counts = word_counts)
# 
# save(appData, file = "appData.RData")

appData_wall <- list(
    all3 = n3a_wall, 
    all4 = n4a_wall, 
    all5 = n5a_wall,
    all6 = n6a_wall)

save(appData_wall, file = "appData_wall.RData")

#---------------------------------------------------------------------------------------------------
# NOTE: for ngrams 3-5 only those with count > are loaded

n3a <- filter(all3, freq >  2)
n3b <- all3

n4a <- filter(all4, freq >  2)
n4b <- all4

n5a <- filter(all5, freq >  2)
n5b <- all5

n6a <- all6

all3 <- readRDS("../all3.RDS")
all4 <- readRDS("../all4.RDS")
all5 <- readRDS("../all5.RDS")
all6 <- readRDS("../all6.RDS")

all3$wall <- NULL
all4$wall <- NULL
all5$wall <- NULL
all6$wall <- NULL

#--------------------------------------
# splitting of all6 in 3 chunks
#--------------------------------------
nrow(all6)
set.seed(1)
shuffled_idx <- sample(1:nrow(all6), replace = FALSE)

n1chunks <- ceiling(nrow(all6)/3)
n2chunks <- n1chunks
n3chunks <- nrow(all6) - 2*n1chunks
idx1 <- shuffled_idx[1:n1chunks]
idx2 <- shuffled_idx[(n1chunks+1):(n1chunks+n2chunks)]
idx3 <- shuffled_idx[(n1chunks+n2chunks+1):nrow(all6)]

#--------------------------------------
# splitting of all6 in 2 chunks
#--------------------------------------
n1chunks <- ceiling(nrow(all6)/2)
idx1 <- shuffled_idx[1:n1chunks]
idx2 <- shuffled_idx[(n1chunks+1):nrow(all6)]

all6_lean_p1 <- all6[idx1, ]
all6_lean_p2 <- all6[idx2, ]

#---------------------------------------------------------------------------------------------------
n3a <- readRDS("./data/n3_gt2_words.RDS")
n4a <- readRDS("./data/n4_gt2_words.RDS")
n5a <- readRDS("./data/n5_gt2_words.RDS")
n6a <- readRDS("./data/n6_words_50pct.RDS")
# n6b <- readRDS("./data/n6b.RDS")
# n6c <- readRDS("./data/n6c.RDS")

n3a <- mutate(n3a, wall = paste(w1, w2, sep = " "))
n4a <- mutate(n4a, wall = paste(w1, w2, w3, sep = " "))
n5a <- mutate(n5a, wall = paste(w1, w2, w3, w4, sep = " "))
n6a <- mutate(n6a, wall = paste(w1, w2, w3, w4, w5, sep = " "))

#---------------------------------------------------------------------------------------------------
# for alternative method
n6a_new <- sapply(n6a_wall$wall, FUN = function(x) {unlist(strsplit(x, " +"))}, USE.NAMES = FALSE)

n6a_selected <- n6a_wall[sample(1:nrow(n6a_wall), 50000), ]
row.names(n6a_selected) <- NULL

n6a_new <- sapply(n6a_selected$wall, FUN = function(x) {unlist(strsplit(x, " +"))}, USE.NAMES = FALSE)
n6a_new <- unlist(strsplit(n6a_selected$wall, split = " +"))

n6a_split <- strsplit(n6a_wall$wall, split = " +")
nw <- sapply(n6a_split, FUN = function(x) {length(x)})
n6a_words <- ldply(n6a_split[1:10])
colnames(n6a_words) <- paste0("w", 1:5)

n6a_words <- ldply(strsplit(n6sel$wall, split = " +"))
colnames(n6a_words) <- paste0("w", 1:5)


#---------------------------------------------------------------------------------------------------
# input_text <- c("just", "another", "song")
# input_text <- "after many, years"
# input_text <- "after few years"
# input_text <- "you can make some important" # "changes"
# input_text <- "a reminder that racial" #"injustice"
# input_text <- "a Reminder   that racial" #"injustice"
# input_text <- "versed in the rise and fall of powers and the vanity of" # ambition"
# input_text <- "still waiting for a date for an appeal hearing at the supreme" #  court"
# input_text <- "I am very tired a need to take"  # vacation
# 
input_text <- "I can't wait to see"
# input_text <- "Rome wasn't built in a"
input_text <- "tomorrow I would like to go to"

input_refmt <- system2("./scripts/regularize_for_R.pl", input = input_text, stdout = TRUE)

words_all <- unlist(strsplit(input_refmt, split = "[ ;,.\"\t\r\n()!?:]+"))
nwords <- min(5, length(words_all))

#-----------------------------------------------------------
# keeps only 5 words if there are more after regularization
#-----------------------------------------------------------
if( nwords >= 5 ) {
    words_select <- words_all[(length(words_all)-4):length(words_all)]
} else {
    words_select <- words_all
}

#-----------------------------------------------------------
# checks matches and counts on dictionary
#-----------------------------------------------------------
wcounts <- rep(0, nwords)
for(i in 1:nwords) {
    # cat(" word ", i, " : ", words_select[i], "\n")
    if(nchar(words_select[i]) >= 3) {
        temp <- sum(word_counts$count[grep(paste0("^", words_select[i]), word_counts$word, perl = TRUE)])
        if(temp > 0 ) { 
            wcounts[i] <- sum(word_counts$count[grep(paste0("^", words_select[i]), word_counts$word, perl = TRUE)])
        }
    }
}

n3sel <- select_ngrams(ngrams = n3a, words = words_select, wcounts = wcounts, wc_threshold = 160000) 
n4sel <- select_ngrams(ngrams = n4a, words = words_select, wcounts = wcounts, wc_threshold = 160000) 
n5sel <- select_ngrams(ngrams = n5a, words = words_select, wcounts = wcounts, wc_threshold = 160000) 
n6sel <- select_ngrams(ngrams = n6a, words = words_select, wcounts = wcounts, wc_threshold = 160000) 

#---------------------------------------------------------------------------------------------------

#---------------------------------------
# Trimming of the word list.
# OBSOLETE?
#---------------------------------------
# if(length(words_select) < 4) {
#     words <- words_select
# } else {
#     words <- words_select[-which.max(wcounts)]
#     wc <- wcounts[-which.max(wcounts)]
#     words <- words[-which.max(wc)]
#     wc <- wc[-which.max(wc)]
# }

words <- words_select

dummy.df <- data.frame(pred = "dummy", freq = 0, wall = "", weight = 0, stringsAsFactors = FALSE)

#---------------------------------------
# matching and weigthing parameters
#---------------------------------------
N_try <- 6

n6_base_sensitivity <- 0.10
n6_weight <- 2.0

n5_base_sensitivity <- 0.10
n5_weight <- 1.5

n4_base_sensitivity <- 0.10
n4_weight <- 1.25

n3_base_sensitivity <- 0.10
n3_weight <- 0.75;

#---------------------------------------

#-------------------
n6w <- n6sel
n6_sensitivity <- n6_base_sensitivity 

for(k in 1:N_try) {
    n6_3456   <- n6w[agrep(paste(words, collapse = " "), paste(n6w$w3, n6w$w4, n6w$w5, n6w$w6, sep = " "), fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall")]
    n6_2456   <- n6w[agrep(paste(words, collapse = " "), paste(n6w$w2, n6w$w4, n6w$w5, n6w$w6, sep = " "), fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall")]
    n6_2356   <- n6w[agrep(paste(words, collapse = " "), paste(n6w$w2, n6w$w3, n6w$w5, n6w$w6, sep = " "), fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall")]
    n6_2346   <- n6w[agrep(paste(words, collapse = " "), paste(n6w$w2, n6w$w3, n6w$w4, n6w$w6, sep = " "), fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall")]
    n6_1456   <- n6w[agrep(paste(words, collapse = " "), paste(n6w$w1, n6w$w3, n6w$w4, n6w$w5, sep = " "), fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall")]
    n6_1345   <- n6w[agrep(paste(words, collapse = " "), paste(n6w$w1, n6w$w2, n6w$w4, n6w$w6, sep = " "), fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall")]
    n6_all    <- n6w[agrep(paste(words, collapse = " "), n6w$wall, fixed = FALSE, max = n6_sensitivity), c("pred", "freq", "wall") ]
    
    n6_summary <- dummy.df
    if(nrow(n6_3456) > 0 ) { n6_3456$weight <- 3.0*n6_weight ; n6_summary <- rbind(n6_summary, n6_3456)}
    if(nrow(n6_2456) > 0 ) { n6_2345$weight <- 3.0*n6_weight ; n6_summary <- rbind(n6_summary, n6_2456)}
    if(nrow(n6_2356) > 0 ) { n6_2356$weight <- 2.0*n6_weight ; n6_summary <- rbind(n6_summary, n6_2356)}
    if(nrow(n6_2346) > 0 ) { n6_2346$weight <- 2.0*n6_weight ; n6_summary <- rbind(n6_summary, n6_2346)}
    if(nrow(n6_1456) > 0 ) { n6_1456$weight <- 1.5*n6_weight ; n6_summary <- rbind(n6_summary, n6_1456)}
    if(nrow(n6_1345) > 0 ) { n6_1345$weight <- 1.5*n6_weight ; n6_summary <- rbind(n6_summary, n6_1345)}
    row.names(n6_summary) <- NULL

    cat(" [", k, "] n6_summary : ", nrow(n6_summary), " at sensitivity = ", n6_sensitivity, "\n")
    if(nrow(n6_summary) > 1 && nrow(n6_summary) < 200) { break }
    if(nrow(n6_summary) == 1)  { n6_sensitivity <- n6_sensitivity + 0.025 }
    if(nrow(n6_summary) > 200) { n6_sensitivity <- n6_sensitivity - 0.025 }
}

#-------------------
n5w <- n5sel
n5_sensitivity <- n5_base_sensitivity 

for(k in 1:N_try) {
    n5_234 <- n5w[agrep(paste(words, collapse = " "), paste(n5w$w2, n5w$w3, n5w$w4, sep = " "), fixed = FALSE, max = n5_sensitivity), c("pred", "freq", "wall")]
    n5_134 <- n5w[agrep(paste(words, collapse = " "), paste(n5w$w1, n5w$w3, n5w$w4, sep = " "), fixed = FALSE, max = n5_sensitivity), c("pred", "freq", "wall")]
    n5_124 <- n5w[agrep(paste(words, collapse = " "), paste(n5w$w1, n5w$w2, n5w$w4, sep = " "), fixed = FALSE, max = n5_sensitivity), c("pred", "freq", "wall")]
    n5_123 <- n5w[agrep(paste(words, collapse = " "), paste(n5w$w1, n5w$w2, n5w$w3, sep = " "), fixed = FALSE, max = n5_sensitivity), c("pred", "freq", "wall")]
    n5_all <- n5w[agrep(paste(words, collapse = " "), n5w$wall, fixed = FALSE, max = n5_sensitivity), c("pred", "freq", "wall") ]
    
    n5_summary <- dummy.df
    if(nrow(n5_all) > 0 ) { n5_all$weight <- 3.0*n5_weight ; n5_summary <- rbind(n5_summary, n5_all)}
    if(nrow(n5_234) > 0 ) { n5_234$weight <- 2.5*n5_weight ; n5_summary <- rbind(n5_summary, n5_234)}
    if(nrow(n5_134) > 0 ) { n5_134$weight <- 2.0*n5_weight ; n5_summary <- rbind(n5_summary, n5_134)}
    if(nrow(n5_124) > 0 ) { n5_124$weight <- 1.5*n5_weight ; n5_summary <- rbind(n5_summary, n5_124)}
    if(nrow(n5_123) > 0 ) { n5_123$weight <- 1.5*n5_weight ; n5_summary <- rbind(n5_summary, n5_123)}
    row.names(n5_summary) <- NULL

    cat(" [", k, "] n5_summary : ", nrow(n5_summary), " at sensitivity = ", n5_sensitivity, "\n")
    if(nrow(n5_summary) > 1 && nrow(n5_summary) < 200) { break }
    if(nrow(n5_summary) == 1)  { n5_sensitivity <- n5_sensitivity + 0.025 }
    if(nrow(n5_summary) > 200) { n5_sensitivity <- n5_sensitivity - 0.025 }

}

#-------------------
n4w <- n4sel
n4_sensitivity <- n4_base_sensitivity 

for(k in 1:N_try) {
    n4_all_1 <- n4w[agrep(paste(words[c(2, 3, 4)], collapse = " "), n4w$wall, fixed = FALSE, max = n4_sensitivity), c("pred", "freq", "wall") ]
    n4_all_2 <- n4w[agrep(paste(words[c(1, 3, 4)], collapse = " "), n4w$wall, fixed = FALSE, max = n4_sensitivity), c("pred", "freq", "wall") ]
    n4_all_3 <- n4w[agrep(paste(words[c(1, 2, 4)], collapse = " "), n4w$wall, fixed = FALSE, max = n4_sensitivity), c("pred", "freq", "wall") ]
    n4_all_4 <- n4w[agrep(paste(words[c(1, 2, 3)], collapse = " "), n4w$wall, fixed = FALSE, max = n4_sensitivity), c("pred", "freq", "wall") ]
    n4_all   <- n4w[agrep(paste(words,             collapse = " "), n4w$wall, fixed = FALSE, max = n4_sensitivity), c("pred", "freq", "wall") ]
    
    n4_summary <- dummy.df
    if(nrow(n4_all_1) > 0 ) { n4_all_1$weight <- 2.5*n4_weight ; n4_summary <- rbind(n4_summary, n4_all_1)}
    if(nrow(n4_all_2) > 0 ) { n4_all_2$weight <- 2.0*n4_weight ; n4_summary <- rbind(n4_summary, n4_all_2)}
    if(nrow(n4_all_3) > 0 ) { n4_all_3$weight <- 1.5*n4_weight ; n4_summary <- rbind(n4_summary, n4_all_3)}
    if(nrow(n4_all_4) > 0 ) { n4_all_4$weight <- 1.0*n4_weight ; n4_summary <- rbind(n4_summary, n4_all_4)}
    if(nrow(n4_all)   > 0 ) { n4_all$weight   <- 2.0*n4_weight ; n4_summary <- rbind(n4_summary, n4_all)}
    row.names(n4_summary) <- NULL

    cat(" [", k, "] n4_summary : ", nrow(n4_summary), " at sensitivity = ", n4_sensitivity, "\n")
    if(nrow(n4_summary) > 1 && nrow(n4_summary) < 200) { break }
    if(nrow(n4_summary) == 1)  { n4_sensitivity <- n4_sensitivity + 0.015 }
    if(nrow(n4_summary) > 200) { n4_sensitivity <- n4_sensitivity - 0.015 }
}

#-------------------
n3w <- n3sel
n3_sensitivity <- n3_base_sensitivity 

for(k in 1:N_try) {

    n3_all_1 <- n3w[agrep(paste(words[c(3,4)], collapse = " "), n3w$wall, fixed = FALSE, max = n3_sensitivity), c("pred", "freq", "wall") ]
    n3_all_2 <- n3w[agrep(paste(words[c(2,4)], collapse = " "), n3w$wall, fixed = FALSE, max = n3_sensitivity), c("pred", "freq", "wall") ]
    n3_all_3 <- n3w[agrep(paste(words[c(1,4)], collapse = " "), n3w$wall, fixed = FALSE, max = n3_sensitivity), c("pred", "freq", "wall") ]
    n3_all_4 <- n3w[agrep(paste(words[c(1,3)], collapse = " "), n3w$wall, fixed = FALSE, max = n3_sensitivity), c("pred", "freq", "wall") ]
    
    n3_summary <- dummy.df
    if(nrow(n3_all_1) > 0 ) { n3_all_1$weight  <- 2.5*n3_weight ; n3_summary <- rbind(n3_summary, n3_all_1)}
    if(nrow(n3_all_2) > 0 ) { n3_all_2$weight  <- 1.5*n3_weight ; n3_summary <- rbind(n3_summary, n3_all_2)}
    if(nrow(n3_all_3) > 0 ) { n3_all_3$weight  <- 1.0*n3_weight ; n3_summary <- rbind(n3_summary, n3_all_3)}
    if(nrow(n3_all_4) > 0 ) { n3_all_4$weight  <- 0.7*n3_weight ; n3_summary <- rbind(n3_summary, n3_all_4)}
    row.names(n3_summary) <- NULL

    cat(" [", k, "] n3_summary : ", nrow(n3_summary), " at sensitivity = ", n3_sensitivity, "\n")
    if(nrow(n3_summary) > 1 && nrow(n3_summary) < 200) { break }
    if(nrow(n3_summary) == 1)  { n3_sensitivity <- n3_sensitivity + 0.015 }
    if(nrow(n3_summary) > 200) { n3_sensitivity <- n3_sensitivity - 0.015 }
}

#---------------------------------------------------------------------------------------------------

n6_summary <- mutate(n6_summary, score = freq*weight)
n5_summary <- mutate(n5_summary, score = freq*weight)
n4_summary <- mutate(n4_summary, score = freq*weight)
n3_summary <- mutate(n3_summary, score = freq*weight)

all_found <- rbind( n6_summary, n5_summary, n4_summary, n3_summary)
candidates <- ddply(all_found, "pred", numcolwise(sum))

check_bad_chars <- grepl("[*+]", candidates$pred, perl = TRUE)
if( sum(check_bad_chars) > 0 ) {
    candidates <- candidates[!check_bad_chars, ]    
}


frequency <- rep(0, nrow(candidates))
for(i in 1:length(frequency)) {
    testw <- candidates$pred[i]
    cat(" word ", i, " : ", testw)
    match <- word_counts$word[grep(paste0("^", testw, "$"), word_counts$word, perl = TRUE)]
    nn    <- word_counts$count[grep(paste0("^", testw, "$"), word_counts$word, perl = TRUE)]
    if( length(nn) != 0 ) {
        cat(" : ", match, " --- ", nn, "\n")
        frequency[i] <- nn
    } else {
        frequency[i] <- 0
        cat(" : NO MATCH\n")
    }
}

candidates <- cbind(candidates, frequency)[frequency > 0, ]
temp <- mutate(candidates, metric = score/log(frequency))
arrange(temp, metric)
head(arrange(temp, desc(metric)), 10)

# temp <- mutate(candidates, metric = round(100*score/frequency, 4))
# temp <- mutate(candidates, metric = log(100*score/frequency))

#---------------------------------------------------------------------------------------------------
