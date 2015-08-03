
## ---- my_functions_returns

#===================================================================================================

prepare_data <- function(data = NULL, xlin = NULL, xlog = NULL) {
    
    returns_log <- diff(log(data), lag = 1)
    returns_rel <- 100.0*(exp(returns_log) - 1)
    
    #---------------------------------------------------------------------
    # relative returns (linear, %)
    #---------------------------------------------------------------------

    # Fit with Generalized Lambda Distribution:
    rr_fit_gl <- fun.RMFMKL.ml(returns_rel)
    rr_fit_gl_y <- dgl(xlin, rr_fit_gl)

    # Fit with a Normal distribution, on the core of the data distribution
    rr_mean <- mean(returns_rel)
    rr_fit_norm1 <- fitdistr(returns_rel[abs(returns_rel - rr_mean) <= 5.0], "normal")
    rr_fit_norm2 <- fitdistr(returns_rel[abs(returns_rel - rr_mean) <= 2.0], "normal")

    rr_fit_norm1_y <- dnorm(xlin, mean = rr_fit_norm1$estimate[1], sd = rr_fit_norm1$estimate[2])
    rr_fit_norm2_y <- dnorm(xlin, mean = rr_fit_norm2$estimate[1], sd = rr_fit_norm2$estimate[2])

    rr_fit_n1 <- c(rr_fit_norm1$estimate[1], rr_fit_norm1$estimate[2])
    rr_fit_n2 <- c(rr_fit_norm2$estimate[1], rr_fit_norm2$estimate[2])

    returns_rel_distr.df <- data.frame(x = xlin, 
                                       y_gl = rr_fit_gl_y, 
                                       y_norm1 = rr_fit_norm1_y, 
                                       y_norm2 = rr_fit_norm2_y)

    #---------------------------------------------------------------------
    # log returns
    #---------------------------------------------------------------------

    # Fit with Generalized Lambda Distribution:
    rl_fit_gl <- fun.RMFMKL.ml(returns_log)
    rl_fit_gl_y <- dgl(xlog, rl_fit_gl)

    # Fit with a Normal distribution, on the core of the data distribution
    rl_mean <- mean(returns_log)
    rl_fit_norm1 <- fitdistr(returns_log[abs(returns_log - rl_mean) <= 0.05], "normal")
    rl_fit_norm2 <- fitdistr(returns_log[abs(returns_log - rl_mean) <= 0.02], "normal")

    rl_fit_norm1_y <- dnorm(xlog, mean = rl_fit_norm1$estimate[1], sd = rl_fit_norm1$estimate[2])
    rl_fit_norm2_y <- dnorm(xlog, mean = rl_fit_norm2$estimate[1], sd = rl_fit_norm2$estimate[2])
    
    rl_fit_n1 <- c(rl_fit_norm1$estimate[1], rl_fit_norm1$estimate[2])
    rl_fit_n2 <- c(rl_fit_norm2$estimate[1], rl_fit_norm2$estimate[2])
    
    returns_log_distr.df <- data.frame(x = xlog, 
                                       y_gl = rl_fit_gl_y, 
                                       y_norm1 = rl_fit_norm1_y, 
                                       y_norm2 = rl_fit_norm2_y)

    #---------------------------------------------------------------------

    list( rr_data = returns_rel,
          rr_fit_gl = rr_fit_gl,
          rr_fit_n1 = rr_fit_n1,
          rr_fit_n2 = rr_fit_n2,
          rr_distr = returns_rel_distr.df,
          rl_data = returns_log,
          rl_fit_gl = rl_fit_gl,
          rl_fit_n1 = rl_fit_n1,
          rl_fit_n2 = rl_fit_n2,
          rl_distr = returns_log_distr.df
        )
    
}

#===================================================================================================

mylog_trans <- function(base = exp(1), from = 0) {
    trans <- function(x) log(x, base) - from
    inv <- function(x) base^(x + from)
    trans_new("mylog", trans, inv, log_breaks(base = base), domain = c(base^from, Inf))
} 

#===================================================================================================

plot_distr_rel_returns <- function(data = NULL, 
                                   fits = NULL) {
    
    df <- data.frame(returns = data, stringsAsFactors = FALSE)

    pl.distr <- ggplot(data = df, aes(x = returns)) + theme_bw() + 
                    theme(axis.title = element_text(size = 16),
                          axis.text= element_text(size = 14),
                          axis.line = element_line(size = 1)) +
                    xlim(-8.0, 8.0) + 
                    xlab("daily relative returns (%)") + 
                    ylab("density") + 
                    geom_histogram(aes(y = ..density..), stat = "bin", drop = TRUE, 
                                   position = "identity", 
                                   binwidth = 0.2, 
                                   color = "grey50", fill = "gold", alpha = 0.3) + 
                    geom_line(data = fits, aes(x = x, y = y_norm1), color = "blue2", lty = 2, lwd = 1.5) + 
                    geom_line(data = fits, aes(x = x, y = y_norm2), color = "blue2", lwd = 1.5) + 
                    geom_line(data = fits, aes(x = x, y = y_gl), color = "red2", lwd = 1.5) + 
                    scale_y_continuous(trans = mylog_trans(base = 10, from = -3), 
                                       limits = c(0.001, 1.1), 
                                       breaks = c(0.001, 0.01, 0.1, 1.0))
    pl.distr

}

#===================================================================================================

plot_distr_log_returns <- function(data = NULL, 
                                   fits = NULL) {
    
    df <- data.frame(returns = data, stringsAsFactors = FALSE)
    hh <- hist(data, breaks = seq(-2.5, 2.5, by =0.0025), plot = FALSE)
    ymax <- 10.0**ceiling(log10(max(hh$density))) + 0.1

    pl.distr <- ggplot(data = df, aes(x = returns)) + theme_bw() + 
                    theme(axis.title = element_text(size = 16),
                          axis.text= element_text(size = 14),
                          axis.line = element_line(size = 1)) +
                    xlim(-0.1, 0.1) +
                    xlab("log(daily returns)") + 
                    ylab("density") + 
                    geom_histogram(aes(y = ..density..), stat = "bin", drop = TRUE, 
                                   position = "identity", 
                                   binwidth = 0.0025, 
                                   color = "grey50", fill = "gold", alpha = 0.3) + 
                    geom_line(data = fits, aes(x = x, y = y_norm1), color = "blue2", lty = 2, lwd = 1.5) + 
                    geom_line(data = fits, aes(x = x, y = y_norm2), color = "blue2", lwd = 1.5) + 
                    geom_line(data = fits, aes(x = x, y = y_gl), color = "red2", lwd = 1.5) +
                    scale_y_continuous(trans = mylog_trans(base = 10, from = -2),
                                       limits = c(0.01, ymax))
                                       # breaks = c(0.001, 0.01, 0.1, 1.0))

    pl.distr

}

#===================================================================================================

## ---- end-of-my_functions_returns

