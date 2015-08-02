
## ---- my_functions_modeling

#===================================================================================================
# MODELING 
#=--------------------------------------------------------------------------------------------------

#=----------------------------------------------------------
# Returns a list of predictors in the model: (model is an 'earth' object)
get_used_pred_names <- function(model = NULL) {
    any1 <- function(x) any(x != 0)
    # like any but no warning if x is double
    names(which(apply(model$dirs[model$selected.terms, , drop = FALSE], 2, any1)))
}


#=----------------------------------------------------------
# given observed and predicted outcomes computes MSE and R^2
#
compute_metrics <- function(data = NULL, 
                            prediction = NULL) { 
    
    MSE <- sum((prediction - data)**2)/length(data)
    R2  <- 1 - sum((data - prediction)**2)/sum((data - mean(data))**2)
    return(list( MSE = MSE, R2 = R2))
}

#===================================================================================================
# IMPUTATION
#=--------------------------------------------------------------------------------------------------

#=----------------------------------------------------------
# Inputs: 
#  - full data frame 
#  - correlation matrix, 
#  - index of variable for imputation
#  - threshold applied to correlation strengths
# Returns:
#  - imputed column for variable (full, not just imputed values)
#
# [1] it looks for variables with correlation with 'i' above the set threshold.
# [2] checks if any observation for 'i' + selected variables has just NAs.
#     If there are, it drops the least correlated variable and checks if the problem is solved,
#     trying until it's left with just 'i' and one of the correlated variables.
# [3] a) If after cleaning at least one correlated variable is left, it imputes the missing values
#        of 'i' by means of linear regression model with the correlated variables as predictors.
#        Since among a handful of variables the worst case scenario for the distribution of NAs
#        would cause the loss of only a few percent of the observations, the fact that 'lm' 
#        only keeps complete cases is not likely to have a significant impact.
#     b) If not enough data are left, it calls 'impute_with_random_sampling()', that
#        imputes the missing data by sampling the observed ones.
# [4] In some cases NAs are still left: final call to 'impute_with_random_sampling()' to impute them.
#
impute_with_lm <- function(data = NULL, 
                           corr_matrix = NULL, 
                           i = NULL, 
                           threshold = NULL, 
                           verbose = FALSE) {

    yname <- colnames(data)[i]

    # [1]
    corr <- abs(corr_matrix[yname, ])
    vnames <- names(head(sort(corr[corr > threshold], decreasing = TRUE), 3))
    if( verbose ) { cat(" i = ", i, " : yname= ", yname, "\n") }
    if( verbose ) { cat(" i = ", i, " : vnames = ", vnames, "\n") }

    # combined temp data frame
    tmp <- data[, c(yname, vnames)]
    colnames(tmp)[1] <- "y"

    if( verbose ) { print(str(tmp)) }
    if( verbose ) { sapply(tmp, function(x) sum(is.na(x))) }

    # [2]
    check <- sum(apply(tmp, 1, function(x) sum(is.na(x)) == ncol(tmp)))
    while( check > 0 & ncol(tmp) > 2) {
        tmp[, ncol(tmp)] <- NULL
        check <- sum(apply(tmp, 1, function(x) sum(is.na(x)) == ncol(tmp)))
    }

    # [3]
    if( check == 0 ) {
        # [3a] 
        if( verbose ) { cat(" can use lm fit\n") }
        flag_cc <- complete.cases(tmp[, -1])
        fit <- lm(y ~ ., data = tmp[flag_cc, ])
        if( verbose ) { print(summary(fit)) }
        pred <- predict(fit, tmp[flag_cc, -1, drop = FALSE])
        data[flag_cc, i] <- ifelse( is.na(data[flag_cc, i]), pred, data[flag_cc, i] )
    } else {
        # [3b] 
        if( verbose ) { cat(" will use dummy imputation\n") }
        data[, i] <- impute_with_random_sampling(data = data[, i])
    }
    
    # [4]
    if(sum(is.na(data[, i])) > 0) {
        if( verbose ) { cat(" needs one more final pass of dummy imputation\n") }
        data[, i] <- impute_with_random_sampling(data = data[, i])
    }
    return(data[, i])

}

#=----------------------------------------------------------
# Imputes missing data by random sampling from the existing ones.
# Given that the fraction of missing data is at most a few percent,
# assuming that they are randomly distributed, imputing them in
# this "ignorant" way is probably a safe back-up option.
# 
# Inputs: 
#  - a vector (or data frame columns)
# Returns:
#  - imputed column for variable (full, not just imputed values)
# 
impute_with_random_sampling <- function(data = NULL) {

    flag_missing <- is.na(data)
    N_missing <- sum(flag_missing)
    data_obs <- data[!flag_missing]
    data_imputed <- data
    data_imputed[flag_missing] <- sample (data_obs, N_missing, replace = TRUE)

    return(data_imputed)
}

#===================================================================================================

## ---- end-of-my_functions_modeling

