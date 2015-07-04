#---------------------------------------------------------------------------------------------------
# NEWS
#---------------------------------------------------------------------------------------------------
nl.chunk <- 100000
N <- ceiling(length(sel.news.sentences)/nl.chunk)

#--- n1 ---#
size.n1g.news <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n1grams.news.", i, collapse = "")
    size.n1g.news[i] <- length(get(name))
    cat(" Number of 1-grams in set", i, " : ", size.n1g.news[i], "\n")
}

n1grams.news.all <- vector(mode = "character", length = sum(size.n1g.news))
ivec <- c(0, cumsum(size.n1g.news))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n1grams.news.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n1grams.news.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n1grams.news.[1-4]"))

#--- n2 ---#
size.n2g.news <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n2grams.news.", i, collapse = "")
    size.n2g.news[i] <- length(get(name))
    cat(" Number of 2-grams in set", i, " : ", size.n2g.news[i], "\n")
}

n2grams.news.all <- vector(mode = "character", length = sum(size.n2g.news))
ivec <- c(0, cumsum(size.n2g.news))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n2grams.news.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n2grams.news.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n2grams.news.[1-4]"))

#--- n3 ---#
size.n3g.news <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n3grams.news.", i, collapse = "")
    size.n3g.news[i] <- length(get(name))
    cat(" Number of 3-grams in set", i, " : ", size.n3g.news[i], "\n")
}

n3grams.news.all <- vector(mode = "character", length = sum(size.n3g.news))
ivec <- c(0, cumsum(size.n3g.news))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n3grams.news.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n3grams.news.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n3grams.news.[1-4]"))

#--- n4 ---#
size.n4g.news <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n4grams.news.", i, collapse = "")
    size.n4g.news[i] <- length(get(name))
    cat(" Number of 4-grams in set", i, " : ", size.n4g.news[i], "\n")
}

n4grams.news.all <- vector(mode = "character", length = sum(size.n4g.news))
ivec <- c(0, cumsum(size.n4g.news))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n4grams.news.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n4grams.news.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n4grams.news.[1-4]"))

#--- n5 ---#
size.n5g.news <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n5grams.news.", i, collapse = "")
    size.n5g.news[i] <- length(get(name))
    cat(" Number of 5-grams in set", i, " : ", size.n5g.news[i], "\n")
}

n5grams.news.all <- vector(mode = "character", length = sum(size.n5g.news))
ivec <- c(0, cumsum(size.n5g.news))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n5grams.news.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n5grams.news.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n5grams.news.[1-5]"))

#---------------------------------------------------------------------------------------------------
