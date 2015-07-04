#!/usr/bin/Rscript

#---------------------------------------------------------------------------------------------------
library("tm")
library("SnowballC")
#library("stringi")
library("openNLP")

# To help java fail less :-(
# options( java.parameters = "-Xmx4g")
options( java.parameters = "-Xmx6g")
library("RWeka")   # [NGramTokenizer], [Weka_control]

#-----------------------------
library("magrittr")
library("devtools")

#library("ggplot2")
#library("RColorBrewer")

#---------------------------------------------------------------------------------------------------
source("scripts/tasks_v2_functions.R")

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

#===================================================================================================

cat("====================================================================================================\n")
cat(" *** N-GRAM TOKENIZATION [", my_date(), "]------------------------------------------------------------\n")

nl.chunk <- 25000

#---------------------------------------------------------------------------------------------------
#  BLOGS
#---------------------------------------------------------------------------------------------------
gc()

cat(" *** Tokenizing n-grams in BLOGS dataset  [", my_date(), "]------------------------------------------------------------\n")

blogs.sentences.all <- readByLine("output/blogs.sentences.all.gz", check_nl = FALSE, skipNul = TRUE)

len.blogs.sentences <- length(blogs.sentences.all)
cat(" *** Number of sentences in the BLOGS data set : ", len.blogs.sentences, "\n")

subs <- strsplit(blogs.sentences.all, split = "[ ;,.\"\t\r\n()!?]+")
nstr.subs  <- sapply(subs, FUN = function(x) {length(unlist(x))}, USE.NAMES = FALSE)
rm(subs)

for( ngram_size in 2:4 ) {
    cat(" *** Tokenizing : BLOGS : ", ngram_size, "-grams ------------------------------------------------------------\n")
    
    good.sentences <- blogs.sentences.all[nstr.subs >= ngram_size]
    len.good <- length(good.sentences)
    cat("   Sentences with good length ( >=", ngram_size, ") : ", sprintf("%7d", len.good), "\n")

    n_chunks <- floor(len.good/nl.chunk) + 1
    n1 <- ((1:n_chunks)-1)*nl.chunk + 1
    n2 <- (1:n_chunks)*nl.chunk
    n2[n_chunks] <- len.good

    names <- paste("n", sprintf("%1d", ngram_size), "grams.blogs.", sprintf("%03d", (1:n_chunks)), sep = "")
    fnames <- paste("output/", names, ".gz", sep = "")
    
    for(i in 1:n_chunks) {
        name1 <- names[i]
        fname1 <- fnames[i]
        idx <- n1[i]:n2[i]
    
        cat("  [", sprintf("%3d", i), "/", sprintf("%3d", n_chunks), "]  ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    
        assign( name1, NGramTokenizer(good.sentences[idx], Weka_control(min = ngram_size, max = ngram_size, delimiters = token_delim)) )
        # assign( name1, NGramTokenizer(blogs.sentences.all[idx], Weka_control(min = ngram_size, max = ngram_size, delimiters = token_delim)) )
    
        con <- gzfile(fname1, open = "w")
        writeLines(get(name1), con = con)
        close(con)

        gc()
    }

    # Combining chunks into one sentences vector

    size.ngrams <- rep(0, n_chunks)
    total_length <- 0 
    for(i in 1:n_chunks) {
        name1 <- names[i]
        this_length <- length(get(name1))
        size.ngrams[i] <- this_length
        total_length <- total_length + this_length
        cat("  [", sprintf("%3d", i), "/", sprintf("%3d", n_chunks), "]  length of ", name1, " = ", this_length, "\n")
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

    fname <- paste("output/", "n", sprintf("%1d", ngram_size), "grams.blogs.all.gz", sep = "")
    con <- gzfile(fname, open = "w")
    writeLines(temp_all_ngrams, con = con)
    close(con)

    rm(good.sentences, len.good, temp_all_ngrams)
    
}

rm(i, n1, n2, n_chunks)
ls(pattern = "^n[1-5]grams.blogs.[0-9]")
rm(list = ls(pattern = "^n[1-5]grams.blogs.[0-9]") )
gc()


cat("\n *** ENDING  [", my_date(), "]------------------------------------------------------------\n")

# q(save = "yes")

#---------------------------------------------------------------------------------------------------
#  NEWS
#---------------------------------------------------------------------------------------------------
gc()

cat(" *** Tokenizing n-grams in NEWS dataset  [", my_date(), "]------------------------------------------------------------\n")

news.sentences.all <- readByLine("output/news.sentences.all.gz", check_nl = FALSE, skipNul = TRUE)

len.news.sentences <- length(news.sentences.all)
cat(" *** Number of sentences in the NEWS data set : ", len.news.sentences, "\n")

subs <- strsplit(news.sentences.all, split = "[ ;,.\"\t\r\n()!?]+")
nstr.subs <- sapply(subs, FUN = function(x) {length(unlist(x))}, USE.NAMES = FALSE)
rm(subs)

for( ngram_size in 2:4 ) {
    cat(" *** Tokenizing : NEWS : ", ngram_size, "-grams ------------------------------------------------------------\n")
    
    good.sentences <- news.sentences.all[nstr.subs >= ngram_size]
    len.good <- length(good.sentences)
    cat("   Sentences with good length ( >=", ngram_size, ") : ", sprintf("%7d", len.good), "\n")

    n_chunks <- floor(len.good/nl.chunk) + 1
    n1 <- ((1:n_chunks)-1)*nl.chunk + 1
    n2 <- (1:n_chunks)*nl.chunk
    n2[n_chunks] <- len.good

    names <- paste("n", sprintf("%1d", ngram_size), "grams.news.", sprintf("%03d", (1:n_chunks)), sep = "")
    fnames <- paste("output/", names, ".gz", sep = "")
    
    for(i in 1:n_chunks) {
        name1 <- names[i]
        fname1 <- fnames[i]
        idx <- n1[i]:n2[i]
    
        cat("  [", sprintf("%3d", i), "/", sprintf("%3d", n_chunks), "]  ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    
        assign( name1, NGramTokenizer(good.sentences[idx], Weka_control(min = ngram_size, max = ngram_size, delimiters = token_delim)) )
    
        con <- gzfile(fname1, open = "w")
        writeLines(get(name1), con = con)
        close(con)

        gc()
    }

    # Combining chunks into one sentences vector

    size.ngrams <- rep(0, n_chunks)
    total_length <- 0 
    for(i in 1:n_chunks) {
        name1 <- names[i]
        this_length <- length(get(name1))
        size.ngrams[i] <- this_length
        total_length <- total_length + this_length
        cat("  [", sprintf("%3d", i), "/", sprintf("%3d", n_chunks), "]  length of ", name1, " = ", this_length, "\n")
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

    fname <- paste("output/", "n", sprintf("%1d", ngram_size), "grams.news.all.gz", sep = "")
    con <- gzfile(fname, open = "w")
    writeLines(temp_all_ngrams, con = con)
    close(con)

    rm(good.sentences, len.good, temp_all_ngrams)
    
}

rm(i, n1, n2, n_chunks)
ls(pattern = "^n[1-5]grams.news.[0-9]")
rm(list = ls(pattern = "^n[1-5]grams.news.[0-9]") )
gc()

     #---------#
#----+ TWITTER +------------------------------------------------------------------------------------
     #---------#

# rm(list=ls(pattern = "^n[1-5]grams.twitter.]"))

cat("\n *** ENDING  [", my_date(), "]------------------------------------------------------------\n")

q(save = "yes")
#---------------------------------------------------------------------------------------------------

#===================================================================================================
