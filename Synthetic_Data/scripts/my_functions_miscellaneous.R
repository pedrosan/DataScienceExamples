
## ---- my_functions_misc

#===================================================================================================
# DATA PROCESSING
#=--------------------------------------------------------------------------------------------------

#===================================================================================================
# Tables
#=--------------------------------------------------------------------------------------------------

kable_a_table <- function(data = NULL, caption = NULL) { 
    tt <- table(data)
    ttn <- names(tt)
    tt_df <- as.data.frame(matrix(tt, nrow = 1))
    colnames(tt_df) <- ttn
    if( is.null(caption) ) {
        kable(tt_df)
    } else {
        kable(tt_df, caption = caption)
    }
}

kable_a_table_wrapped <- function(data = NULL, width = 16) { 

    # prepare data frame from table
    tt <- table(data)
    ttn <- names(tt)
    tt_df <- as.data.frame(matrix(tt, nrow = 1))
    colnames(tt_df) <- ttn

    nw <- width
    ncol <- ncol(tt_df)
    nl <- ceiling(ncol / nw)

    i_last <- 0
    il <- 1
    tt_list <- list()
    for( k in 1:nl ) {
        i1 <- i_last + 1
        i2 <- min(i_last + nw, ncol)
        tt_list[[il]] <- tt_df[i1:i2]
        i_last <- i2
        il <- il + 1
    }
    return(tt_list)
}

#===================================================================================================

## ---- end-of-my_functions_misc
