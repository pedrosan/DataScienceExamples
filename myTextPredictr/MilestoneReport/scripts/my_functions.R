
## ---- my_functions

#===================================================================================================
# modified readLines

readByLine <- function(fname, check_nl = TRUE, skipNul = TRUE) {
    if( check_nl ) {
        cmd.nl   <- paste("gzip -dc", fname, "| wc -l | awk '{print $1}'", sep = " ")
        nl   <- system(cmd.nl, intern = TRUE)
    } else {
        nl   <- -1L
    }
    con <- gzfile(fname, open = "r")
    on.exit(close(con))
    readLines(con, n = nl, skipNul = skipNul) 
}

#===================================================================================================
# to use w/ sapply for finer sentence splitting.

find_sentences <- function(x) {
    s <- paste(x, collapse = " ") %>% as.String()
    a <- NLP::annotate(s , sent_token_annotator) 
    as.vector(s[a])
}

#===================================================================================================

## ---- end-of-my_functions

