#!/usr/bin/Rscript

#---------------------------------------------------------------------------------------------------
# library("stringi")
require("NLP")
require("openNLP")

require("magrittr")
require("devtools")

source("scripts/tasks_v2_functions.R")
#---------------------------------------------------------------------------------------------------

cat(" *** loading data : ", date(), "------------------------------------------------------------\n")

load("data/ata1.blogs.main.RData")
load("data/ata1.news.main.RData")
load("data/ata1.twitter.main.RData")

in.blogs.CL.cleaned <- blogs.main$level1
in.news.CL.cleaned <- news.main$level1
in.twitter.CL.cleaned <- twitter.main$level1

#-----------------------------------------------------------
sent_token_annotator <- Maxent_Sent_Token_Annotator()
sent_token_annotator

# blogs   :  891834 
# news    : 1007617
# twitter : 2357178
 
len.blogs   <- length(in.blogs.CL.cleaned)
len.news    <- length(in.news.CL.cleaned)
len.twitter <- length(in.twitter.CL.cleaned)

# chunk_size <- 5000
chunk_size <- 100000

#-----------------------------------------------------------
cat(" *** Processing blogs : ", date(), "------------------------------------------------------------\n")

n_chunks <- floor(len.blogs/chunk_size) + 1
n1 <- ((1:n_chunks)-1)*chunk_size + 1
n2 <- (1:n_chunks)*chunk_size
n2[n_chunks] <- len.blogs
Ns_by_chunk <- rep(0, n_chunks)

names <- paste("blogs.sentences", sprintf("%02d", (1:n_chunks)), sep = ".")
fnames <- paste(names, ".gz", sep = "")

for(i in 1:n_chunks) {
    name1 <- names[i]
    fname1 <- fnames[i]
    idx <- n1[i]:n2[i]

    cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    assign( name1, sapply(in.blogs.CL.cleaned[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )
    con <- gzfile(fname1, open = "w")
    writeLines(get(name1), con = con)
    close(con)
}
rm(i, n1, n2, n_chunks)

#-----------------------------------------------------------
cat(" *** Processing news : ", date(), "------------------------------------------------------------\n")

n_chunks <- floor(len.news/chunk_size) + 1
n1 <- ((1:n_chunks)-1)*chunk_size + 1
n2 <- (1:n_chunks)*chunk_size
n2[n_chunks] <- len.news
Ns_by_chunk <- rep(0, n_chunks)

names <- paste("news.sentences", sprintf("%02d", (1:n_chunks)), sep = ".")
fnames <- paste(names, ".gz", sep = "")

for(i in 1:n_chunks) {
    name1 <- names[i]
    fname1 <- fnames[i]
    idx <- n1[i]:n2[i]

    cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    assign( name1, sapply(in.news.CL.cleaned[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )
    con <- gzfile(fname1, open = "w")
    writeLines(get(name1), con = con)
    close(con)
}
rm(i, n1, n2, n_chunks)

#-----------------------------------------------------------
cat(" *** Processing twitter : ", date(), "------------------------------------------------------------\n")

n_chunks <- floor(len.twitter/chunk_size) + 1
n1 <- ((1:n_chunks)-1)*chunk_size + 1
n2 <- (1:n_chunks)*chunk_size
n2[n_chunks] <- len.twitter
Ns_by_chunk <- rep(0, n_chunks)

names <- paste("twitter.sentences", sprintf("%02d", (1:n_chunks)), sep = ".")
fnames <- paste(names, ".gz", sep = "")

for(i in 1:n_chunks) {
    name1 <- names[i]
    fname1 <- fnames[i]
    idx <- n1[i]:n2[i]

    cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
    assign( name1, sapply(in.twitter.CL.cleaned[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )
    con <- gzfile(fname1, open = "w")
    writeLines(get(name1), con = con)
    close(con)
}
rm(i, n1, n2, n_chunks)

#-----------------------------------------------------------

cat(" *** ENDING : ", date(), "------------------------------------------------------------\n")

q(save = "yes")

#---------------------------------------------------------------------------------------------------
