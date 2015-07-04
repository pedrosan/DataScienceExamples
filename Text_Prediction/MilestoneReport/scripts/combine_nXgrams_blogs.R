#---------------------------------------------------------------------------------------------------
# BLOGS
#---------------------------------------------------------------------------------------------------
nl.chunk <- 100000
N <- ceiling(length(sel.blogs.sentences)/nl.chunk)

#--- n1 ---#
size.n1g.blogs <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n1grams.blogs.", i, collapse = "")
    size.n1g.blogs[i] <- length(get(name))
    cat(" Number of 1-grams in set", i, " : ", size.n1g.blogs[i], "\n")
}

n1grams.blogs.all <- vector(mode = "character", length = sum(size.n1g.blogs))
ivec <- c(0, cumsum(size.n1g.blogs))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n1grams.blogs.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n1grams.blogs.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n1grams.blogs.[1-5]"))

#--- n2 ---#
size.n2g.blogs <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n2grams.blogs.", i, collapse = "")
    size.n2g.blogs[i] <- length(get(name))
    cat(" Number of 2-grams in set", i, " : ", size.n2g.blogs[i], "\n")
}

n2grams.blogs.all <- vector(mode = "character", length = sum(size.n2g.blogs))
ivec <- c(0, cumsum(size.n2g.blogs))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n2grams.blogs.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n2grams.blogs.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n2grams.blogs.[1-5]"))

#--- n3 ---#
size.n3g.blogs <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n3grams.blogs.", i, collapse = "")
    size.n3g.blogs[i] <- length(get(name))
    cat(" Number of 3-grams in set", i, " : ", size.n3g.blogs[i], "\n")
}

n3grams.blogs.all <- vector(mode = "character", length = sum(size.n3g.blogs))
ivec <- c(0, cumsum(size.n3g.blogs))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n3grams.blogs.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n3grams.blogs.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n3grams.blogs.[1-5]"))

#--- n4 ---#
size.n4g.blogs <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n4grams.blogs.", i, collapse = "")
    size.n4g.blogs[i] <- length(get(name))
    cat(" Number of 4-grams in set", i, " : ", size.n4g.blogs[i], "\n")
}

n4grams.blogs.all <- vector(mode = "character", length = sum(size.n4g.blogs))
ivec <- c(0, cumsum(size.n4g.blogs))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n4grams.blogs.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n4grams.blogs.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n4grams.blogs.[1-5]"))

#--- n5 ---#
size.n5g.blogs <- rep(0, N)

for( i in 1:N ) {
    name <- paste0("n5grams.blogs.", i, collapse = "")
    size.n5g.blogs[i] <- length(get(name))
    cat(" Number of 5-grams in set", i, " : ", size.n5g.blogs[i], "\n")
}

n5grams.blogs.all <- vector(mode = "character", length = sum(size.n5g.blogs))
ivec <- c(0, cumsum(size.n5g.blogs))
for( i in 1:N ) {
    n1 <- ivec[i] + 1
    n2 <- ivec[i+1]
    name <- paste0("n5grams.blogs.", i, collapse = "")
    cat(" ", i, n1, n2, name, "\n")
    n5grams.blogs.all[n1:n2] <- get(name)
}

rm(list=ls(pattern = "^n5grams.blogs.[1-5]"))

#---------------------------------------------------------------------------------------------------
