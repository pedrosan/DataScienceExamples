
## ---- my_functions_plot

#===================================================================================================
# PLOTTING PREDICTIONS
#=--------------------------------------------------------------------------------------------------

#=----------------------------------------------------------
# plots the difference between the distributions (histograms) 
# of observed and predicted outcomes, as an histogram.
#
plot_hist_difference <- function(data1 = NULL, 
                                 data2 = NULL, 
                                 color = "red2") {

    h_breaks <- seq(-30, 30, by = 1)
    h_1 <- hist(data1, breaks = h_breaks, plot = FALSE)
    h_2 <- hist(data2, breaks = h_breaks, plot = FALSE)
    h_diff <- h_1$density - h_2$density
    plot(h_1$mids, h_diff, type = "h", 
         xlim = c(-28, 28), 
         ylim = c(-0.04, 0.03), 
         col = color,
         lwd = 10, 
         lend = 3,
         xlab = "target",
         ylab = "(Data - Prediction)",
         main = "Difference b/w Observed and Predicted\nDistributions of 'target'")
    grid()
    abline(h = 0, lty = 2, col = "purple", lwd = 1)
}

#=----------------------------------------------------------
# plots of observed and predicted outcome 
#  - type = "d" : X-Y  scatter plot 
#  - type = "r" : residuals
#
plot_data_vs_prediction <- function(data = NULL, 
                                    prediction = NULL, 
                                    type = "d", 
                                    xlim = 25, 
                                    ylim = 25, 
                                    color = c(0.8, 0.0, 0.0),
                                    main = "") {

    if( type == "r" ) {
        ylab_str <- "residuals"
        slope <- 0
        ratio <- 2.0
        main_str <- paste0(main, "residuals")
    } else {
        ylab_str <- "Predicted"
        slope <- 1
        ratio <- 1.0
        main_str <- paste0(main, "scatterplot")
    }
    plot(data, prediction, 
         xlim = c(-1, 1)*xlim, 
         ylim = c(-1, 1)*ylim,
         pch = 19, col = rgb(color[1], color[2], color[3], 0.20), 
         cex = 0.9, 
         xlab = "Observed",
         ylab = ylab_str,
         main = main_str)
    grid()
    abline(c(0, slope), col = "grey30", lty = 2)
}

#===================================================================================================
# PLOTTING DATA
#=--------------------------------------------------------------------------------------------------

#=----------------------------------------------------------
# X-Y scatter plot of predictors and outcome values
# with contours at selected (z)levels.
# USES:
#  - get_zlevels()
#
plot_target_vs_variable <- function(data = NULL, 
                                    var = NULL, 
                                    zlevels = NULL, 
                                    lm_fit = FALSE) { 

    if( is.numeric(var) ) {
        k <- var
    } else {
        k <- which(colnames(data) == var)
    }

    yname <- colnames(data)[k]
    flag <- !is.na(data[, k])
    x <- data[flag, k]
    y <- data$target[flag]

    cor <- cor(y, x)

    if( lm_fit ) {
        mod <- lm(y ~ x)
        print(mod)
        cx <- summary(mod)$coeff
        icept <- cx[1, 1]
        slope <- cx[2, 1]
        prob_slope <- cx[2, 4]
        if(prob_slope < 0.05)  { lty <- 2 ; lwd <- 3 ; lcol <- "cadetblue";  str1 <- "_p005" }
        if(prob_slope < 0.01)  { lty <- 2 ; lwd <- 4 ; lcol <- "blue2";      str1 <- "_p001" }
        if(prob_slope < 0.001) { lty <- 4 ; lwd <- 5 ; lcol <- "green4";     str1 <- "_p0001" }
    }

    #---------
    z <- kde2d(x, y, n = 50)
    zlevels <- get_zlevels(zmat = z)
    #---------
    lty <- 3
    lwd <- 2
    lcol <- "lightblue"
    str1 <- ""
    str2 <- ""

    if( sum(abs(range(y))) > 20 ) { 
        yminmax <- c(-20, 20) 
        asp_ratio <- 0.25
    } else { 
        yminmax <- c(-4, 4) 
        asp_ratio <- 1.0
    }
    #---------

    plot(x, y, xlim = c(-4, 4), ylim = yminmax,
            pch = 19, col = rgb(0.8, 0, 0, 0.20), cex = 0.6, 
            main = as.expression(paste0(yname, "  /  corr = ", round(cor, 4))),
            xlab = as.expression(yname),
            ylab = "target",
            asp = asp_ratio)
    grid()
    contour(z, drawlabels = TRUE, levels = zlevels, 
            labels = c(0.1, 0.25, 0.5, 0.75, 0.9), 
            labcex = 1.0,
            # labcex = 1.25,
            lty = c(1, 2, 1, 2, 1),
            col = "grey20", add = TRUE)

    if( lm_fit ) {
        abline(mod$coef, lty = lty, lwd = lwd, col = lcol)
        mtext(as.expression(paste0("intercept = ", round(icept, 4), 
                                   "  /  slope = ", round(slope, 3), 
                                   "  /  p = ", round(prob_slope, 6))), 3)
    }

}

#=----------------------------------------------------------
# given a density matrix ('zmat') it finds the z values corresponding to the
# requested cumulative probability levels ('levels')
# 
get_zlevels <- function(zmat = NULL, 
                        levels = c(0.1, 0.25, 0.5, 0.75, 0.9)) {

    dx <- diff(zmat$x, lag = 1)[1]
    dy <- diff(zmat$y, lag = 1)[1]
    zdens <- data.frame(z_all = as.vector(zmat$z),  dpz_all = as.vector(zmat$z)*dx*dy)
    zdens <- zdens[order(zdens$z_all), ]
    row.names(zdens) <- NULL

    zdens$cumsum <- cumsum(zdens$dpz_all)
    return( sapply(c(0.1, 0.25, 0.5, 0.75, 0.9), function(x) zdens[zdens$cumsum >= x, ][1, 1]) )
}

#=----------------------------------------------------------
# Plots density curves of the values of the selected variable 
#  in the training and testing data sets (overlayed)
#
ggcompare_stats_distributions <- function(data = NULL, 
                                          var = NULL, 
                                          xlim = NULL) {
    
    df <- data[, c(var, "set")]
    df$set <- factor(df$set)
    colnames(df) <- c("stat", "DataSet")

    c_fill <- c("cadetblue", "goldenrod")
    c_line <- c("blue3", "orangered")
    xlabel <- deparse(substitute(var)) %>% gsub('"', '', .)

    p <- ggplot(data = df, aes(x = stat, fill = DataSet, col = DataSet)) + theme_bw() + 
         theme(legend.position = c(0.15, 0.85),
               axis.title = element_text(size = 14),
               axis.text= element_text(size = 12),
               axis.line = element_line(size = 1)
               ) +
         geom_density(alpha = 0.3) +
         scale_colour_manual(values = c_line) +
         scale_fill_manual(values = c_fill) + 
         xlab(xlabel)
    
    if(!is.null(xlim)) { p <- p + coord_cartesian(xlim = xlim) }

    return(p) 
}

#=----------------------------------------------------------
# Scatterplot of the summary statistics for a variable (var)
# the training and testing data sets (data1, data2).
#  - logic : expression that will be used to select points to highlight
#  - flag  : logical vector that will be used to select points to highlight
#
plot_stats_vs_stats <- function(data1 = NULL, 
                                data2 = NULL, 
                                var = NULL, 
                                logic = NULL, 
                                flag = NULL) {

    x <- data1[, var]
    y <- data2[, var]
    name <- row.names(x)
    vname <- deparse(substitute(var)) %>% gsub('"', '', .)

    if( is.null(flag) ) {
        flag <- rep(FALSE, length(x))
    }
    
    if( is.null(logic) ) {
        flag_l <- rep(FALSE, length(x))
    } else {
        flag_l <- eval(logic)
    }

    flag <- flag | flag_l
    
    lty <- 3
    lwd <- 2
    lcol <- "lightblue"
    asp_ratio <- 1.0
    str_xlab <- "Train"
    str_ylab <- "Test"

    xy <- c(x, y)
    minmax <- range(xy)

    plot(x, y, 
         xlim = minmax, ylim = minmax,
         pch = 19, col = rgb(0.8, 0, 0, 0.30), cex = 1.0, 
         main = as.expression(paste0("stat : ", vname)), 
         xlab = str_xlab,
         ylab = str_ylab,
         asp = asp_ratio)
    abline(c(0, 1), col = "grey30", lty = 2)

    if( !is.null(flag) ) {
        points(x[flag], y[flag],
               pch = 1, col = rgb(0, 0, 1.0, 1.00), cex = 1.4, lwd = 2.0)
    }

    grid()
}

#=----------------------------------------------------------
# Customized stripchart + boxplot function
#
boxplot_target_for_factor <- function(data = NULL, 
                                      factor_name = NULL) {

    fac_name <- deparse(substitute(factor_name)) %>% gsub('"', '', .)
    formula <- paste("target", fac_name, sep = " ~ ")

    stripchart(as.formula(formula), data = data, vertical = FALSE, 
               xlim = c(-25, 25),
               las = 1, 
               pch = 19, 
               cex = 0.5,
               col = rgb(0.8, 0, 0, 0.4), 
               method = "jitter", 
               jitter = 0.2,
               main = fac_name)

    boxplot(as.formula(formula), data = data, horizontal = TRUE, 
            las = 1, 
            pch = NA,
            cex = 0.75,
            lwd = 1.5,
            lty = 1,
            col = rgb(0.8, 0.8, 0, 0.3), 
            notch = TRUE, 
            add = TRUE)

}


#===================================================================================================
# Miscellaneous graphics stuff
#=--------------------------------------------------------------------------------------------------

plot_filled_histogram <- function(x, y, 
                                  xlim = NULL, 
                                  colors = c("black", "orange"), 
                                  xlab = NULL, 
                                  ylab = NULL, 
                                  main = NULL) {
    plot(x, y, type = "n", 
        xlim = xlim,
        xlab = xlab,
        ylab = ylab,
        main = main)

    poly <- get_polygon(x, y)
    polygon(poly$xp, poly$yp, border = NA, col = colors[2])

    lines(poly$xp, poly$yp, 
          col = colors[1],
          lwd = 3)
}

get_polygon <- function(x, y) {
    y2 <- rep(y, each=2)
    y2 <- y2[-length(y2)]
    x2 <- rep(x, each=2)[-1]
    x3 <- c(min(x2), x2, max(x2))
    y3 <- c(0, y2, 0)
    return(list(xp = x3, yp = y3))
}

#===================================================================================================

## ---- end-of-my_functions_plot

