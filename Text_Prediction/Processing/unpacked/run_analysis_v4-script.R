#!/usr/bin/Rscript

#---------------------------------------------------------------------------------------------------
library("tm")
library("SnowballC")
#library("stringi")
library("openNLP")
#library("qdap")     # [sent_detect] needs careful tailoring of punctuation... it did not recognize Mr. as NOT the end of a sentence.

# To help java fail less :-(
# options( java.parameters = "-Xmx4g")
options( java.parameters = "-Xmx6g")
library("RWeka")   # [NGramTokenizer], [Weka_control]

#library("textcat") # n-gram "profiles"

#library("tau")      # [textcnt], [tokenize], [remove_stopwords]
#library("ngram")    # [Preprocess], [ngram], [babble]

#-----------------------------
library("magrittr")
library("devtools")

#library("ggplot2")
#library("RColorBrewer")

#---------------------------------------------------------------------------------------------------
# source("./scripts/task0_v5_functions.R")
source("scripts/tasks_v2_functions.R")
#---------------------------------------------------------------------------------------------------

cat(" *** Loading the data sets  [", my_date(), "]------------------------------------------------------------\n")
#---------------------------------------
# LOADING DATA
#---------------------------------------

# in.blogs.CL <- readByLine("./blogs_pass4-emptied_TAGS.gz", check_nl = FALSE, skipNul = TRUE)
# in.news.CL <- readByLine("./news_pass4-emptied_TAGS.gz", check_nl = FALSE, skipNul = TRUE)
# in.twitter.CL <- readByLine("./twitter_pass4-emptied_TAGS.gz", check_nl = FALSE, skipNul = TRUE)

# in.blogs.CL <- readByLine("./blogs_pass4_NF_ge_5.gz", check_nl = FALSE, skipNul = TRUE)
# in.news.CL <- readByLine("./news_pass4_NF_ge_5.gz", check_nl = FALSE, skipNul = TRUE)
# in.twitter.CL <- readByLine("./twitter_pass4_NF_ge_5.gz", check_nl = FALSE, skipNul = TRUE)

in.blogs.CL <- readByLine("./TESTING/blogs_pass5_NF_ge_5.gz", check_nl = FALSE, skipNul = TRUE)
in.news.CL <- readByLine("./TESTING/news_pass5_NF_ge_5.gz", check_nl = FALSE, skipNul = TRUE)
in.twitter.CL <- readByLine("./TESTING/twitter_pass5_NF_ge_5.gz", check_nl = FALSE, skipNul = TRUE)

# in.blogs.CL <- readByLine("data/en_US.blogs.XCLEANED.txt.gz", check_nl = FALSE, skipNul = TRUE) 
# in.news.CL <- readByLine("data/en_US.news.XCLEANED.txt.gz", check_nl = FALSE, skipNul = TRUE)
# in.twitter.CL <- readByLine("data/en_US.twitter.XCLEANED.txt.gz", check_nl = FALSE, skipNul = TRUE)

# save(in.blogs.ORIG, file = "in.blogs.RData")
# save(in.news.ORIG, file = "in.news.RData")
# save(in.twitter.ORIG, file = "in.twitter.RData")

# save(in.blogs.CL, file = "in.blogs.CLEANED1.RData")
# save(in.news.CL, file = "in.news.CLEANED1.RData")
# save(in.twitter.CL, file = "in.twitter.CLEANED1.RData")

#---------------------------------------
# load(file = "data/in.blogs.RData")
# load(file = "data/in.news.RData")
# load(file = "data/in.twitter.RData")

# load(file = "data/in.blogs.CLEANED1.RData")
# load(file = "data/in.news.CLEANED1.RData")
# load(file = "data/in.twitter.CLEANED1.RData")

#---------------------------------------------------------------------------------------------------
# Excluding rows with too few characters
# The 'rn.*' vectors keep track of the original row numbers, mostly for debugging
#-----------------------------------------

# 2015.04.17: this filtering is not useful anymore because I am using text of a minimum number of words in each line.
nchar.min <- 6

cat(" *** Beginning check of Nchar  [", my_date(), "]------------------------------------------------------------\n")

# rn.blogs.CL <- 1:length(in.blogs.CL)
  in.blogs.CL.cleaned <- tolower(in.blogs.CL) %>% removeNumbers() %>% stripWhitespace()
# nchar.blogs.CL.cleaned <- nchar(in.blogs.CL.cleaned)
# in.blogs.CL.cleaned <- in.blogs.CL.cleaned[nchar.blogs.CL.cleaned > nchar.min]
# rn.blogs.CL <- rn.blogs.CL[nchar.blogs.CL.cleaned > nchar.min]

# rn.news.CL <- 1:length(in.news.CL)
  in.news.CL.cleaned <- tolower(in.news.CL) %>% removeNumbers() %>% stripWhitespace()
# nchar.news.CL.cleaned <- nchar(in.news.CL.cleaned)
# in.news.CL.cleaned <- in.news.CL.cleaned[nchar.news.CL.cleaned > nchar.min]
# rn.news.CL <- rn.news.CL[nchar.news.CL.cleaned > nchar.min]

# rn.twitter.CL <- 1:length(in.twitter.CL)
  in.twitter.CL.cleaned <- tolower(in.twitter.CL) %>% removeNumbers() %>% stripWhitespace()
# nchar.twitter.CL.cleaned <- nchar(in.twitter.CL.cleaned)
# in.twitter.CL.cleaned <- in.twitter.CL.cleaned[nchar.twitter.CL.cleaned > nchar.min]
# rn.twitter.CL <- rn.twitter.CL[nchar.twitter.CL.cleaned > nchar.min]

in.blogs.CL.cleaned <- gsub('<(emoticon|hashtag|dollaramount|period|hour|profanity|usa|percentage|date|money|ass|space|decade|ordinal|number|telephonenumber|timeinterval)>', 
                  '<\\U\\1>', in.blogs.CL.cleaned, ignore.case = TRUE, perl = TRUE)

in.news.CL.cleaned  <- gsub('<(emoticon|hashtag|dollaramount|period|hour|profanity|usa|percentage|date|money|ass|space|decade|ordinal|number|telephonenumber|timeinterval)>', 
                  '<\\U\\1>', in.news.CL.cleaned, ignore.case = TRUE, perl = TRUE)

in.twitter.CL.cleaned <- gsub('<(emoticon|hashtag|dollaramount|period|hour|profanity|usa|percentage|date|money|ass|space|decade|ordinal|number|telephonenumber|timeinterval)>', 
                  '<\\U\\1>', in.twitter.CL.cleaned, ignore.case = TRUE, perl = TRUE)


cat(" *** End check of Nchar  [", my_date(), "]------------------------------------------------------------\n")

#-------------------
# Renaming the datasets to a more compact name
#
# rn.blogs <- rn.blogs.CL
  in.blogs <- in.blogs.CL.cleaned
# rn.news <- rn.news.CL
  in.news <- in.news.CL.cleaned
# rn.twitter <- rn.twitter.CL
  in.twitter <- in.twitter.CL.cleaned

  save(in.blogs, file = "in.blogs.RData")
  save(in.news, file = "in.news.RData")
  save(in.twitter, file = "in.twitter.RData")

#===================================================================================================

#---------------------------------------------------------------------------------------------------
# random subsetting of the dataset
#-----------------------------------------
seed.blogs <- 7001
seed.news <- 7002
seed.twitter <- 7003

set.seed(seed.blogs)
idx.blogs.shuffled <- sample(1:length(in.blogs))
set.seed(seed.news)
idx.news.shuffled <- sample(1:length(in.news))
set.seed(seed.twitter)
idx.twitter.shuffled <- sample(1:length(in.twitter))

len.blogs   <- length(in.blogs)
len.news    <- length(in.news)
len.twitter <- length(in.twitter)

cat("   N_rows - blogs   : ", sprintf("%9d", len.blogs), "\n")
cat("   N_rows - news    : ", sprintf("%9d", len.news), "\n")
cat("   N_rows - twitter : ", sprintf("%9d", len.twitter), "\n")

cat(" *** Sampling data for analysis subset  [", my_date(), "]------------------------------------------------------------\n")
cat("     SKIPPED FOR NOW\n")

fraction <- 0.3
idx.blogs   <- idx.blogs.shuffled[1:ceiling(fraction*len.blogs)]
idx.news    <- idx.news.shuffled[1:ceiling(fraction*len.news)]
idx.twitter <- idx.twitter.shuffled[1:ceiling(fraction*len.twitter)]

rn.blogs    <- rn.blogs[idx.blogs]
sel.blogs   <- in.blogs[idx.blogs]
rn.news     <- rn.news[idx.news]
sel.news    <- in.news[idx.news]
rn.twitter  <- rn.twitter[idx.twitter]
sel.twitter <- in.twitter[idx.twitter]

in.blogs <- sel.blogs
in.news <- sel.news
in.twitter <- sel.twitter

len.blogs   <- length(in.blogs)
len.news    <- length(in.news)
len.twitter <- length(in.twitter)

cat("   N_rows - blogs   : ", sprintf("%9d", len.blogs), "\n")
cat("   N_rows - news    : ", sprintf("%9d", len.news), "\n")
cat("   N_rows - twitter : ", sprintf("%9d", len.twitter), "\n")

#===================================================================================================
# Using 'openNLP' sentence annotator
#--------------------------------------------

cat("====================================================================================================\n")
cat(" *** SENTENCES ANNOTATION [", my_date(), "]------------------------------------------------------------\n")

sent_token_annotator <- Maxent_Sent_Token_Annotator()
sent_token_annotator

#---------------------------------------------------------------------------------------------------
# Annotation of 'sel' subsets (COMMENT OUT FOR BATCH PROCESSING)
#------------------------------

# cat(" *** Annotating sentences in blogs dataset  [", my_date(), "]------------------------------------------------------------\n")
# system.time({ sel.blogs.sentences <- sapply(sel.blogs, FUN = find_sentences, USE.NAMES = FALSE) %>% unlist })
# cat(" *** N_sentences = ", length(sel.blogs.sentences), " ------------------------------------------------------------\n")
# 
# cat(" *** Annotating sentences in news dataset  [", my_date(), "]------------------------------------------------------------\n")
# system.time({ sel.news.sentences <- sapply(sel.news, FUN = find_sentences, USE.NAMES = FALSE) %>% unlist })
# cat("   N_sentences = ", length(sel.news.sentences), " ------------------------------------------------------------\n")
# 
# cat(" *** Annotating sentences in twitter dataset [", my_date(), "]------------------------------------------------------------\n")
# system.time({ sel.twitter.sentences <- sapply(sel.twitter, FUN = find_sentences, USE.NAMES = FALSE) %>% unlist })
# cat("   N_sentences = ", length(sel.twitter.sentences), " ------------------------------------------------------------\n")

#---------------------------------------------------------------------------------------------------
# Annotation of full datasets, in chunks
#---------------------------------------------------------------------------------------------------

# chunk_size <- 4000
# chunk_size <- 100000
chunk_size <- 50000

#---------------------------------------------------------------------------------------------------
cat(" *** Processing BLOGS  [", my_date(), "]------------------------------------------------------------\n")

n_chunks <- floor(len.blogs/chunk_size) + 1
n1 <- ((1:n_chunks)-1)*chunk_size + 1
n2 <- (1:n_chunks)*chunk_size
n2[n_chunks] <- len.blogs
Ns_by_chunk <- rep(0, n_chunks)

names <- paste("blogs.sentences", sprintf("%03d", (1:n_chunks)), sep = ".")
fnames <- paste("output/", names, ".gz", sep = "")

for(i in 1:n_chunks) {
    name1 <- names[i]
    fname1 <- fnames[i]
    idx <- n1[i]:n2[i]

    cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    assign( name1, sapply(in.blogs[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )

    con <- gzfile(fname1, open = "w")
    writeLines(get(name1), con = con)
    close(con)
}

#-------------------------------------------------
# Combining chunks into one sentences vector
#
size.sentences.blogs <- rep(0, n_chunks)
total_length <- 0 
for(i in 1:n_chunks) {
    name1 <- names[i]
    this_length <- length(get(name1))
    size.sentences.blogs[i] <- this_length
    total_length <- total_length + this_length
    cat("   ", sprintf("03d", i), "  Length = ", this_length, "\n")
}
cat("    Total Length = ", total_length, "\n")

blogs.sentences.all <- vector(mode = "character", length = total_length)
ivec <- c(0, cumsum(size.sentences.blogs))
for(i in 1:n_chunks) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- names[i]
    cat("   ", i, n1, n2, name, "\n")
    blogs.sentences.all[n1:n2] <- get(name)
}

fname <- "output/blogs.sentences.all.gz"
con <- gzfile(fname, open = "w")
writeLines(blogs.sentences.all, con = con)
close(con)

rm(i, n1, n2, n_chunks)

#---------------------------------------------------------------------------------------------------
cat(" *** Processing NEWS  [", my_date(), "]------------------------------------------------------------\n")

n_chunks <- floor(len.news/chunk_size) + 1
n1 <- ((1:n_chunks)-1)*chunk_size + 1
n2 <- (1:n_chunks)*chunk_size
n2[n_chunks] <- len.news
Ns_by_chunk <- rep(0, n_chunks)

names <- paste("news.sentences", sprintf("%03d", (1:n_chunks)), sep = ".")
fnames <- paste("output/", names, ".gz", sep = "")

for(i in 1:n_chunks) {
    name1 <- names[i]
    fname1 <- fnames[i]
    idx <- n1[i]:n2[i]

    cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    assign( name1, sapply(in.news[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )

    con <- gzfile(fname1, open = "w")
    writeLines(get(name1), con = con)
    close(con)
}

#-------------------------------------------------
# Combining chunks into one sentences vector
#
size.sentences.news <- rep(0, n_chunks)
total_length <- 0 
for(i in 1:n_chunks) {
    name1 <- names[i]
    this_length <- length(get(name1))
    size.sentences.news[i] <- this_length
    total_length <- total_length + this_length
    cat("   ", sprintf("03d", i), "  Length = ", this_length, "\n")
}
cat("    Total Length = ", total_length, "\n")

news.sentences.all <- vector(mode = "character", length = total_length)
ivec <- c(0, cumsum(size.sentences.news))
for(i in 1:n_chunks) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- names[i]
    cat("   ", i, n1, n2, name, "\n")
    news.sentences.all[n1:n2] <- get(name)
}

fname <- "output/news.sentences.all.gz"
con <- gzfile(fname, open = "w")
writeLines(news.sentences.all, con = con)
close(con)

rm(i, n1, n2, n_chunks)

#---------------------------------------------------------------------------------------------------
cat(" *** Processing TWITTER  [", my_date(), "]------------------------------------------------------------\n")

n_chunks <- floor(len.twitter/chunk_size) + 1
n1 <- ((1:n_chunks)-1)*chunk_size + 1
n2 <- (1:n_chunks)*chunk_size
n2[n_chunks] <- len.twitter
Ns_by_chunk <- rep(0, n_chunks)

names <- paste("twitter.sentences", sprintf("%03d", (1:n_chunks)), sep = ".")
fnames <- paste("output/", names, ".gz", sep = "")

for(i in 1:n_chunks) {
    name1 <- names[i]
    fname1 <- fnames[i]
    idx <- n1[i]:n2[i]

    cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    assign( name1, sapply(in.twitter[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )

    con <- gzfile(fname1, open = "w")
    writeLines(get(name1), con = con)
    close(con)
}

#-------------------------------------------------
# Combining chunks into one sentences vector
#
size.sentences.twitter <- rep(0, n_chunks)
total_length <- 0 
for(i in 1:n_chunks) {
    name1 <- names[i]
    this_length <- length(get(name1))
    size.sentences.twitter[i] <- this_length
    total_length <- total_length + this_length
    cat("   ", sprintf("03d", i), "  Length = ", this_length, "\n")
}
cat("    Total Length = ", total_length, "\n")

twitter.sentences.all <- vector(mode = "character", length = total_length)
ivec <- c(0, cumsum(size.sentences.twitter))
for(i in 1:n_chunks) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- names[i]
    cat("   ", i, n1, n2, name, "\n")
    twitter.sentences.all[n1:n2] <- get(name)
}

fname <- "output/twitter.sentences.all.gz"
con <- gzfile(fname, open = "w")
writeLines(twitter.sentences.all, con = con)
close(con)

rm(i, n1, n2, n_chunks)

# QUESTION: Would it be possible to use data frames instead of matrices?
#           With data frames I could use dplyr, which is probably faster.
#           Would the LNP tools work with data frames?


#===================================================================================================
# RWeka Tokenizer
#---------------------------------------------------------------------------------------------------
## WOW(NGramTokenizer)
## -max <int>
##     The max size of the Ngram (default = 3).
##     Number of arguments: 1.
## -min <int>
##     The min size of the Ngram (default = 1).
##     Number of arguments: 1.
## -delimiters <value>
##     The delimiters to use (default ' \r\n\t.,;:'"()?!').
##     Number of arguments: 1.

# from Nick Oswald
token_delimiters_1 <- " \\t\\r\\n.!?,;\"()"

# from Maher Harb (same as Oswald with the addition of ":")
token_delimiters_2 <- " \\r\\n\\t.,;:\"()?!"

token_delim <- token_delimiters_1

# nl.chunk <- 100000
# nl.chunk <- 7000
nl.chunk <- 100000

# N <- ceiling(length(sel.blogs.sentences)/nl.chunk)

#---------------------------------------------------------------------------------------------------

cat("====================================================================================================\n")
cat(" *** N-GRAM TOKENIZATION [", my_date(), "]\n")

     #-------#
#----+ BLOGS +--------------------------------------------------------------------------------------
     #-------#

cat(" *** Tokenizing n-grams in BLOGS dataset  [", my_date(), "]------------------------------------------------------------\n")

len.blogs.sentences <- length(blogs.sentences.all)
cat(" *** Number of sentences in the BLOGS data set : ", len.blogs.sentences, "\n")

n_chunks <- floor(len.blogs.sentences/nl.chunk) + 1
n1 <- ((1:n_chunks)-1)*nl.chunk + 1
n2 <- (1:n_chunks)*nl.chunk
n2[n_chunks] <- len.blogs.sentences
Ns_by_chunk <- rep(0, n_chunks)


#----- 1-/2-/3-/4-/5-grams ---------------------------------------------
cat(" *** Tokenizing : blogs : 1-grams ------------------------------------------------------------\n")

for( ngram_size in 2:3 ) {
    cat(" *** Tokenizing : BLOGS : ", ngram_size, "-grams ------------------------------------------------------------\n")
    # ngram_size <- 1
    
    names <- paste("n", sprintf("%1d", ngram_size), "grams.blogs.", sprintf("%03d", (1:n_chunks)), sep = "")
    fnames <- paste("output/", names, ".gz", sep = "")
    
    for(i in 1:n_chunks) {
        name1 <- names[i]
        fname1 <- fnames[i]
        idx <- n1[i]:n2[i]
    
        cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    
        assign( name1, NGramTokenizer(blogs.sentences.all[idx], Weka_control(min = ngram_size, max = ngram_size, delimiters = token_delim)) )
    
        con <- gzfile(fname1, open = "w")
        writeLines(get(name1), con = con)
        close(con)
    }

    # Combining chunks into one sentences vector

    size.ngrams <- rep(0, n_chunks)
    total_length <- 0 
    for(i in 1:n_chunks) {
        name1 <- names[i]
        this_length <- length(get(name1))
        size.ngrams[i] <- this_length
        total_length <- total_length + this_length
        cat("   ", sprintf("03d", i), "  Length of ", name1, " = ", this_length, "\n")
    }
    cat("    Total Length = ", total_length, "\n")
    
    name_for_all_ngrams <- paste("n", sprintf("%1d", ngram_size), "grams.blogs.all", sep = "")
    temp_all_ngrams <- vector(mode = "character", length = total_length)
    ivec <- c(0, cumsum(size.ngrams))
    for(i in 1:n_chunks) {
        i1 <- ivec[i] + 1
        i2 <- ivec[i+1]
        name <- names[i]
        cat("   ", i, i1, i2, name, "\n")
        temp_all_ngrams[i1:i2] <- get(name)
    }

    assign( name_for_all_ngrams, temp_all_ngrams )

    fname <- paste("output/", "n", sprintf("%1d", ngram_size), "grams.blogs.all", sep = "")
    con <- gzfile(fname, open = "w")
    writeLines(blogs.sentences.all, con = con)
    close(con)
    
}

rm(i, n1, n2, n_chunks)
# rm(list=ls(pattern = "^n[1-5]grams.blogs.]"))

     #------#
#----+ NEWS +---------------------------------------------------------------------------------------
     #------#

cat(" *** Tokenizing n-grams in NEWS dataset  [", my_date(), "]------------------------------------------------------------\n")

len.news.sentences <- length(news.sentences.all)
cat(" *** Number of sentences in the NEWS data set : ", len.news.sentences, "\n")

n_chunks <- floor(len.news.sentences/nl.chunk) + 1
n1 <- ((1:n_chunks)-1)*nl.chunk + 1
n2 <- (1:n_chunks)*nl.chunk
n2[n_chunks] <- len.news.sentences
Ns_by_chunk <- rep(0, n_chunks)


#----- 1-/2-/3-/4-/5-grams ---------------------------------------------
cat(" *** Tokenizing : NEWS : 1-grams ------------------------------------------------------------\n")

for( ngram_size in 2:3 ) {
    cat(" *** Tokenizing : NEWS : ", ngram_size, "-grams ------------------------------------------------------------\n")
    # ngram_size <- 1
    
    names <- paste("n", sprintf("%1d", ngram_size), "grams.news.", sprintf("%03d", (1:n_chunks)), sep = "")
    fnames <- paste("output/", names, ".gz", sep = "")
    
    for(i in 1:n_chunks) {
        name1 <- names[i]
        fname1 <- fnames[i]
        idx <- n1[i]:n2[i]
    
        cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    
        assign( name1, NGramTokenizer(news.sentences.all[idx], Weka_control(min = ngram_size, max = ngram_size, delimiters = token_delim)) )
    
        con <- gzfile(fname1, open = "w")
        writeLines(get(name1), con = con)
        close(con)
    }

    # Combining chunks into one sentences vector

    size.ngrams <- rep(0, n_chunks)
    total_length <- 0 
    for(i in 1:n_chunks) {
        name1 <- names[i]
        this_length <- length(get(name1))
        size.ngrams[i] <- this_length
        total_length <- total_length + this_length
        cat("   ", sprintf("03d", i), "  Length of ", name1, " = ", this_length, "\n")
    }
    cat("    Total Length = ", total_length, "\n")
    
    name_for_all_ngrams <- paste("n", sprintf("%1d", ngram_size), "grams.news.all", sep = "")
    temp_all_ngrams <- vector(mode = "character", length = total_length)
    ivec <- c(0, cumsum(size.ngrams))
    for(i in 1:n_chunks) {
        i1 <- ivec[i] + 1
        i2 <- ivec[i+1]
        name <- names[i]
        cat("   ", i, i1, i2, name, "\n")
        temp_all_ngrams[i1:i2] <- get(name)
    }

    assign( name_for_all_ngrams, temp_all_ngrams )

    fname <- paste("output/", "n", sprintf("%1d", ngram_size), "grams.news.all", sep = "")
    con <- gzfile(fname, open = "w")
    writeLines(news.sentences.all, con = con)
    close(con)
    
}

rm(i, n1, n2, n_chunks)
# rm(list=ls(pattern = "^n[1-5]grams.news.]"))

     #---------#
#----+ TWITTER +------------------------------------------------------------------------------------
     #---------#

cat(" *** Tokenizing n-grams in TWITTER dataset  [", my_date(), "]------------------------------------------------------------\n")

len.twitter.sentences <- length(twitter.sentences.all)
cat(" *** Number of sentences in the TWITTER data set : ", len.twitter.sentences, "\n")

n_chunks <- floor(len.twitter.sentences/nl.chunk) + 1
n1 <- ((1:n_chunks)-1)*nl.chunk + 1
n2 <- (1:n_chunks)*nl.chunk
n2[n_chunks] <- len.twitter.sentences
Ns_by_chunk <- rep(0, n_chunks)


#----- 1-/2-/3-/4-/5-grams ---------------------------------------------
cat(" *** Tokenizing : TWITTER : 1-grams ------------------------------------------------------------\n")

for( ngram_size in 2:3 ) {
    cat(" *** Tokenizing : TWITTER : ", ngram_size, "-grams ------------------------------------------------------------\n")
    # ngram_size <- 1
    
    names <- paste("n", sprintf("%1d", ngram_size), "grams.twitter.", sprintf("%03d", (1:n_chunks)), sep = "")
    fnames <- paste("output/", names, ".gz", sep = "")
    
    for(i in 1:n_chunks) {
        name1 <- names[i]
        fname1 <- fnames[i]
        idx <- n1[i]:n2[i]
    
        cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    
        assign( name1, NGramTokenizer(twitter.sentences.all[idx], Weka_control(min = ngram_size, max = ngram_size, delimiters = token_delim)) )
    
        con <- gzfile(fname1, open = "w")
        writeLines(get(name1), con = con)
        close(con)
    }

    # Combining chunks into one sentences vector

    size.ngrams <- rep(0, n_chunks)
    total_length <- 0 
    for(i in 1:n_chunks) {
        name1 <- names[i]
        this_length <- length(get(name1))
        size.ngrams[i] <- this_length
        total_length <- total_length + this_length
        cat("   ", sprintf("03d", i), "  Length of ", name1, " = ", this_length, "\n")
    }
    cat("    Total Length = ", total_length, "\n")
    
    name_for_all_ngrams <- paste("n", sprintf("%1d", ngram_size), "grams.twitter.all", sep = "")
    temp_all_ngrams <- vector(mode = "character", length = total_length)
    ivec <- c(0, cumsum(size.ngrams))
    for(i in 1:n_chunks) {
        i1 <- ivec[i] + 1
        i2 <- ivec[i+1]
        name <- names[i]
        cat("   ", i, i1, i2, name, "\n")
        temp_all_ngrams[i1:i2] <- get(name)
    }

    assign( name_for_all_ngrams, temp_all_ngrams )

    fname <- paste("output/", "n", sprintf("%1d", ngram_size), "grams.twitter.all", sep = "")
    con <- gzfile(fname, open = "w")
    writeLines(twitter.sentences.all, con = con)
    close(con)
    
}

rm(i, n1, n2, n_chunks)
# rm(list=ls(pattern = "^n[1-5]grams.twitter.]"))

cat("\n *** ENDING  [", my_date(), "]------------------------------------------------------------\n")

q(save = "yes")
#---------------------------------------------------------------------------------------------------

#===================================================================================================
# #----- BLOGS ------------------------------------
# cat(" *** Tokenizing n-grams in blogs dataset : ", my_date(), "------------------------------------------------------------\n")
# end.blogs <- length(sel.blogs.sentences)
# cat(" *** Number of sentences in the blogs data set : ", end.blogs, "\n")
# # 441996
# 
# #----- 1-grams -----
# cat(" *** Tokenizing : blogs : 1-grams ------------------------------------------------------------\n")
# system.time( n1grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# 
# #----- 2-grams -----
# cat(" *** Tokenizing : blogs : 2-grams ------------------------------------------------------------\n")
# system.time( n2grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# 
# #----- 3-grams -----
# cat(" *** Tokenizing : blogs : 3-grams ------------------------------------------------------------\n")
# system.time( n3grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# ## 1480339 ## 1482030 ## 1479030 ## 1477194 ##  631661
# 
# #----- 4-grams -----
# cat(" *** Tokenizing : blogs : 4-grams ------------------------------------------------------------\n")
# system.time( n4grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# ## 1385276 ## 1386941 ## 1383863 ## 1382009 ##  591634
# 
# #----- 5-grams -----
# cat(" *** Tokenizing : blogs : 5-grams ------------------------------------------------------------\n")
# system.time( n5grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# ## 1293716 ## 1295314 ## 1292110 ## 1290310 ##  553035
# 
# cat(" *** Combining split N-grams vector ------------------------------------------------------------\n")
# source("./scripts/combine_nXgrams_blogs.R")
# 
# #----- NEWS -------------------------------------
# cat(" *** Tokenizing n-grams in news dataset : ", my_date(), "------------------------------------------------------------\n")
# end.news <- length(sel.news.sentences)
# cat(" *** Number of sentences in the news data set : ", end.news, "\n")
# # 391286
# 
# #----- 1-grams -----
# cat(" *** Tokenizing : news : 1-grams ------------------------------------------------------------\n")
# system.time( n1grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# 
# #----- 2-grams -----
# cat(" *** Tokenizing : news : 2-grams ------------------------------------------------------------\n")
# system.time( n2grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# 
# #----- 3-grams -----
# cat(" *** Tokenizing : news : 3-grams ------------------------------------------------------------\n")
# system.time( n3grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# ## 1538280 ## 1535403 ## 1534954 ## 1402133
# 
# #----- 4-grams -----
# cat(" *** Tokenizing : news : 4-grams ------------------------------------------------------------\n")
# system.time( n4grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# ## 1442196 ## 1439274 ## 1438859 ## 1314429
# 
# #----- 5-grams -----
# cat(" *** Tokenizing : news : 5-grams ------------------------------------------------------------\n")
# system.time( n5grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# ## 1348977 ## 1346068 ## 1345613 ## 1229384
# 
# cat(" *** Combining split N-grams vector ------------------------------------------------------------\n")
# source("./scripts/combine_nXgrams_news.R")
# 
# #----- TWITTER ----------------------------------
# cat(" *** Tokenizing n-grams in twitter dataset : ", my_date(), "------------------------------------------------------------\n")
# end.twitter <- length(sel.twitter.sentences)
# cat(" *** Number of sentences in the twitter data set : ", end.twitter, "\n")
# # 736509
# 
# #----- 1-grams -----
# cat(" *** Tokenizing : twitter : 1-grams ------------------------------------------------------------\n")
# system.time( n1grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# system.time( n1grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
# 
# #----- 2-grams -----
# cat(" *** Tokenizing : twitter : 2-grams ------------------------------------------------------------\n")
# system.time( n2grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# system.time( n2grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
# 
# #----- 3-grams -----
# cat(" *** Tokenizing : twitter : 3-grams ------------------------------------------------------------\n")
# system.time( n3grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# system.time( n3grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
# ## 882848 ## 894610 ## 891990 ## 888937 ## 887111 ## 887242 ## 888466 ## 328230
# 
# #----- 4-grams -----
# cat(" *** Tokenizing : twitter : 4-grams ------------------------------------------------------------\n")
# system.time( n4grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# system.time( n4grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
# ## 825803 ## 837390 ## 834870 ## 831655 ## 830245 ## 830259 ## 831186 ## 307380
# 
# #----- 5-grams -----
# cat(" *** Tokenizing : twitter : 5-grams ------------------------------------------------------------\n")
# system.time( n5grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# system.time( n5grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
# ## 770875 ## 782209 ## 779816 ## 776462 ## 775474 ## 775377 ## 775982 ## 287280
# 
# cat(" *** Combining split N-grams vector ------------------------------------------------------------\n")
# source("./scripts/combine_nXgrams_twitter.R")

#-------------------

cat(" *** Counting n-grams frequencies in blogs dataset : ", my_date(), "------------------------------------------------------------\n")
# word frequency and n-grams frequencies with 'table'

n1grams.blogs.freq <- as.data.frame(table(n1grams.blogs.all), stringsAsFactors = FALSE)
n1grams.blogs.freq <- n1grams.blogs.freq[order(n1grams.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n1grams.blogs.freq) <- NULL
head(n1grams.blogs.freq, 20)

n2grams.blogs.freq <- as.data.frame(table(n2grams.blogs.all), stringsAsFactors = FALSE)
n2grams.blogs.freq <- n2grams.blogs.freq[order(n2grams.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n2grams.blogs.freq) <- NULL
head(n2grams.blogs.freq, 20)

n3grams.blogs.freq <- as.data.frame(table(n3grams.blogs.all), stringsAsFactors = FALSE)
n3grams.blogs.freq <- n3grams.blogs.freq[order(n3grams.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n3grams.blogs.freq) <- NULL
head(n3grams.blogs.freq, 20)

n4grams.blogs.freq <- as.data.frame(table(n4grams.blogs.all), stringsAsFactors = FALSE)
n4grams.blogs.freq <- n4grams.blogs.freq[order(n4grams.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n4grams.blogs.freq) <- NULL
head(n4grams.blogs.freq, 20)

n5grams.blogs.freq <- as.data.frame(table(n5grams.blogs.all), stringsAsFactors = FALSE)
n5grams.blogs.freq <- n5grams.blogs.freq[order(n5grams.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n5grams.blogs.freq) <- NULL
head(n5grams.blogs.freq, 20)

colnames(n1grams.blogs.freq) <- c("ngram", "count")
colnames(n2grams.blogs.freq) <- c("ngram", "count")
colnames(n3grams.blogs.freq) <- c("ngram", "count")
colnames(n4grams.blogs.freq) <- c("ngram", "count")
colnames(n5grams.blogs.freq) <- c("ngram", "count")

#---
cat(" *** Counting n-grams frequencies in news dataset : ", my_date(), "------------------------------------------------------------\n")
n1grams.news.freq <- as.data.frame(table(n1grams.news.all), stringsAsFactors = FALSE)
n1grams.news.freq <- n1grams.news.freq[order(n1grams.news.freq$Freq, decreasing = TRUE), ]
row.names(n1grams.news.freq) <- NULL
head(n1grams.news.freq, 20)

n2grams.news.freq <- as.data.frame(table(n2grams.news.all), stringsAsFactors = FALSE)
n2grams.news.freq <- n2grams.news.freq[order(n2grams.news.freq$Freq, decreasing = TRUE), ]
row.names(n2grams.news.freq) <- NULL
head(n2grams.news.freq, 20)

n3grams.news.freq <- as.data.frame(table(n3grams.news.all), stringsAsFactors = FALSE)
n3grams.news.freq <- n3grams.news.freq[order(n3grams.news.freq$Freq, decreasing = TRUE), ]
row.names(n3grams.news.freq) <- NULL
head(n3grams.news.freq, 20)

n4grams.news.freq <- as.data.frame(table(n4grams.news.all), stringsAsFactors = FALSE)
n4grams.news.freq <- n4grams.news.freq[order(n4grams.news.freq$Freq, decreasing = TRUE), ]
row.names(n4grams.news.freq) <- NULL
head(n4grams.news.freq, 20)

n5grams.news.freq <- as.data.frame(table(n5grams.news.all), stringsAsFactors = FALSE)
n5grams.news.freq <- n5grams.news.freq[order(n5grams.news.freq$Freq, decreasing = TRUE), ]
row.names(n5grams.news.freq) <- NULL
head(n5grams.news.freq, 20)

colnames(n1grams.news.freq) <- c("ngram", "count")
colnames(n2grams.news.freq) <- c("ngram", "count")
colnames(n3grams.news.freq) <- c("ngram", "count")
colnames(n4grams.news.freq) <- c("ngram", "count")
colnames(n5grams.news.freq) <- c("ngram", "count")

#---
cat(" *** Counting n-grams frequencies in twitter dataset : ", my_date(), "------------------------------------------------------------\n")
n1grams.twitter.freq <- as.data.frame(table(n1grams.twitter.all), stringsAsFactors = FALSE)
n1grams.twitter.freq <- n1grams.twitter.freq[order(n1grams.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n1grams.twitter.freq) <- NULL
head(n1grams.twitter.freq, 20)

n2grams.twitter.freq <- as.data.frame(table(n2grams.twitter.all), stringsAsFactors = FALSE)
n2grams.twitter.freq <- n2grams.twitter.freq[order(n2grams.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n2grams.twitter.freq) <- NULL
head(n2grams.twitter.freq, 20)

n3grams.twitter.freq <- as.data.frame(table(n3grams.twitter.all), stringsAsFactors = FALSE)
n3grams.twitter.freq <- n3grams.twitter.freq[order(n3grams.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n3grams.twitter.freq) <- NULL
head(n3grams.twitter.freq, 20)

n4grams.twitter.freq <- as.data.frame(table(n4grams.twitter.all), stringsAsFactors = FALSE)
n4grams.twitter.freq <- n4grams.twitter.freq[order(n4grams.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n4grams.twitter.freq) <- NULL
head(n4grams.twitter.freq, 20)

n5grams.twitter.freq <- as.data.frame(table(n5grams.twitter.all), stringsAsFactors = FALSE)
n5grams.twitter.freq <- n5grams.twitter.freq[order(n5grams.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n5grams.twitter.freq) <- NULL
head(n5grams.twitter.freq, 20)

colnames(n1grams.twitter.freq) <- c("ngram", "count")
colnames(n2grams.twitter.freq) <- c("ngram", "count")
colnames(n3grams.twitter.freq) <- c("ngram", "count")
colnames(n4grams.twitter.freq) <- c("ngram", "count")
colnames(n5grams.twitter.freq) <- c("ngram", "count")

cat(" *** ENDING : ", my_date(), "------------------------------------------------------------\n")

q(save = "yes")
#---------------------------------------------------------------------------------------------------
