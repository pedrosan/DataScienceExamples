#===================================================================================================
# READ DATA FROM CSV FILES
#--------------------------

# system.time( dict2 <- read.csv2("./data/dictionary_Nw2_OK.csv.gz", stringsAsFactors = FALSE, 
#                                colClasses = c("character", "character", "integer")) )

# system.time( dict5 <- read.csv2("./data/dictionary_Nw5_OK.csv.gz", stringsAsFactors = FALSE, 
#                                colClasses = c("character", "character", "integer")) )

system.time( dict5 <- read.csv2("./data/dictionary_Nw5_OK.csv.gz", stringsAsFactors = FALSE, 
                               colClasses = c("integer", "character", "integer")) )

#--------------
# words 
#--------------

# system.time({ 
#     n3g_Ng4_Nw2 <- read.csv2("./data/n3grams_Ng4_Nw2.csv.gz", stringsAsFactors = FALSE) 
#     n4g_Ng4_Nw2 <- read.csv2("./data/n4grams_Ng4_Nw2.csv.gz", stringsAsFactors = FALSE) 
#     n5g_Ng2_Nw2 <- read.csv2("./data/n5grams_Ng2_Nw2.csv.gz", stringsAsFactors = FALSE)
# })

# system.time({ 
#     n3g_Ng4_Nw5 <- read.csv2("./data/n3grams_Ng4_Nw5.csv.gz", stringsAsFactors = FALSE) 
#     n4g_Ng4_Nw5 <- read.csv2("./data/n4grams_Ng4_Nw5.csv.gz", stringsAsFactors = FALSE) 
#     n5g_Ng2_Nw5 <- read.csv2("./data/n5grams_Ng2_Nw5.csv.gz", stringsAsFactors = FALSE)
# })

#--------------
# words by ID
#--------------

# system.time({ 
#     n3g_Ng4_Nw2_ID <- read.csv2("./data/n3grams_Ng4_Nw2_byID.csv.gz", stringsAsFactors = FALSE) 
#     n4g_Ng4_Nw2_ID <- read.csv2("./data/n4grams_Ng4_Nw2_byID.csv.gz", stringsAsFactors = FALSE) 
#     n5g_Ng2_Nw2_ID <- read.csv2("./data/n5grams_Ng2_Nw2_byID.csv.gz", stringsAsFactors = FALSE)
# })

# Ng = 4/4/2 -- Nw = 5
system.time({ 
    n3g_Ng4_Nw5_ID <- read.csv2("./data/n3grams_Ng4_Nw5_byID.csv.gz", stringsAsFactors = FALSE) 
    n4g_Ng4_Nw5_ID <- read.csv2("./data/n4grams_Ng4_Nw5_byID.csv.gz", stringsAsFactors = FALSE) 
    n5g_Ng2_Nw5_ID <- read.csv2("./data/n5grams_Ng2_Nw5_byID.csv.gz", stringsAsFactors = FALSE)
})
n3g_Ng4_Nw5_ID$logPdict <- as.numeric(n3g_Ng4_Nw5_ID$logPdict)
n4g_Ng4_Nw5_ID$logPdict <- as.numeric(n4g_Ng4_Nw5_ID$logPdict)
n5g_Ng2_Nw5_ID$logPdict <- as.numeric(n5g_Ng2_Nw5_ID$logPdict)

# Ng = 4/4/2 -- Nw = 5 -- PURIFIED
system.time({ 
    n3g_Ng4_Nw5_pure_ID <- read.csv2("./data/n3grams_Ng4_Nw5_pure_byID.csv.gz", stringsAsFactors = FALSE) 
    n4g_Ng4_Nw5_pure_ID <- read.csv2("./data/n4grams_Ng4_Nw5_pure_byID.csv.gz", stringsAsFactors = FALSE) 
    n5g_Ng2_Nw5_pure_ID <- read.csv2("./data/n5grams_Ng2_Nw5_pure_byID.csv.gz", stringsAsFactors = FALSE)
})
n3g_Ng4_Nw5_pure_ID$logPdict <- as.numeric(n3g_Ng4_Nw5_pure_ID$logPdict)
n4g_Ng4_Nw5_pure_ID$logPdict <- as.numeric(n4g_Ng4_Nw5_pure_ID$logPdict)
n5g_Ng2_Nw5_pure_ID$logPdict <- as.numeric(n5g_Ng2_Nw5_pure_ID$logPdict)

# Ng = 3/3/2 -- Nw = 5 -- PURIFIED
system.time({ 
    n3g_Ng3_Nw5_pure_ID <- read.csv2("./data/n3grams_Ng3_Nw5_pure_byID.csv.gz", stringsAsFactors = FALSE) 
    n4g_Ng3_Nw5_pure_ID <- read.csv2("./data/n4grams_Ng3_Nw5_pure_byID.csv.gz", stringsAsFactors = FALSE) 
})
n3g_Ng3_Nw5_pure_ID$logPdict <- as.numeric(n3g_Ng3_Nw5_pure_ID$logPdict)
n4g_Ng3_Nw5_pure_ID$logPdict <- as.numeric(n4g_Ng3_Nw5_pure_ID$logPdict)

#===================================================================================================
# SAVE DATA TO RDS
#---------------------

# Nw = 2
# saveRDS(dict2, file = "./data/dict_Nw2_OK.RDS")
# 
# saveRDS(n3g_Ng4_Nw2, file = "./data/n3grams_Ng4_Nw2.RDS")
# saveRDS(n4g_Ng4_Nw2, file = "./data/n4grams_Ng4_Nw2.RDS")
# saveRDS(n5g_Ng2_Nw2, file = "./data/n5grams_Ng2_Nw2.RDS")
# 
# saveRDS(n3g_Ng4_Nw2_ID, file = "./data/n3grams_Ng4_Nw2_byID.RDS")
# saveRDS(n4g_Ng4_Nw2_ID, file = "./data/n4grams_Ng4_Nw2_byID.RDS")
# saveRDS(n5g_Ng2_Nw2_ID, file = "./data/n5grams_Ng2_Nw2_byID.RDS")

# Nw = 5
saveRDS(dict5, file = "./data/dict_Nw5_OK.RDS")

# saveRDS(n3g_Ng4_Nw5, file = "./data/n3grams_Ng4_Nw5.RDS")
# saveRDS(n4g_Ng4_Nw5, file = "./data/n4grams_Ng4_Nw5.RDS")
# saveRDS(n5g_Ng2_Nw5, file = "./data/n5grams_Ng2_Nw5.RDS")

saveRDS(n3g_Ng4_Nw5_ID, file = "./data/n3grams_Ng4_Nw5_byID.RDS")
saveRDS(n4g_Ng4_Nw5_ID, file = "./data/n4grams_Ng4_Nw5_byID.RDS")
saveRDS(n5g_Ng2_Nw5_ID, file = "./data/n5grams_Ng2_Nw5_byID.RDS")

# Ng = 4/4/2 -- Nw = 5 -- PURIFIED
saveRDS(n3g_Ng4_Nw5_pure_ID, file = "./data/n3grams_Ng4_Nw5_pure_byID.RDS")
saveRDS(n4g_Ng4_Nw5_pure_ID, file = "./data/n4grams_Ng4_Nw5_pure_byID.RDS")
saveRDS(n5g_Ng2_Nw5_pure_ID, file = "./data/n5grams_Ng2_Nw5_pure_byID.RDS")

# Ng = 3/3/2 -- Nw = 5 -- PURIFIED
saveRDS(n3g_Ng3_Nw5_pure_ID, file = "./data/n3grams_Ng3_Nw5_pure_byID.RDS")
saveRDS(n4g_Ng3_Nw5_pure_ID, file = "./data/n4grams_Ng3_Nw5_pure_byID.RDS")

#-------------------------------------------------------------------------------

rm(list = ls(pattern = "^n[345]*"))

#===================================================================================================
# READ DATA FROM RDS
#---------------------

# Ng = 4/4/2 -- Nw = 2

system.time({ 
    dict2  <- readRDS(file = "./data/dict_Nw2_OK.RDS")
    n3g_Ng4_Nw2 <- readRDS(file = "./data/n3grams_Ng4_Nw2.RDS")
    n4g_Ng4_Nw2 <- readRDS(file = "./data/n4grams_Ng4_Nw2.RDS")
    n5g_Ng2_Nw2 <- readRDS(file = "./data/n5grams_Ng2_Nw2.RDS")
})

system.time({ 
    dict2  <- readRDS(file = "./data/dict_Nw2_OK.RDS")
    n3g_Ng4_Nw2_ID <- readRDS(file = "./data/n3grams_Ng4_Nw2_byID.RDS")
    n4g_Ng4_Nw2_ID <- readRDS(file = "./data/n4grams_Ng4_Nw2_byID.RDS")
    n5g_Ng2_Nw2_ID <- readRDS(file = "./data/n5grams_Ng2_Nw2_byID.RDS")
})

# Ng = 4/4/2 -- Nw = 5

system.time({ 
    dict5  <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g_Ng4_Nw5 <- readRDS(file = "./data/n3grams_Ng4_Nw5.RDS")
    n4g_Ng4_Nw5 <- readRDS(file = "./data/n4grams_Ng4_Nw5.RDS")
    n5g_Ng2_Nw5 <- readRDS(file = "./data/n5grams_Ng2_Nw5.RDS")
})

system.time({ 
    dict5  <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g_Ng4_Nw5_ID <- readRDS(file = "./data/n3grams_Ng4_Nw5_byID.RDS")
    n4g_Ng4_Nw5_ID <- readRDS(file = "./data/n4grams_Ng4_Nw5_byID.RDS")
    n5g_Ng2_Nw5_ID <- readRDS(file = "./data/n5grams_Ng2_Nw5_byID.RDS")
})

# Ng = 4/4/2 -- Nw = 5 -- PURIFIED

system.time({ 
    dict5  <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g_Ng4_Nw5_pure_ID <- readRDS(file = "./data/n3grams_Ng4_Nw5_pure_byID.RDS")
    n4g_Ng4_Nw5_pure_ID <- readRDS(file = "./data/n4grams_Ng4_Nw5_pure_byID.RDS")
    n5g_Ng2_Nw5_pure_ID <- readRDS(file = "./data/n5grams_Ng2_Nw5_pure_byID.RDS")
})

# Ng = 3/3/2 -- Nw = 5 -- PURIFIED

system.time({ 
    dict5  <- readRDS(file = "./data/dict_Nw5_OK.RDS")
    n3g_Ng3_Nw5_pure_ID <- readRDS(file = "./data/n3grams_Ng3_Nw5_pure_byID.RDS")
    n4g_Ng3_Nw5_pure_ID <- readRDS(file = "./data/n4grams_Ng3_Nw5_pure_byID.RDS")
    n5g_Ng2_Nw5_pure_ID <- readRDS(file = "./data/n5grams_Ng2_Nw5_pure_byID.RDS")
})

#===================================================================================================
#===================================================================================================
#===================================================================================================
#===================================================================================================
# OLD FILES
#------------

# system.time( word_counts <- readRDS("./data/wc_best.RDS") ) 
# system.time( hash_wc <- hash(word_counts$word, word_counts$count) ) 

system.time( {
    n3_sentences <- readRDS("./data/old_n3_gt2_sentences.RDS") 
    n4_sentences <- readRDS("./data/old_n4_gt2_sentences.RDS") 
    n5_sentences <- readRDS("./data/old_n5_gt2_sentences.RDS") 
} ) 
system.time( n6_sentences <- readRDS("./data/old_n6_sentences_50pct.RDS") ) 

n3a <- n3_sentences
n4a <- n4_sentences
n5a <- n5_sentences
n6a <- n6_sentences

n3w <- ldply(strsplit(n3a$wall, split = " +"))
colnames(n3w) <- c("w1", "w2")
n3w$pred <- n3a$pred
n3w$freq <- n3a$freq

n4w <- ldply(strsplit(n4a$wall, split = " +"))
colnames(n4w) <- c("w1", "w2", "w3")
n4w$pred <- n4a$pred
n4w$freq <- n4a$freq

n5w <- ldply(strsplit(n5a$wall, split = " +"))
colnames(n5w) <- c("w1", "w2", "w3", "w4")
n5w$pred <- n5a$pred
n5w$freq <- n5a$freq

n6w <- ldply(strsplit(n6a$wall, split = " +"))
colnames(n6w) <- c("w1", "w2", "w3", "w4", "w5")
n6w$pred <- n6a$pred
n6w$freq <- n6a$freq

n3w <- readRDS("./data/old_3w.RDS")
n4w <- readRDS("./data/old_4w.RDS")
n5w <- readRDS("./data/old_5w.RDS")
n6w <- readRDS("./data/old_6w.RDS")

#===================================================================================================
