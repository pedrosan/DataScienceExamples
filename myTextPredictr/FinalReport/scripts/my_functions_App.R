####################################################################################################
# Main function
#---------------------------------------------------------------------------------------------------
predict_engine <- function(input_text = NULL, n3w = NULL, n4w = NULL, n5w = NULL, dict = NULL, vec_words, vec_counts, how_many = 5, debug = FALSE) {
    
    dict_size <- sum(dict$count)

    OutputColumns <- c(1, 2)

    # return some default data frame.
    fake1_wpred <- c("BAZINGA!", "", "You've", "kidding me", "")
    fake1_metric1 <- c("3.141592653", "", "Got to be", "with this!", "")
    fake1_metric2 <- c("2.718281828", "", "", "", "")

    fake2_wpred <- c("BAZINGA!", "Sorry...", "I Could", "find")
    fake2_metric1 <- c("3.141592653", "", "Not", "a match")
    fake2_metric2 <- c("2.718281828", "", "", "")

    fake3_wpred <- c("BAZINGA!", "", "EMPTY", "Please")
    fake3_metric1 <- c("3.141592653", "", "INPUT", "Try Again")
    fake3_metric2 <- c("2.718281828", "", "", "")

    fall_back1 <- data.frame( prediction = fake1_wpred, metric1 = fake1_metric1, metric2 = fake1_metric2, stringsAsFactors = FALSE)
    fall_back2 <- data.frame( prediction = fake2_wpred, metric1 = fake2_metric1, metric2 = fake2_metric2, stringsAsFactors = FALSE)
    fall_back3 <- data.frame( prediction = fake3_wpred, metric1 = fake3_metric1, metric2 = fake3_metric2, stringsAsFactors = FALSE)

    debug_df_col1 <- c("PROBLEM", " ", " ", " ", " ")
    debug_df_col2 <- c("CAUGHT", " ", " ", " ", " ")
    debug_df_col3 <- c(" ", " ", " ", " ", " ")
    debug_df <- data.frame( prediction = debug_df_col1, metric1 = debug_df_col2, metric2 = debug_df_col3, stringsAsFactors = FALSE)

    #-----------------------------------------------------------
    # input_refmt1 <- system2("./scripts/regularize_for_R_new.pl", input = input_text, stdout = TRUE)
    # input_refmt2 <- system2("./scripts/regularize_for_R_new.pl", input = shQuote(input_text), stdout = TRUE)
    # input_refmt3 <- text_string_refmt(input_text)
    input_refmt <- text_string_refmt(input_text)
    # input_refmt <- input_text;
    
    input_length <- 0.0
    input_length <- nchar(input_refmt)

    if( is.null(input_length) ) {
        candidates <- debug_df
        candidates[2, 1] <- "input_length"; candidates[2, 2] <- "NULL"
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

    if( is.na(input_length) ) {
        candidates <- debug_df
        candidates[2, 1] <- "input_length"; candidates[2, 2] <- "NA"
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

    if( input_length == 0 ) { 
        candidates <- debug_df
        candidates[2, 1] <- "input_length"; candidates[2, 2] <- 0
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

    #-----------------------------------------------------------
    words_all <- unlist(strsplit(input_refmt, split = "[ ;,.\"\t\r\n()!?:]+"))
    nwords <- min(5, length(words_all))
    
    if( is.null(nwords) ) {
        candidates <- debug_df
        candidates[2, 1] <- "nwords"; candidates[2, 2] <- "NULL"
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

    if( is.na(nwords) ) {
        candidates <- debug_df
        candidates[2, 1] <- "nwords"; candidates[2, 2] <- "NA"
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

    if( nwords == 0 ) {
        candidates <- debug_df
        candidates[2, 1] <- "nwords"; candidates[2, 2] <- 0
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

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
    check_counts <- 0.0
    w_counts <- sapply(words_select, function(x) { get_word_count(dict, x) }, USE.NAMES = FALSE )
    w_IDs    <- sapply(words_select, function(x) { get_word_ID(dict, x) }, USE.NAMES = FALSE )

    check_counts <- sum(w_counts)

    if( is.null(check_counts) ) {
        candidates <- debug_df
        candidates[2, 1] <- "check_counts"; candidates[2, 2] <- "NULL"
        candidates[3, 1] <- "nwords"      ; candidates[3, 2] <- nwords
        candidates[ , 3] <- w_IDs[1:5]
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }
    if( is.na(check_counts) ) {
        candidates <- debug_df
        candidates[2, 1] <- "check_counts"; candidates[2, 2] <- "NA"
        candidates[3, 1] <- "nwords"      ; candidates[3, 2] <- nwords
        candidates[ , 3] <- w_IDs[1:5]
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
    }

    if( check_counts == 0 ) { 
        candidates <- fall_back1
        top10 <- head(candidates[, OutputColumns], how_many)
        return(top10)
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
    N5_candidates <- 0.0
    N4_candidates <- 0.0
    N3_candidates <- 0.0
    FLAG_EMPTY_5 <- TRUE 
    FLAG_EMPTY_4 <- TRUE 
    FLAG_EMPTY_3 <- TRUE 
    FLAG_DONE <- FALSE
    #-------------------

     # candidates <- debug_df
     # candidates[2, 1] <- "N5_candidates"; candidates[2, 2] <- N5_candidates
     # candidates[3, 1] <- "N4_candidates"; candidates[3, 2] <- N4_candidates
     # candidates[4, 1] <- "N3_candidates"; candidates[4, 2] <- N3_candidates
     # candidates[5, 1] <- "FLAG_DONE";     candidates[5, 2] <- FLAG_DONE
     # candidates[6, 1] <- "input_length";  candidates[6, 2] <- input_length
     # candidates[7, 1] <- "check_counts";  candidates[7, 2] <- check_counts
     # candidates[8, 1] <- "nwords"      ;  candidates[8, 2] <- nwords
     # candidates[1:3 , 3] <- c(FLAG_EMPTY_5, FLAG_EMPTY_4, FLAG_EMPTY_3)
     # top10 <- head(candidates[, OutputColumns], how_many)
     # return(top10)

    n5s <- select_ngrams_xnew(ngrams = n5w, 
                              columns = 1:4, 
                              words = tail(w_IDs, 4), 
                              counts = tail(w_counts, 4), 
                              c_threshold = c_threshold) 

    N5_candidates <- nrow(n5s$matches)
    if( N5_candidates > 0 ) { 

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
        } else if( test_bs2 >= threshold_bs2 ) {
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
            
            N5_candidates <- nrow(n5pred_aggr)
        }
    }

    if( N5_candidates > 0 ) { 
        FLAG_EMPTY_5 <- FALSE 
    }

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
        } else if( flag_bs2 ) {
            n4text <- filter(n4text, bs2 >= 10)
        }
        
        n4text <- mutate(n4text, 
                         root = str_join(vec_words[w1], vec_words[w2], vec_words[w3], sep = " "), 
                         wpred = vec_words[pred])
        
        n4text <- mutate(n4text, 
                         ngImp = logPdict - logPng, 
                         predImp = logPdict_pred + log10(ngFreq/Nng), 
                         mixImp = ngImp + predImp)
        
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

            N4_candidates <- nrow(n4pred_aggr)
        }
        
        if( N4_candidates > 0 ) { 
            FLAG_EMPTY_4 <- FALSE 
        }

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
        
        if( nrow(n3s$matches) > 0 ) { 
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
            
                N3_candidates <- nrow(n3pred_aggr)
            }
            
            if( N3_candidates > 0 ) {
                candidates <- group_by(n3pred, wpred) %>% 
                    summarise( sum_bs2 = sum(bs2*orderW), sum_logPdict = sum(logPdict), sum_mixImp = sum(mixImp*orderW)) %>% 
                    arrange(desc(sum_bs2), desc(sum_logPdict))
                FLAG_DONE <- TRUE
            }
        }
            
    }
    
    #===============================================================================
    if( FLAG_DONE == FALSE ) {
        candidates <- fall_back2
    }

    #---------------------------------------------------------------------------------------------------
    
    colnames(candidates) <- c("prediction", "score", "score_alt") 
    candidates$prediction <- sapply(candidates$prediction, function(x) {reverse_refmt(input = x)}, USE.NAMES = FALSE)

    top10 <- head(candidates[, OutputColumns], how_many)

    # top10 <- mutate(top10, prediction = reverse_refmt(prediction))
    # top10$prediction <- sapply(top10$prediction, function(x) {reverse_refmt(input = x)}, USE.NAMES = FALSE)

    return(top10)

}

####################################################################################################
# FUNCTIONS
#---------------------------------------------------------------------------------------------------
get_word_ID <- function( dict, word ) {
    ID <- dict[dict$word == word, 1]
    # Return first ID value to avoid duplication (which should not actually be possible)
    # If not found return 0
    if( length(ID) > 0 ) {
        output <- ID[1] 
    } else {
        output <- 0 
    }
    return(output)
}

get_word_count <- function( dict, word ) {
    ID <- dict[dict$word == word, 3]
    # Return first ID value to avoid duplication (which should not actually be possible)
    # If not found return 0
    if( length(ID) > 0 ) {
        output <- ID[1] 
    } else {
        output <- 0 
    }
    return(output)
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
    } else if( n_AB >= 10 ) {
        best <- check_AB
    }

    return(best)

}

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
    df_sel_ngrams <- filter(ngrams, selection)
    df_sel_flags <- filter(df_flags, selection)

    # df_output <- data.frame(df_sel_ngrams, df_sel_flags)
    # return( df_output )
    
    return( list( matches = df_sel_ngrams, flags = df_sel_flags ) )

}

#---------------------------------------------------------------------------------------------------
text_string_refmt <- function(input = NULL) {

    if( nchar(input) == 0 ) { 
        return(input) 
    } else {
        tmp <- input
    }

    # tmp <- gsub('([[:space:]\(\!\".?\-\/])#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b', "\\1 <HASHTAG> ", tmp, perl = TRUE);
    tmp <- gsub('([[:space:]])#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\\b', "\\1 <HASHTAG> ", tmp, perl = TRUE);
    tmp <- gsub('^#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\\b', "<HASHTAG> ", tmp, perl = TRUE)

    #---------------------------------------
    # 'll ==> _will / " will" ==> _will
    #----------------
    tmp <- gsub("([^[:alnum:]])-+([^[:alnum:]])", "\\1 \\2", tmp, perl = TRUE)

    tmp <- gsub("\\b(I|you|he|it|she|we|they|who|there)'ll\\b", "\\1_will", tmp, perl = TRUE)
    tmp <- gsub("\\b(I|you|he|it|she|we|they|who|there) +will\\b", "\\1_will",  tmp, perl = TRUE)

    #---------------------------------------
    # n't ==> _not
    #----------------
    tmp <- gsub("\\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need)n\'t\\b", "\\1_not", tmp, perl = TRUE)
    tmp <- gsub("\\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need) +not\\b", "\\1_not", tmp, perl = TRUE)

    tmp <- gsub("\\b(they|you|we)'re\\b", "\\1_are", tmp, perl = TRUE)
    tmp <- gsub("\\b(they|you|we) +are\\b", "\\1_are", tmp, perl = TRUE)

    #---------------------------------------
    # 've ==> _have
    #----------------
    tmp <- gsub("\\b(I|you|we|they|would|should|could|must|might)'ve\\b", "\\1_have", tmp, perl = TRUE)
    tmp <- gsub("\\b(I|you|we|they|would|should|could|must|might) +have\\b", "\\1_have", tmp, perl = TRUE)

    #---------------------------------------
    # ad hoc
    #----------------
    tmp <- gsub("\\b(can)'t\\b", "can_not", tmp, perl = TRUE)
    tmp <- gsub("\\b(can) +not\\b", "can_not", tmp, perl = TRUE)

    tmp <- gsub("\\b(won)'t\\b", "will_not", tmp, perl = TRUE)
    tmp <- gsub("\\b(will) +not\\b", "will_not", tmp, perl = TRUE)

    tmp <- gsub("\\b(ain)'t\\b", "is_not", tmp, perl = TRUE)

    tmp <- gsub("\\b(shan)'t\\b", "shall_not", tmp, perl = TRUE)
    tmp <- gsub("\\b(shall) +not\\b", "shall_not", tmp, perl = TRUE)

    tmp <- gsub("\\b(I)'m\\b", "I_am", tmp, perl = TRUE)
    tmp <- gsub("\\b(I) am\\b", "I_am", tmp, perl = TRUE)
    tmp <- gsub("\\bam I\\b", "am_I", tmp, perl = TRUE)

    tmp <- gsub("\\b(it)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(he)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(she)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(that)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(there)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(what)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(let)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(here)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(who)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(how)'s", "\\1_s", tmp, perl = TRUE)
    tmp <- gsub("\\b(where)'s", "\\1_s", tmp, perl = TRUE)

    tmp <- gsub("\\b(it) +is", "\\1_is", tmp, perl = TRUE)
    tmp <- gsub("\\b(he) +is", "\\1_is", tmp, perl = TRUE)
    tmp <- gsub("\\b(she) +is", "\\1_is", tmp, perl = TRUE)
    tmp <- gsub("\\b(that) +is", "\\1_is", tmp, perl = TRUE)
    tmp <- gsub("\\b(there) +is", "\\1_is", tmp, perl = TRUE)

    tmp <- gsub("\\b((shit|piss|fuck|cunt|cocksuck|motherfuck|tits)[[:alpha:]]{0,12})\\b", "<PROFANITY>", tmp, perl = TRUE)
    tmp <- gsub("\\b([[:alnum:]]+)'s\\b", "\\1", tmp, perl = TRUE)
    tmp <- gsub("\\b(a|an|as|at|no|of|on|or|by|so|up|or|no|in|to|rt)\\b", "", tmp, perl = TRUE)

    tmp <- gsub(' +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +', ' ', tmp, perl = TRUE)
    tmp <- gsub(' +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]])', '\\2', tmp, perl = TRUE)
    tmp <- gsub(' +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>', ' ', tmp, perl = TRUE)
    tmp <- gsub('^<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +', '', tmp, perl = TRUE)
    tmp <- gsub('<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +', ' ', tmp, perl = TRUE)

    tmp <- gsub("[,;:]", " ", tmp, perl = TRUE)

    tmp <- gsub(" +", " ", tmp, perl = TRUE)
    tmp <- gsub("^ +", "", tmp, perl = TRUE)
    tmp <- gsub(" +$", "", tmp, perl = TRUE)

    refmt <- tmp
    return(refmt)
}
#---------------------------------------------------------------------------------------------------
reverse_refmt <- function(input = NULL) {

    if( nchar(input) == 0 ) { 
        return(input) 
    } else {
        tmp <- input
    }
    # rev_refmt <- system2("./scripts/reverse_refmt.pl", input = input, stdout = TRUE) 

    tmp <- gsub("\\b(i|you|he|it|she|we|they|who|there)_will\\b", "\\1 will", tmp, perl = TRUE)

    tmp <- gsub("\\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need)_not\\b", "\\1 not", tmp, perl = TRUE)
    tmp <- gsub("\\bdon_t\\b", "don't", tmp, perl = TRUE)

    tmp <- gsub("\\b(they|you|we)_are\\b", "\\1 are", tmp, perl = TRUE)

    tmp <- gsub("\\b(i|you|we|they|would|should|could|must|might)_have\\b", "\\1 have", tmp, perl = TRUE)

    tmp <- gsub("\\b(can|will|is|shall)_not\\b", "\\1 not", tmp, perl = TRUE)
    tmp <- gsub("\\bi_am\\b", "I am", tmp, perl = TRUE)
    tmp <- gsub("\\bam_i\\b", "am I", tmp, perl = TRUE)

    tmp <- gsub("\\b(it|he|she|that|there|what|let|here|who|how|where)_s\\b", "\\1's", tmp, perl = TRUE)

    tmp <- gsub("\\b(it|he|she|that|there)_is\\b", "\\1 is", tmp, perl = TRUE)

    tmp <- gsub("\\bo_clock\\b", "o'clock", tmp, perl = TRUE)

    rev_refmt <- tmp

    return(rev_refmt)
}
#---------------------------------------------------------------------------------------------------
