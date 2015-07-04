#---------------------------------------------------------------------------------------------------
# FUNCTIONS
#---------------------------------------------------------------------------------------------------
get_word_ID <- function( word ) {
    ID <- dict[dict$word == word, 1]
    # Return first ID value to avoid duplication (which should not actually be possible)
    # If not found return 0
    if( length(ID) > 0) {
        output <- ID[1] 
    } else {
        output <- 0 
    }
    return(output)
}

get_word_count <- function( word ) {
    ID <- dict[dict$word == word, 3]
    # Return first ID value to avoid duplication (which should not actually be possible)
    # If not found return 0
    if( length(ID) > 0) {
        output <- ID[1] 
    } else {
        output <- 0 
    }
    return(output)
}

get_word_str <- function(wordidx) {
    word <- values(h_wc2, keys = wordidx, USE.NAMES = FALSE)
    # if more than one word matches : to avoid duplication return first value 
    # if no matches : return empty string ""
    if( length(word) > 0) {
        word[1] 
    } else {
        "" 
    }
}

flag_best_matches <- function(data = NULL, order = NULL) {

    # tier1_bs2  <- c(7, 11, 13, 14, 15)   # nm >= 3
    # tier2_bs2  <- c(6, 10, 12)
    # tier3_bs2  <- c(5, 8, 9)
    # tier4_bs2  <- c(1, 2, 3, 4)          # these are pretty poor

    check_A <- rep(FALSE, nrow(data))
    check_B <- rep(FALSE, nrow(data))
    check_C <- rep(FALSE, nrow(data))
    best <- check_A

    check_A <- ( data$nm == order )
    n_A <- sum( check_A )
    if( order > 2 ) {
        check_B <- ( data$nm == order-1 )
        n_B <- sum( check_B )
    }
    if( order > 3 ) {
        check_C <- ( data$nm == order-2 )
        n_C <- sum( check_C )
    }

    check_AB  <- ( check_A | check_B )
    check_ABC <- ( check_A | check_B | check_C )
    n_AB  <- sum( check_AB )
    n_ABC <- sum( check_ABC )

    best <- check_ABC
    if( n_A >= 10 ) { 
        best <- check_A
    } else if ( n_AB >= 10 ) {
        best <- check_AB
    }

    return(best)

}

# get_word_str <- get_word_str_v3 

#---------------------------------------------------------------------------------------------------
select_ngrams_xnew <- function(ngrams = NULL, columns = NULL, words = NULL, counts = NULL, c_threshold = 1e7) {
    
    max_ncol <- ncol(ngrams) - 3
    if( length(columns) > max_ncol ) {
        columns <- 1:max_ncol
    }
    if( length(words) > max_ncol ) {
        words <- tail(words, max_ncol)
    }
    
    diff <- length(columns) - length(words) 
    if( diff > 0 ) {
        i_sub <- (diff + 1):length(columns)
        columns <- columns[i_sub]
    }
    if( diff < 0 ) {
        i_sub <- (abs(diff) + 1):length(words)
        words <- words[i_sub]
        counts <- counts[i_sub]
    }
    n_max <- length(columns)

    name <- paste0("temp_flag_", sprintf("%1d", 1:4))
    
    for(i in 1:4) {
        assign( name[i], rep(FALSE, nrow(ngrams)) )
    }
    
    for(i in 1:n_max) {
        if(counts[i] > 0 && counts[i] <= c_threshold) {
            assign( name[i],  as.logical( words[i] == ngrams[, columns[i]] ) )
        }
    }
    
    df_flags <- data.frame(as.logical(temp_flag_1), as.logical(temp_flag_2), 
                           as.logical(temp_flag_3), as.logical(temp_flag_4) )
    colnames(df_flags) <- paste0("flag", 1:4)
    
    selection <- ( temp_flag_1 | temp_flag_2 | temp_flag_3 | temp_flag_4 )
    # cat(" length(selection) = ", length(selection), "\n")
    # cat(" selected number   = ", sum(selection), "\n")
    # cat(nrow(ngrams), length(selection))
    df_sel_ngrams <- filter(ngrams, selection)
    df_sel_flags <- filter(df_flags, selection)

    # df_output <- data.frame(df_sel_ngrams, df_sel_flags)
    # return( df_output )
    
    return( list( matches = df_sel_ngrams, flags = df_sel_flags ) )

    # return( list( matches = df, flags = filter(df_flags, selection) ) )

}

#---------------------------------------------------------------------------------------------------
# predict_engine_v3 <- function(input_text = NULL, n3w = NULL, n4w = NULL, n5w = NULL, dict = NULL, hash_count = NULL, debug = FALSE) {
predict_engine_v5 <- function(input_text = NULL, n3w = NULL, n4w = NULL, n5w = NULL, debug = FALSE) {
    
    # return some default data frame.
    fake_wpred <- c("bazinga!", "you've", "got", "to be", "kidding")
    fake_metric1 <- c("3.1415", "92653", "58979", "32384", "62643")
    fake_metric2 <- c("2.7182", "81828", "45904", "52353", "60287")
    fall_back <- data.frame( prediction = fake_wpred, metric1 = fake_metric1, metric2 = fake_metric2)

    input_refmt <- system2("./scripts/regularize_for_R.pl", input = input_text, stdout = TRUE)
    
    words_all <- unlist(strsplit(input_refmt, split = "[ ;,.\"\t\r\n()!?:]+"))
    nwords <- min(5, length(words_all))
    
    #-----------------------------------------------------------
    # keeps only 5 words if there are more after regularization
    #-----------------------------------------------------------
    if( nwords >= 5 ) {
        # words_select <- words_all[(length(words_all)-4):length(words_all)]
        words_select <- tail(words_all, 4)
    } else {
        words_select <- words_all
    }
    
    #-----------------------------------------------------------
    # checks matches and counts on dictionary
    #-----------------------------------------------------------
    w_counts <- sapply(words_select, function(x) { get_word_count(x) }, USE.NAMES = FALSE )
    w_IDs    <- sapply(words_select, function(x) { get_word_ID(x) }, USE.NAMES = FALSE )

    check_counts <- sum(w_counts)
    if( check_counts == 0 ) { 
        # return some kind of DEFAULT answer.... HERE, skipping the rest
    }

    #-------------------
    bs_exp <- 0:3
    bs_w2 <- 2^bs_exp 
    #-------------------
    c_threshold <- 1e7

    threshold_n34 <- 10
    flag_n34 <- FALSE
    threshold_bs2 <- 20
    flag_bs2 <- FALSE
    #-------------------
    weight_ng5 <- 1.5
    weight_ng4 <- 1.0
    weight_ng3 <- 0.5
    #-------------------
    FLAG_DONE <- FALSE
    #-------------------

    n5s <- select_ngrams_xnew(ngrams = n5w, 
                              columns = 1:4, 
                              words = tail(w_IDs, 4), 
                              counts = tail(w_counts, 4), 
                              c_threshold = c_threshold) 

    n5text <- mutate(n5s$matches, 
                     logPdict_pred = -1*(log10(vec_counts[pred]/dict_size)), 
                     logPdict = as.numeric(logPdict),
                     orderW = weight_ng5)

    n5text$nm <- rowSums(n5s$flags)
    binscore5_w2 <- apply(n5s$flags, 1, function(x) { x %*% bs_w2 } )
    n5text$bs2 <- binscore5_w2

    test_n34 <- sum( n5text$nm  >=  3 )
    test_bs2 <- sum( n5text$bs2 >= 10 | n5text$bs2 == 7 | n5text$bs2 == 6 )

    if( test_n34 >= threshold_n34 ) {
        flag_n34 <- TRUE
        n5text <- filter(n5text, nm >= 3)
    } else if ( test_bs2 >= threshold_bs2 ) {
        flag_bs2 <- TRUE
        n5text <- filter(n5text, bs2 >= 10 | bs2 == 7 | bs2 == 6 )
    }
    
    n5text <- mutate(n5text, 
                     root = str_join(vec_words[w1], vec_words[w2], vec_words[w3], vec_words[w4], sep = " "), 
                     wpred = vec_words[pred])

    n5text <- mutate(n5text, 
                     ngImp = logPdict - logPng, 
                     predImp = logPdict_pred + log10(ngFreq/Nng), 
                     mixImp = ngImp + predImp)
    
    # N5_matches <- nrow(n5s$matches)
    # N5_matches <- nrow(n5text)
    # if( N5_matches > 0 ) { select5 <- flag_best_matches(data = n5text, order = 4) }
    # N5_select <- sum(select5)

    N5_select <- nrow(n5text)
    if( N5_select > 0 ) {
        
        filter5 <- ( n5text$logPdict > 12.5 & n5text$logPdict_pred > 2.0 ) 
        filter5 <- ifelse(n5text$bs2 >= 11, TRUE, filter5)
    
        n5pred <- filter(n5text, filter5) %>%
            select(wpred, pred, logPdict, logPdict_pred, bs2, mixImp, orderW) %>%
            arrange(desc(bs2), desc(logPdict)) 
        
        n5pred_aggr <- group_by(n5pred, wpred) %>% 
            summarise( sum_bs2 = sum(bs2), sum_logPdict = sum(logPdict)) %>% 
            arrange(desc(sum_bs2), desc(sum_logPdict))
        
    }

    N5_candidates <- nrow(n5pred_aggr)
    if( N5_candidates == 0 ) { FLAG_EMPTY_5 <- TRUE } else { FLAG_EMPTY_5 <- FALSE }

    if( N5_candidates >= 2 ) {
        
        FLAG_DONE <- TRUE

        candidates <- group_by(n5pred, wpred) %>% 
            summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
            arrange(desc(sum_bs2), desc(sum_logPdict))
        
    }

    #===============================================================================
    if( FLAG_DONE == FALSE ) {

        n4s <- select_ngrams_xnew(ngrams = n4w, 
                                  columns = 1:3, 
                                  words = tail(w_IDs, 3), 
                                  counts = tail(w_counts, 3), 
                                  c_threshold = c_threshold) 
        
        n4text <- mutate(n4s$matches, 
                         logPdict_pred = -1*(log10(vec_counts[pred]/dict_size)), 
                         logPdict = as.numeric(logPdict),
                         orderW = weight_ng4)
        
        n4text$nm <- rowSums(n4s$flags)
        binscore4_w2 <- apply(n4s$flags, 1, function(x) { x %*% c(bs_w2[2:4], 0) } )
        n4text$bs2 <- binscore4_w2
        
        if( flag_n34 ) {
            n4text <- filter(n4text, nm  >=  3)
        } else if ( flag_bs2 ) {
            n4text <- filter(n4text, bs2 >= 10)
        }
        
        n4text <- mutate(n4text, 
                         root = str_join(vec_words[w1], vec_words[w2], vec_words[w3], sep = " "), 
                         wpred = vec_words[pred])
        
        n4text <- mutate(n4text, 
                         ngImp = logPdict - logPng, 
                         predImp = logPdict_pred + log10(ngFreq/Nng), 
                         mixImp = ngImp + predImp)
        
        #N4_matches <- nrow(n4s$matches)
        #if( N4_matches > 0 ) { select4 <- flag_best_matches(data = n4text, order = 3) }
        #N4_select <- sum(select4)
        
        N4_select <- nrow(n4text)
        if( N4_select > 0 ) {
            
            # n4pred <- filter(n4text, logPdict > 8.0 & logPdict_pred > 2.0) %>% 
            filter4 <- ( n4text$logPdict > 8.0 & n4text$logPdict_pred > 2.0 ) 
            filter4 <- ifelse(n4text$bs2 >= 10, TRUE, filter5)
        
            n4pred <- filter(n4text, filter4) %>%
                select(wpred, pred, logPdict, logPdict_pred, bs2, mixImp, orderW) %>%
                arrange(desc(bs2), desc(logPdict)) 
            
            n4pred_aggr <- group_by(n4pred, wpred) %>% 
                summarise( sum_bs2 = sum(bs2), sum_logPdict = sum(logPdict)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))
            
        }
        
        N4_candidates <- nrow(n4pred_aggr)
        if( N4_candidates == 0 ) { FLAG_EMPTY_4 <- TRUE } else { FLAG_EMPTY_4 <- FALSE }
        
        if( N4_candidates >= 2 ) {
            
            FLAG_DONE <- TRUE
        
            candidates <- group_by(n4pred, wpred) %>% 
                summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))
        }
    }

    #===============================================================================
    if( FLAG_DONE == FALSE ) {
        if( FLAG_EMPTY_5 == FALSE & FLAG_EMPTY_4 == FALSE ) {
        
            candidates <- rbind(n5pred, n4pred) %>% group_by(wpred) %>% 
                summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))
            FLAG_DONE <- TRUE
        
        } else if( FLAG_EMPTY_5 == FALSE & FLAG_EMPTY_4 == TRUE ) {
        
            candidates <- group_by(n5pred, wpred) %>% 
                summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))
            FLAG_DONE <- TRUE
            
        } else if( FLAG_EMPTY_5 == TRUE & FLAG_EMPTY_4 == FALSE ) {
        
            candidates <- group_by(n4pred, wpred) %>% 
                summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))
            FLAG_DONE <- TRUE
            
        }
    }

    #===============================================================================
    if( FLAG_DONE == FALSE ) {

        n3s <- select_ngrams_xnew(ngrams = n3w, 
                                  columns = 1:2, 
                                  words = tail(w_IDs, 2), 
                                  counts = tail(w_counts, 2), 
                                  c_threshold = c_threshold) 
        
        n3text <- mutate(n3s$matches, 
                         logPdict_pred = -1*(log10(vec_counts[pred]/dict_size)), 
                         logPdict = as.numeric(logPdict),
                         orderW = weight_ng3)

        n3text$nm <- rowSums(n3s$flags)
        binscore3_w2 <- apply(n3s$flags, 1, function(x) { x %*% c(bs_w2[3:4], 0, 0) } )
        n3text$bs2 <- binscore3_w2
        
        n3text <- mutate(n3text, 
                         root = str_join(vec_words[w1], vec_words[w2], sep = " "), 
                         wpred = vec_words[pred])
        
        n3text <- mutate(n3text, 
                         ngImp = logPdict - logPng, 
                         predImp = logPdict_pred + log10(ngFreq/Nng), 
                         mixImp = ngImp + predImp)
    
        # N3_matches <- nrow(n3s$matches)
        N3_matches <- nrow(n3text)
        if( N3_matches > 0 ) { select3 <- flag_best_matches(data = n3text, order = 2) }

        N3_select <- sum(select3)
        if( N3_select > 0 ) {
            
            n3pred <- n3text[select3, ] %>% 
                filter(logPdict > 6.0 & logPdict_pred > 2.0) %>% 
                select(pred, logPdict, logPdict_pred, bs2, mixImp, orderW) %>%
                arrange(desc(bs2), desc(logPdict)) 
            
            n3pred_aggr <- group_by(n3pred, pred) %>% 
                summarise( sum_bs2 = sum(bs2), sum_logPdict = sum(logPdict)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))

        }
        N3_candidates <- nrow(n3pred_aggr)
        
        if( N3_candidates > 0 ) {
            candidates <- group_by(n3pred, wpred) %>% 
                summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
                arrange(desc(sum_bs2), desc(sum_logPdict))
            FLAG_DONE <- TRUE
            
        }
            
    }
    
    #===============================================================================
    if( FLAG_DONE == FALSE ) {
        candidates <- fall_back
    }

    #---------------------------------------------------------------------------------------------------
    
    top10 <- head(candidates[, c(1, 2, 3)], 5)
    colnames(top10) <- c("prediction", "metric1", "metric2")

    best <- top10$pred[1]
    
    # return(best)
    # if( debug ) { head(top10, 10) } 

    return(top10)

    # return(top10[, c("pred", "metric")])
    # return(list(top10 = top10[, c("pred", "metric")], n3sum = n3_summary, n4sum = n4_summary, n5sum = n5_summary))
    
}

#---------------------------------------------------------------------------------------------------
predict_engine2 <- function(input_text = NULL) {

    best <- paste0("bazinga!", " ", input_text)
    return(best)
    #return(top10[, c("pred", "metric")])
    # output$value <- renderPrint({ input$text })

}

#---------------------------------------------------------------------------------------------------
SAVE_select_ngrams_xnew <- function(in_ngrams = NULL, words = NULL, w_counts = NULL, wc_threshold = NULL) {
    name <- paste("temp_flag_", sprintf("%1d", 1:5), sep = "")
    # cat(" N_rows n-grams input = ", nrow(in_ngrams), "\n")
    for(i in 1:5) {
        # name <- paste("temp_flag_", sprintf("%1d", 1:5), sep = "")
        assign( name[i], rep(FALSE, nrow(in_ngrams)) )
    }
    for(i in (6-length(words)):5) {
        j <- i - (5 - length(words))
        k <- (ncol(in_ngrams)-2) - length(words) + j
        if(w_counts[j] > 0 && w_counts[j] <= wc_threshold) {
            assign( name[i],  as.numeric(words[j] == in_ngrams[, k]) )
        }
    }
    selection <- ( temp_flag_1 | temp_flag_2 | temp_flag_3 | temp_flag_4 | temp_flag_5 )
    df <- cbind(in_ngrams, as.numeric(temp_flag_1), as.numeric(temp_flag_2), as.numeric(temp_flag_3), 
                as.numeric(temp_flag_4), as.numeric(temp_flag_5) )
    nc <- ncol(in_ngrams)
    colnames(df)[(nc+1):(nc+5)] <- paste0("flag", 1:5)
      return( filter(df, selection) )
    # return( filter(in_ngrams, selection) )
}

#---------------------------------------------------------------------------------------------------
