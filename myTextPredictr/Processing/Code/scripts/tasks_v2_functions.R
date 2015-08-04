#---------------------------------------------------------------------------------------------------
# system.time({f <- file("data/pop.dos", "rb"); a <- readChar(f, file.info("data/pop.dos")$size, useBytes = TRUE); close(f)})
# size <- system("gzip -l data/pop2.unix.gz | egrep -v compressed | awk '{print $2}' ", intern = TRUE)

#---------------------------------------------------------------------------------------------------
# readLines
#---------------

# from : gzfile
# It was readByLine.3b
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

#---------------------------------------------------------------------------------------------------
# to use w/ sapply for finer sentence splitting.
find_sentences <- function(x) {
    s <- paste(x, collapse = " ") %>% as.String()
    a <- NLP::annotate(s , sent_token_annotator) 
    as.vector(s[a])
}

my_date <- function() {
    format(Sys.time(), "%a %b %d %H:%M:%S %Y")
}

#---------------------------------------------------------------------------------------------------
# is.compile <- function(func) {
#     # this function lets us know if a function has been byte-coded or not
#     #If you have a better idea for how to do this - please let me know...
#     if(class(func) != "function") stop("You need to enter a function")
#     last_2_lines <- tail(capture.output(func),2)
#     any(grepl("bytecode:", last_2_lines)) # returns TRUE if it finds the text "bytecode:" in any of the last two lines of the function's print
# }
#---------------------------------------------------------------------------------------------------