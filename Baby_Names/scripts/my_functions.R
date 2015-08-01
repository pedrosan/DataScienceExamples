
# Baby_Names

## ---- my_functions

#===================================================================================================
# Nothing Yey

intersect_MF_names_1year <- function(data = NULL, 
                                     select_year = NULL) {

    tmp_f <- filter(data, year == select_year & gender == "F") %>% group_by(name) %>% summarize(n = sum(count)) 
    tmp_m <- filter(data, year == select_year & gender == "M") %>% group_by(name) %>% summarize(n = sum(count)) 

    tmp_c <- inner_join(tmp_f, tmp_m, by = "name") %>% mutate(ntot = n.x + n.y, 
                                                              diff = abs(n.x - n.y), 
                                                              diff_norm = round(abs(n.x - n.y)/ntot, 4), 
                                                              ratio = round(pmin(n.x/n.y, n.y/n.x), 4))
    colnames(tmp_c)[1:4] <- c("Name", "N_female", "N_male", "N_tot")
    return(list(female = tmp_f, male = tmp_m, common = tmp_c))
}

#===-----------------------------------------------------------
# 
get_coverage <- function(cnt = NULL, 
                         cutoff = NULL) {

    tot <- sum(cnt)
    cov <- cumsum(cnt)/tot*100

    Ncov <- sum(cov <= cutoff)
    Fcov <- Ncov/length(cnt)
    return( list(Ncov = Ncov, Fcov = Fcov) )

}

#===-----------------------------------------------------------
# from: https://github.com/cran/descr/blob/master/R/file.head.R
# 
file.head <- function(file, 
                      n = 6, 
                      truncate.cols = TRUE) {

    lns <- readLines(file, n = n)
    lns <- gsub("\t", "\\\\t", lns)
    if(truncate.cols){
        try(file.head.lns <- substr(lns, 1, getOption("width") - 1), silent = TRUE)
        if(!exists("file.head.lns")){
            Encoding(lns) <- "bytes"
            file.head.lns <- substr(lns, 1, getOption("width") - 1)
        }
    }
    cat(file.head.lns, sep = "\n")
}

#===-----------------------------------------------------------
#  - subset must be passed enclosed in 'quote()'
#
plot_hist_state_year_with_fit <- function(data = NULL, 
                                          STATE = NULL, 
                                          YEAR = NULL, 
                                          subset = NULL,
                                          return_fit = FALSE, 
                                          debug = FALSE) {

    # require("dplyr")   
    if( is.null(STATE) & !is.null(YEAR)) { data_for_histo <- subset(data, year %in% YEAR) }
    if(!is.null(STATE) &  is.null(YEAR)) { data_for_histo <- subset(data, state %in% STATE) }
    if(!is.null(STATE) & !is.null(YEAR)) { data_for_histo <- subset(data, state %in% STATE & year %in% YEAR) }
    
    # log_breaks <- seq(log10(5), log10(2*max(data_for_histo$count)), by = 0.25*log10(5))
    log_breaks <- seq(0, 4.1, by = 0.2*log10(5)) + log10(5)
    
    #---
    fit_df <- data_for_histo %>% mutate(log_c = log10(count)) %>% dplyr::select( . , gender, log_c)
    if( debug ) { print(nrow(fit_df)) }
    hh_F <- hist(subset(fit_df$log_c, fit_df$gender == "F"), breaks = log_breaks, plot = FALSE)
    hh_M <- hist(subset(fit_df$log_c, fit_df$gender == "M"), breaks = log_breaks, plot = FALSE)
    
    hh_F_df <- data.frame(x = hh_F$mids, y = log10(hh_F$counts), g = "F", stringsAsFactors = FALSE) 
    hh_M_df <- data.frame(x = hh_M$mids, y = log10(hh_M$counts), g = "M", stringsAsFactors = FALSE) 
    hh_df <- bind_rows(hh_F_df, hh_M_df) %>% filter( . , y != -Inf)
    hh_df$xy <- hh_df$y + hh_df$x
    
    #---
    # needed for understanding the passed subset expression
    x <- hh_df$x
    y <- hh_df$y
    #
    if( is.null(subset) ) {
        flag_subset <- rep(TRUE, nrow(hh_df)) 
    } else {
        flag_subset <- eval(subset)
    }
    #---

    mod <- lm(y ~ I(x-1)*g, data = hh_df, subset = flag_subset)
    cx <- summary(mod)$coeff
    ab <- cx[, 1]
    
    cx_at_1 <- c(ab[1], ab[2], ab[1]+ab[3], ab[2]+ab[4])
    names(cx_at_1) <- c("nF", "slopeF", "nM", "slopeM")
    
    ab_F <- c( ab[1] - ab[2], ab[2] )
    ab_M <- c( (ab[1]+ab[3]) - (ab[2]+ab[4]), ab[2]+ab[4])

    if( debug ) { print(cx[, -3]) }
    if( debug ) { print(cx_at_1) }
    if( debug ) { print(rbind(ab_F, ab_M)) }
    
    #---
    if( !is.null(STATE) ) {
        label_STATE <- deparse(substitute(STATE)) %>% gsub('"', '', .)
    } else {
        label_STATE <- ""
    }
    if( !is.null(YEAR) ) {
        label_YEAR  <- deparse(substitute(YEAR)) %>% gsub('"', '', .)
    } else {
        label_YEAR  <- ""
    }

    label_main <- paste0(label_STATE, " / ", label_YEAR)
    #---
    
    # single_panel_mar <- c(3, 4, 2, 1)
    # single_panel_oma <- c(0 ,0, 2, 0)
    # gr_par <- list( mar = single_panel_mar, oma = single_panel_oma, 
    #                 cex = 1.0, cex.axis = 1.0, cex.lab = 1.0, cex.main = 1.25,
    #                 las = 0, mgp = c(1.5, 0.5, 0),
    #                 tcl = 0.3)
    # par(gr_par)

    colors_FM <- c("pink2", "dodgerblue2")
    plot(hh_df$x, hh_df$y, 
         xlim = c(0, 4.1), 
         ylim = c(0, 4.5), 
         type = "n", 
         xlab = "log10(Counts)", 
         ylab = "log10(Frequency)",
         main = label_main)
    
    points(hh_df$x[hh_df$g == "F"], hh_df$y[hh_df$g == "F"], col = colors_FM[1], pch = 19, cex = 1.5)
    points(hh_df$x[hh_df$g == "M"], hh_df$y[hh_df$g == "M"], col = colors_FM[2], pch = 19, cex = 1.5)

    abline(ab_F, col = "red2", lty = 2)
    abline(ab_M, col = "blue2", lty = 2)
    grid()

    points(hh_df$x[!flag_subset], hh_df$y[!flag_subset], pch = 15, col = rgb(0,0,0,0.2), cex = 2.2)

    if( return_fit ) { return(cx_at_1) }

}

#===-----------------------------------------------------------
#
prepare_powerlaw_fits_data_frame <- function(data = NULL) {
    
    vec_states <- unique(data$state)
    # vec_states <- c("MA", "WY", "NM", "FL")
    
    vec_years <- unique(data$year) %>% sort( . , decreasing = FALSE)
    last_year <- 2013
    
    y_start_step <- 5
    start_years <- seq(1910, 2014, by = y_start_step)
    y_window <- 10
    
    store <- list()
    
    i <- 0
    for( S in vec_states ) {
        state_df <- filter(data, state == S)
        for( y1 in start_years ) {
            i <- i + 1
            # y2 <- min(y1 + y_start_step - 1, last_year)
            y2 <- min(y1 + y_window - 1, last_year)
            cat(" ", S, " : ", y1, " - ", y2, "\n")
            # name <- paste0(S, "_", y1, "_", y2)
            name <- paste0(S, y1)
            
            fname <- paste0("distr2_", S, "_", y1, "_", y2, ".png")
            png(file = fname, width = 900, height = 900, res = 96, bg = "white")
            cx <- plot_hist_state_year_with_fit(data = state_df, YEAR = y1:y2, subset = quote(y > log10(25)), return_fit = TRUE)
            # store[[i]] <- cx
            store[[name]] <- c(name, cx)
            
            dev.off()
        }
    }
    
    powerlaw_fits <- as.data.frame(t(as.data.frame(store, stringsAsFactors = FALSE)), stringsAsFactors = FALSE)
    colnames(powerlaw_fits)[1] <- "StateYear"
    
    powerlaw_fits[, 2:5] <- apply(powerlaw_fits[,2:5], 2, as.numeric)
    row.names(powerlaw_fits) <- NULL
    powerlaw_fits <- separate(powerlaw_fits, StateYear, c("State", "Time"), sep = 2)
    powerlaw_fits$Time <- as.integer(powerlaw_fits$Time) + 0.5*y_window
    
    return(powerlaw_fits)
    
}

#===================================================================================================

## ---- end-of-my_functions

