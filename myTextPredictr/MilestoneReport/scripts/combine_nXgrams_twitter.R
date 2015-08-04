#---------------------------------------------------------------------------------------------------
# TWITTER
#---------------------------------------------------------------------------------------------------
nl.chunk <- 100000
N <- ceiling(length(sel.twitter.sentences)/nl.chunk)

#--- n1 ---#
size.n1g.twitter <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n1grams.twitter.", i, collapse = "")
    size.n1g.twitter[i] <- length(get(name))
    cat(" Number of 1-grams in set", i, " : ", size.n1g.twitter[i], "\n")
}

n1grams.twitter.all <- vector(mode = "character", length = sum(size.n1g.twitter))
ivec <- c(0, cumsum(size.n1g.twitter))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n1grams.twitter.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n1grams.twitter.all[n1:n2] <- get(name)
}

rm(list = ls(pattern = "^n1grams.twitter.[1-8]"))

#--- n2 ---#
size.n2g.twitter <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n2grams.twitter.", i, collapse = "")
    size.n2g.twitter[i] <- length(get(name))
    cat(" Number of 2-grams in set", i, " : ", size.n2g.twitter[i], "\n")
}

n2grams.twitter.all <- vector(mode = "character", length = sum(size.n2g.twitter))
ivec <- c(0, cumsum(size.n2g.twitter))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n2grams.twitter.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n2grams.twitter.all[n1:n2] <- get(name)
}

rm(list = ls(pattern = "^n2grams.twitter.[1-8]"))

#--- n3 ---#
size.n3g.twitter <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n3grams.twitter.", i, collapse = "")
    size.n3g.twitter[i] <- length(get(name))
    cat(" Number of 3-grams in set", i, " : ", size.n3g.twitter[i], "\n")
}

n3grams.twitter.all <- vector(mode = "character", length = sum(size.n3g.twitter))
ivec <- c(0, cumsum(size.n3g.twitter))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n3grams.twitter.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n3grams.twitter.all[n1:n2] <- get(name)
}

rm(list = ls(pattern = "^n3grams.twitter.[1-8]"))

#--- n4 ---#
size.n4g.twitter <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n4grams.twitter.", i, collapse = "")
    size.n4g.twitter[i] <- length(get(name))
    cat(" Number of 4-grams in set", i, " : ", size.n4g.twitter[i], "\n")
}

n4grams.twitter.all <- vector(mode = "character", length = sum(size.n4g.twitter))
ivec <- c(0, cumsum(size.n4g.twitter))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n4grams.twitter.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n4grams.twitter.all[n1:n2] <- get(name)
}

rm(list = ls(pattern = "^n4grams.twitter.[1-8]"))

#--- n5 ---#
size.n5g.twitter <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n5grams.twitter.", i, collapse = "")
    size.n5g.twitter[i] <- length(get(name))
    cat(" Number of 5-grams in set", i, " : ", size.n5g.twitter[i], "\n")
}

n5grams.twitter.all <- vector(mode = "character", length = sum(size.n5g.twitter))
ivec <- c(0, cumsum(size.n5g.twitter))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n5grams.twitter.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n5grams.twitter.all[n1:n2] <- get(name)
}

rm(list = ls(pattern = "^n5grams.twitter.[1-8]"))

#---------------------------------------------------------------------------------------------------
