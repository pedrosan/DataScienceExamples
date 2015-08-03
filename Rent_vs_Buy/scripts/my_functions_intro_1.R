
## ---- my_functions_intro_1

#=-------------------------------------------------------------------------------

cumprod.matrix.old <- function(x) {
    nrows <- dim(x)[1] 
    ncols <- dim(x)[2]
    y <- matrix(1, nrow = nrows, ncol = ncols)
    y[1, ] <- x[1, ]
    for (i in 2:nrows) {
        y[i, ] <- y[i-1, ]*x[i, ]
    }
    return(y)
}

cumprod.matrix <- function(x) {
    nrows <- dim(x)[1] 
    ncols <- dim(x)[2]
    y <- matrix(1, nrow = nrows, ncol = ncols)
    y[1, ] <- x[1, ]
    for (i in 1:ncols) {
        y[, i] <- cumprod(x[, i])
    }
    return(y)
}

cumdiv.matrix <- function(x) {
    nrows <- dim(x)[1] 
    ncols <- dim(x)[2]
    y <- matrix(1, nrow = nrows, ncol = ncols)
    y[1, ] <- x[1, ]
    for (i in 2:nrows) {
        y[i, ] <- x[i, ] / x[i-1, ]
    }
    return(y)
}

cumsum.matrix <- function(x) {
    nrows <- dim(x)[1] 
    ncols <- dim(x)[2]
    y <- matrix(1, nrow = nrows, ncol = ncols)
    y[1, ] <- x[1, ]
    for (i in 1:ncols) {
        y[, i] <- cumsum(x[, i])
    }
    #for (i in 2:nrows) {
    #    y[i, ] <- x[i, ] + x[i-1, ]
    #}
    return(y)
}

cumsub.matrix <- function(x) {
    nrows <- dim(x)[1] 
    ncols <- dim(x)[2]
    y <- matrix(1, nrow = nrows, ncol = ncols)
    y[1, ] <- x[1, ]
    for (i in 2:nrows) {
        y[i, ] <- x[i, ] - x[i-1, ]
    }
    return(y)
}

#=-------------------------------------------------------------------------------

getParams1 <- function(input, pnames) {
    # input[["run_simul"]]

    params <- lapply(pnames, function(p) { input[[p]] })
    names(params) <- pnames
    params
}

#=------------------------------------------------------------------------------

## ---- end-of-my_functions_intro_1


