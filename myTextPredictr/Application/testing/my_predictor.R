#---------------------------------------------------------------------------------------------------
# LIBRARIES
#-------------------
# library("shiny")
# library("plyr")
# library("hash")
library("dplyr")

#-------------------
# my functions
#-------------------
# source("scripts/my_functions_OLD.R")
# source("scripts/my_functions_App_v1.R")
source("my_functions.R")

#-------------------
# data
#-------------------

# Nw = 5
system.time({ 
    dict <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g  <- readRDS(file = "./data/n3grams_Ng4_Nw5_byID.RDS")
    n4g  <- readRDS(file = "./data/n4grams_Ng4_Nw5_byID.RDS")
    n5g  <- readRDS(file = "./data/n5grams_Ng2_Nw5_byID.RDS")
})

# Ng = 4/4/2 -- Nw = 5 -- PURIFIED
system.time({ 
    dict <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g  <- readRDS(file = "./data/n3grams_Ng4_Nw5_pure_byID.RDS")
    n4g  <- readRDS(file = "./data/n4grams_Ng4_Nw5_pure_byID.RDS")
    n5g  <- readRDS(file = "./data/n5grams_Ng2_Nw5_pure_byID.RDS")
})

# Ng = 3/3/2 -- Nw = 5 -- PURIFIED
system.time({ 
    dict <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g  <- readRDS(file = "./data/n3grams_Ng3_Nw5_pure_byID.RDS")
    n4g  <- readRDS(file = "./data/n4grams_Ng3_Nw5_pure_byID.RDS")
    n5g  <- readRDS(file = "./data/n5grams_Ng2_Nw5_pure_byID.RDS")
})

# system.time( word_counts <- readRDS("./data/wc_best.RDS") ) 
# system.time( hash_word2count <- hash(keys = dict$word, values = dict$count) ) 
# system.time( hash_id2word <- hash(keys = dict$ID, values = dict$word) ) 
# system.time( hash_count <- hash(keys = dict$ID, values = dict$count) ) 

system.time({
    vec_words  <- vector(mode = "character", length = nrow(dict))
    vec_counts <- vector(mode = "integer", length = nrow(dict))
    vec_words[dict$ID] <- dict$word
    vec_counts[dict$ID] <- dict$count
    dict_size <- sum(dict$count)
})

#===================================================================================================

n3grams <- n3g
n4grams <- n4g
n5grams <- n5g

# use the following to setup when testing manually
n3w <- n3g
n4w <- n4g
n5w <- n5g

n3g_norm <- sum(n3g$ngFreq)
n4g_norm <- sum(n4g$ngFreq)
n5g_norm <- sum(n5g$ngFreq)
n3w <- mutate(n3w, logPng = -1.0*log10(ngFreq/n5g_norm))
n4w <- mutate(n4w, logPng = -1.0*log10(ngFreq/n5g_norm))
n5w <- mutate(n5w, logPng = -1.0*log10(ngFreq/n5g_norm))


# prediction3 <- predict_engine_v3(input_text, n3w = n3w, n4w = n4w, n5w = n5w, debug = FALSE) 
# prediction3b <- predict_engine_v3b(input_text, n3w = n3w, n4w = n4w, n5w = n5w, debug = FALSE) 
# prediction4 <- predict_engine_v4(input_text, n3w = n3w, n4w = n4w, n5w = n5w, debug = FALSE) 

predict_engine_v5(input_text, n3w = n3w, n4w = n4w, n5w = n5w, debug = FALSE) 
predict_engine_v3b(input_text, n3w = n3w, n4w = n4w, n5w = n5w, debug = FALSE) 
predict_engine_v4(input_text, n3w = n3w, n4w = n4w, n5w = n5w, debug = FALSE) 

best <- prediction; 
head(best, 5) 


#-----------------------------------------------------------

prediction <- predict_engine_v3(input$text_to_test, n3w = n3grams, n4w = n4grams, n5w = n5grams, hash_wc, hash_count, debug = FALSE) 

prediction <- predict_engine_v2(input$text_to_test, n3_sentences, n4_sentences, n5_sentences, n6_sentences, hash_wc, debug = FALSE) 

best <- prediction; 
head(best, 5) 

#===================================================================================================
