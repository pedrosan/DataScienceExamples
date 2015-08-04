#!/usr/bin/Rscript

#---------------------------------------------------------------------------------------------------
library("tm")
library("SnowballC")
library("openNLP")

# To help java fail less :-(
options( java.parameters = "-Xmx6g")
library("RWeka")   # [NGramTokenizer], [Weka_control]

#-----------------------------
library("magrittr")
library("devtools")

#library("ggplot2")
#library("RColorBrewer")

#---------------------------------------------------------------------------------------------------
source("my_functions.R")
#---------------------------------------------------------------------------------------------------

#---------------------------------------
# LOADING DATA
#---------------------------------------
# in.blogs.ORIG <- readByLine("data/en_US.blogs.txt.gz", check_nl = FALSE, skipNul = TRUE)
# in.news.ORIG <- readByLine("data/en_US.news.txt.gz", check_nl = FALSE, skipNul = TRUE)
# in.twitter.ORIG <- readByLine("data/en_US.twitter.txt.gz", check_nl = FALSE, skipNul = TRUE)

in.blogs.CL <- readByLine("data/en_US.blogs.CLEANED1.txt.gz", check_nl = FALSE, skipNul = TRUE)
in.news.CL <- readByLine("data/en_US.news.CLEANED1.txt.gz", check_nl = FALSE, skipNul = TRUE)
in.twitter.CL <- readByLine("data/en_US.twitter.CLEANED1.txt.gz", check_nl = FALSE, skipNul = TRUE)

#---------------------------------------------------------------------------------------------------
# Excluding rows with too few characters
# The 'nl.*' vectors keep track of the original line numbers, mostly for debugging
#-----------------------------------------
nchar.min <- 6

cat(" *** Beginning check of Nchar : ", date(), "------------------------------------------------------------\n")
nl.blogs.CL <- 1:length(in.blogs.CL)
in.blogs.CL.cleaned <- tolower(in.blogs.CL) %>% removeNumbers() %>% stripWhitespace()
nchar.blogs.CL <- nchar(in.blogs.CL.cleaned)
in.blogs.CL.cleaned <- in.blogs.CL.cleaned[nchar.blogs.CL > nchar.min]
nl.blogs.CL <- nl.blogs.CL[nchar.blogs.CL > nchar.min]

nl.news.CL <- 1:length(in.news.CL)
in.news.CL.cleaned <- tolower(in.news.CL) %>% removeNumbers() %>% stripWhitespace()
nchar.news.CL <- nchar(in.news.CL.cleaned)
in.news.CL.cleaned <- in.news.CL.cleaned[nchar.news.CL > nchar.min]
nl.news.CL <- nl.news.CL[nchar.news.CL > nchar.min]

nl.twitter.CL <- 1:length(in.twitter.CL)
in.twitter.CL.cleaned <- tolower(in.twitter.CL) %>% removeNumbers() %>% stripWhitespace()
nchar.twitter.CL <- nchar(in.twitter.CL.cleaned)
in.twitter.CL.cleaned <- in.twitter.CL.cleaned[nchar.twitter.CL > nchar.min]
nl.twitter.CL <- nl.twitter.CL[nchar.twitter.CL > nchar.min]
cat(" *** End check of Nchar : ", date(), "------------------------------------------------------------\n")

#-------------------

nl.blogs <- nl.blogs.CL
in.blogs <- in.blogs.CL.cleaned
nl.news <- nl.news.CL
in.news <- in.news.CL.cleaned
nl.twitter <- nl.twitter.CL
in.twitter <- in.twitter.CL.cleaned

#---------------------------------------------------------------------------------------------------
# random subsetting of the dataset
#-----------------------------------------
fraction <- 0.2

cat(" *** Sampling data for analysis subset : ", date(), "------------------------------------------------------------\n")
set.seed(6420)
idx.blogs   <- sample(1:length(in.blogs), ceiling(fraction*length(in.blogs)))
idx.news    <- sample(1:length(in.news), ceiling(fraction*length(in.news)))
idx.twitter <- sample(1:length(in.twitter), ceiling(fraction*length(in.twitter)))

nl.blogs    <- nl.blogs[idx.blogs]
sel.blogs   <- in.blogs[idx.blogs]
nl.news     <- nl.news[idx.news]
sel.news    <- in.news[idx.news]
nl.twitter  <- nl.twitter[idx.twitter]
sel.twitter <- in.twitter[idx.twitter]

#---------------------------------------------------------------------------------------------------
# Trying/Using 'openNLP' sentence annotator
#--------------------------------------------

sent_token_annotator <- Maxent_Sent_Token_Annotator()
sent_token_annotator

#---------------------------------------------------------------------------------------------------

cat(" *** Annotating sentences in blogs dataset : ", date(), "------------------------------------------------------------\n")
system.time({ sel.blogs.sentences <- sapply(sel.blogs, FUN = find_sentences, USE.NAMES = FALSE) %>% unlist })
cat(" *** N_sentences = ", length(sel.blogs.sentences), " ------------------------------------------------------------\n")

cat(" *** Annotating sentences in news dataset : ", date(), "------------------------------------------------------------\n")
system.time({ sel.news.sentences <- sapply(sel.news, FUN = find_sentences, USE.NAMES = FALSE) %>% unlist })
cat("   N_sentences = ", length(sel.news.sentences), " ------------------------------------------------------------\n")

cat(" *** Annotating sentences in twitter dataset : ", date(), "------------------------------------------------------------\n")
system.time({ sel.twitter.sentences <- sapply(sel.twitter, FUN = find_sentences, USE.NAMES = FALSE) %>% unlist })
cat("   N_sentences = ", length(sel.twitter.sentences), " ------------------------------------------------------------\n")


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

nl.chunk <- 100000
N <- ceiling(length(sel.blogs.sentences)/nl.chunk)

#----- BLOGS ------------------------------------
cat(" *** Tokenizing n-grams in blogs dataset : ", date(), "------------------------------------------------------------\n")
end.blogs <- length(sel.blogs.sentences)
cat(" *** Number of sentences in the blogs data set : ", end.blogs, "\n")
# 441996

#----- 1-grams -----
cat(" *** Tokenizing : blogs : 1-grams ------------------------------------------------------------\n")
system.time( n1grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 1, max = 1, delimiters = token_delim)) )

#----- 2-grams -----
cat(" *** Tokenizing : blogs : 2-grams ------------------------------------------------------------\n")
system.time( n2grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 2, max = 2, delimiters = token_delim)) )

#----- 3-grams -----
cat(" *** Tokenizing : blogs : 3-grams ------------------------------------------------------------\n")
system.time( n3grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
## 1480339 ## 1482030 ## 1479030 ## 1477194 ##  631661

#----- 4-grams -----
cat(" *** Tokenizing : blogs : 4-grams ------------------------------------------------------------\n")
system.time( n4grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
## 1385276 ## 1386941 ## 1383863 ## 1382009 ##  591634

#----- 5-grams -----
cat(" *** Tokenizing : blogs : 5-grams ------------------------------------------------------------\n")
system.time( n5grams.blogs.1 <- NGramTokenizer(sel.blogs.sentences[1:100000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.blogs.2 <- NGramTokenizer(sel.blogs.sentences[100001:200000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.blogs.3 <- NGramTokenizer(sel.blogs.sentences[200001:300000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.blogs.4 <- NGramTokenizer(sel.blogs.sentences[300001:400000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.blogs.5 <- NGramTokenizer(sel.blogs.sentences[400001:end.blogs], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
## 1293716 ## 1295314 ## 1292110 ## 1290310 ##  553035

cat(" *** Combining split N-grams vector ------------------------------------------------------------\n")
source("./combine_nXgrams_blogs.R")

#----- NEWS -------------------------------------
cat(" *** Tokenizing n-grams in news dataset : ", date(), "------------------------------------------------------------\n")
end.news <- length(sel.news.sentences)
cat(" *** Number of sentences in the news data set : ", end.news, "\n")
# 391286

#----- 1-grams -----
cat(" *** Tokenizing : news : 1-grams ------------------------------------------------------------\n")
system.time( n1grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 1, max = 1, delimiters = token_delim)) )

#----- 2-grams -----
cat(" *** Tokenizing : news : 2-grams ------------------------------------------------------------\n")
system.time( n2grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 2, max = 2, delimiters = token_delim)) )

#----- 3-grams -----
cat(" *** Tokenizing : news : 3-grams ------------------------------------------------------------\n")
system.time( n3grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
## 1538280 ## 1535403 ## 1534954 ## 1402133

#----- 4-grams -----
cat(" *** Tokenizing : news : 4-grams ------------------------------------------------------------\n")
system.time( n4grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
## 1442196 ## 1439274 ## 1438859 ## 1314429

#----- 5-grams -----
cat(" *** Tokenizing : news : 5-grams ------------------------------------------------------------\n")
system.time( n5grams.news.1 <- NGramTokenizer(sel.news.sentences[1:100000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.news.2 <- NGramTokenizer(sel.news.sentences[100001:200000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.news.3 <- NGramTokenizer(sel.news.sentences[200001:300000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.news.4 <- NGramTokenizer(sel.news.sentences[300001:end.news], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
## 1348977 ## 1346068 ## 1345613 ## 1229384

cat(" *** Combining split N-grams vector ------------------------------------------------------------\n")
source("./combine_nXgrams_news.R")

#----- TWITTER ----------------------------------
cat(" *** Tokenizing n-grams in twitter dataset : ", date(), "------------------------------------------------------------\n")
end.twitter <- length(sel.twitter.sentences)
cat(" *** Number of sentences in the twitter data set : ", end.twitter, "\n")
# 736509

#----- 1-grams -----
cat(" *** Tokenizing : twitter : 1-grams ------------------------------------------------------------\n")
system.time( n1grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 1, max = 1, delimiters = token_delim)) )
system.time( n1grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 1, max = 1, delimiters = token_delim)) )

#----- 2-grams -----
cat(" *** Tokenizing : twitter : 2-grams ------------------------------------------------------------\n")
system.time( n2grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 2, max = 2, delimiters = token_delim)) )
system.time( n2grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 2, max = 2, delimiters = token_delim)) )

#----- 3-grams -----
cat(" *** Tokenizing : twitter : 3-grams ------------------------------------------------------------\n")
system.time( n3grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
system.time( n3grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 3, max = 3, delimiters = token_delim)) )
## 882848 ## 894610 ## 891990 ## 888937 ## 887111 ## 887242 ## 888466 ## 328230

#----- 4-grams -----
cat(" *** Tokenizing : twitter : 4-grams ------------------------------------------------------------\n")
system.time( n4grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
system.time( n4grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 4, max = 4, delimiters = token_delim)) )
## 825803 ## 837390 ## 834870 ## 831655 ## 830245 ## 830259 ## 831186 ## 307380

#----- 5-grams -----
cat(" *** Tokenizing : twitter : 5-grams ------------------------------------------------------------\n")
system.time( n5grams.twitter.1 <- NGramTokenizer(sel.twitter.sentences[1:100000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.2 <- NGramTokenizer(sel.twitter.sentences[100001:200000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.3 <- NGramTokenizer(sel.twitter.sentences[200001:300000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.4 <- NGramTokenizer(sel.twitter.sentences[300001:400000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.5 <- NGramTokenizer(sel.twitter.sentences[400001:500000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.6 <- NGramTokenizer(sel.twitter.sentences[500001:600000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.7 <- NGramTokenizer(sel.twitter.sentences[600001:700000], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
system.time( n5grams.twitter.8 <- NGramTokenizer(sel.twitter.sentences[700001:end.twitter], Weka_control(min = 5, max = 5, delimiters = token_delim)) )
## 770875 ## 782209 ## 779816 ## 776462 ## 775474 ## 775377 ## 775982 ## 287280

cat(" *** Combining split N-grams vector ------------------------------------------------------------\n")
source("./combine_nXgrams_twitter.R")

#-------------------

cat(" *** Counting n-grams frequencies in blogs dataset : ", date(), "------------------------------------------------------------\n")
# word frequency and n-grams frequencies with 'table'

n1g.blogs.freq <- as.data.frame(table(n1grams.blogs.all), stringsAsFactors = FALSE)
n1g.blogs.freq <- n1g.blogs.freq[order(n1g.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n1g.blogs.freq) <- NULL
head(n1g.blogs.freq, 20)

n2g.blogs.freq <- as.data.frame(table(n2grams.blogs.all), stringsAsFactors = FALSE)
n2g.blogs.freq <- n2g.blogs.freq[order(n2g.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n2g.blogs.freq) <- NULL
head(n2g.blogs.freq, 20)

n3g.blogs.freq <- as.data.frame(table(n3grams.blogs.all), stringsAsFactors = FALSE)
n3g.blogs.freq <- n3g.blogs.freq[order(n3g.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n3g.blogs.freq) <- NULL
head(n3g.blogs.freq, 20)

n4g.blogs.freq <- as.data.frame(table(n4grams.blogs.all), stringsAsFactors = FALSE)
n4g.blogs.freq <- n4g.blogs.freq[order(n4g.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n4g.blogs.freq) <- NULL
head(n4g.blogs.freq, 20)

n5g.blogs.freq <- as.data.frame(table(n5grams.blogs.all), stringsAsFactors = FALSE)
n5g.blogs.freq <- n5g.blogs.freq[order(n5g.blogs.freq$Freq, decreasing = TRUE), ]
row.names(n5g.blogs.freq) <- NULL
head(n5g.blogs.freq, 20)

colnames(n1g.blogs.freq) <- c("ngram", "count")
colnames(n2g.blogs.freq) <- c("ngram", "count")
colnames(n3g.blogs.freq) <- c("ngram", "count")
colnames(n4g.blogs.freq) <- c("ngram", "count")
colnames(n5g.blogs.freq) <- c("ngram", "count")

#---
cat(" *** Counting n-grams frequencies in news dataset : ", date(), "------------------------------------------------------------\n")
n1g.news.freq <- as.data.frame(table(n1grams.news.all), stringsAsFactors = FALSE)
n1g.news.freq <- n1g.news.freq[order(n1g.news.freq$Freq, decreasing = TRUE), ]
row.names(n1g.news.freq) <- NULL
head(n1g.news.freq, 20)

n2g.news.freq <- as.data.frame(table(n2grams.news.all), stringsAsFactors = FALSE)
n2g.news.freq <- n2g.news.freq[order(n2g.news.freq$Freq, decreasing = TRUE), ]
row.names(n2g.news.freq) <- NULL
head(n2g.news.freq, 20)

n3g.news.freq <- as.data.frame(table(n3grams.news.all), stringsAsFactors = FALSE)
n3g.news.freq <- n3g.news.freq[order(n3g.news.freq$Freq, decreasing = TRUE), ]
row.names(n3g.news.freq) <- NULL
head(n3g.news.freq, 20)

n4g.news.freq <- as.data.frame(table(n4grams.news.all), stringsAsFactors = FALSE)
n4g.news.freq <- n4g.news.freq[order(n4g.news.freq$Freq, decreasing = TRUE), ]
row.names(n4g.news.freq) <- NULL
head(n4g.news.freq, 20)

n5g.news.freq <- as.data.frame(table(n5grams.news.all), stringsAsFactors = FALSE)
n5g.news.freq <- n5g.news.freq[order(n5g.news.freq$Freq, decreasing = TRUE), ]
row.names(n5g.news.freq) <- NULL
head(n5g.news.freq, 20)

colnames(n1g.news.freq) <- c("ngram", "count")
colnames(n2g.news.freq) <- c("ngram", "count")
colnames(n3g.news.freq) <- c("ngram", "count")
colnames(n4g.news.freq) <- c("ngram", "count")
colnames(n5g.news.freq) <- c("ngram", "count")

#---
cat(" *** Counting n-grams frequencies in twitter dataset : ", date(), "------------------------------------------------------------\n")
n1g.twitter.freq <- as.data.frame(table(n1grams.twitter.all), stringsAsFactors = FALSE)
n1g.twitter.freq <- n1g.twitter.freq[order(n1g.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n1g.twitter.freq) <- NULL
head(n1g.twitter.freq, 20)

n2g.twitter.freq <- as.data.frame(table(n2grams.twitter.all), stringsAsFactors = FALSE)
n2g.twitter.freq <- n2g.twitter.freq[order(n2g.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n2g.twitter.freq) <- NULL
head(n2g.twitter.freq, 20)

n3g.twitter.freq <- as.data.frame(table(n3grams.twitter.all), stringsAsFactors = FALSE)
n3g.twitter.freq <- n3g.twitter.freq[order(n3g.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n3g.twitter.freq) <- NULL
head(n3g.twitter.freq, 20)

n4g.twitter.freq <- as.data.frame(table(n4grams.twitter.all), stringsAsFactors = FALSE)
n4g.twitter.freq <- n4g.twitter.freq[order(n4g.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n4g.twitter.freq) <- NULL
head(n4g.twitter.freq, 20)

n5g.twitter.freq <- as.data.frame(table(n5grams.twitter.all), stringsAsFactors = FALSE)
n5g.twitter.freq <- n5g.twitter.freq[order(n5g.twitter.freq$Freq, decreasing = TRUE), ]
row.names(n5g.twitter.freq) <- NULL
head(n5g.twitter.freq, 20)

colnames(n1g.twitter.freq) <- c("ngram", "count")
colnames(n2g.twitter.freq) <- c("ngram", "count")
colnames(n3g.twitter.freq) <- c("ngram", "count")
colnames(n4g.twitter.freq) <- c("ngram", "count")
colnames(n5g.twitter.freq) <- c("ngram", "count")

cat(" *** ENDING : ", date(), "------------------------------------------------------------\n")

q(save = "yes")
#---------------------------------------------------------------------------------------------------
