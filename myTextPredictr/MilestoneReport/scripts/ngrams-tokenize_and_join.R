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

#---------------------------------------------------------------------------------------------------
# source("../scripts/tasks_v2_functions.R")
source("my_functions.R")

#---------------------------------------------------------------------------------------------------
all.sentences.ALL <- readByLine("./all.sentences.GO.gz", check_nl = FALSE, skipNul = TRUE)

# 2015.04.17: added 'rt' to stopwords 
# my_stop_words <- c("a", "an", "as", "at", "no", "of", "on", "or", "by", "so", "up", "or", "no", "in", "to")
my_stop_words <- c("a", "an", "as", "at", "no", "of", "on", "or", "by", "so", "up", "or", "no", "in", "to", "rt")

all_nostop <- removeWords(all.sentences.ALL, my_stop_words) %>% 
    gsub(" +", " ", . , perl = TRUE) %>% 
    gsub("^ +", "", . , perl = TRUE) %>% 
    gsub(" +$", "", . , perl = TRUE)

all.sentences <- all_nostop
rm(all_nonstop)

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
token_delim <- token_delimiters_2

#===================================================================================================

cat("====================================================================================================\n")
cat(" *** N-GRAM TOKENIZATION [", my_date(), "]------------------------------------------------------------\n")

nl.chunk <- 25000

#---------------------------------------------------------------------------------------------------
# ALL
#---------------------------------------------------------------------------------------------------
gc()

cat(" *** Tokenizing n-grams in WHOLE dataset  [", my_date(), "]------------------------------------------------------------\n")

len.all.sentences <- length(all.sentences)
cat(" *** Number of sentences in the WHOLE data set : ", len.all.sentences, "\n")

subs <- strsplit(all.sentences, split = "[ ;,.\"\t\r\n()!?]+")
nstr.subs  <- sapply(subs, FUN = function(x) {length(unlist(x))}, USE.NAMES = FALSE)
rm(subs)

for( ngram_size in 4:5 ) {
    cat(" *** Tokenizing : WHOLE : ", ngram_size, "-grams ------------------------------------------------------------\n")
    
    good.sentences <- all.sentences[nstr.subs >= ngram_size]
    len.good <- length(good.sentences)
    cat("   Sentences with good length ( >=", ngram_size, ") : ", sprintf("%7d", len.good), "\n")
    cat("   Sentences with good length ( >=", ngram_size, ") : ", sprintf("%7d", len.good), "(of ", sprintf("%7d", len.all.sentences), ")\n")

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
    
    rm(i, n1, n2, n_chunks)
    ls(pattern = "^n[1-6]grams.blogs.[0-9]")
    rm(list = ls(pattern = "^n[1-6]grams.blogs.[0-9]") )
    gc()

}

# rm(i, n1, n2, n_chunks)
# ls(pattern = "^n[1-5]grams.blogs.[0-9]")
# rm(list = ls(pattern = "^n[1-5]grams.blogs.[0-9]") )
# gc()


cat("\n *** ENDING  [", my_date(), "]------------------------------------------------------------\n")

q(save = "yes")
#===================================================================================================
#===================================================================================================


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

cat(" *** ENDING : ", my_date(), "------------------------------------------------------------\n")

q(save = "yes")
#---------------------------------------------------------------------------------------------------
