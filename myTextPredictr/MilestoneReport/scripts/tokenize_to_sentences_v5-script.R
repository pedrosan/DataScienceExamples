#!/usr/bin/Rscript

#---------------------------------------------------------------------------------------------------
# library("stringi")
require("NLP")
require("openNLP")

require("magrittr")
require("devtools")

#-----------------------------------------------------------
# source("scripts/tasks_v2_functions.R")
# source("my_functions.R")
find_sentences <- function(x) {
    s <- paste(x, collapse = " ") %>% as.String()
    a <- NLP::annotate(s , sent_token_annotator) 
    as.vector(s[a])
}

#---------------------------------------------------------------------------------------------------

cat(" *** loading data : ", date(), "------------------------------------------------------------\n")

load("in.blogs.REG.RData")
load("in.news.REG.RData")
load("in.twitter.REG.RData")

len.blogs   <- length(in.blogs)
len.news    <- length(in.news)
len.twitter <- length(in.twitter)

cat(" n rows for blogs    = ", len.blogs, "\n")
cat(" n rows for news     = ", len.news, "\n")
cat(" n rows for twitter  = ", len.twitter, "\n")

#-----------------------------------------------------------
sent_token_annotator <- Maxent_Sent_Token_Annotator()
sent_token_annotator

#-----------------------------------------------------------
chunk_size <- 100000

for( what in c("blogs", "news", "twitter")) {
    
    data.what <- get(paste0("in.", what))
    len.what   <- length(data.what)
    cat(" - length ", len.what, "\n")
    
    n_chunks <- floor(len.what/chunk_size) + 1
    n1 <- ((1:n_chunks)-1)*chunk_size + 1
    n2 <- (1:n_chunks)*chunk_size
    n2[n_chunks] <- len.what
    Ns_by_chunk <- rep(0, n_chunks)
    print(n1)
    print(n2)
    
    names <- paste(what, "sentences", sprintf("%02d", (1:n_chunks)), sep = ".")
    fnames <- paste(names, ".gz", sep = "")
    print(names)
    print(fnames)
    
    for(i in 1:n_chunks) {
        name1 <- names[i]
        fname1 <- fnames[i]
        idx <- n1[i]:n2[i]
        
        cat("   ", name1, length(idx), idx[1], idx[length(idx)], "\n")
        assign( name1, sapply(data.what[idx], FUN = find_sentences, USE.NAMES = FALSE) %>% unlist )
        con <- gzfile(fname1, open = "w")
        writeLines(get(name1), con = con)
        close(con)
    }
    rm(i, n1, n2, n_chunks)
}
#-----------------------------------------------------------

cat(" *** ENDING : ", date(), "------------------------------------------------------------\n")

q(save = "no")

#---------------------------------------------------------------------------------------------------
