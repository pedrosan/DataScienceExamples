#---------------------------------------------------------------------------------------------------
# http://www.r-bloggers.com/the-generalized-lambda-distribution-and-gldex-package-fitting-financial-return-data/
# http://www.r-bloggers.com/the-generalized-lambda-distribution-and-gldex-package-for-fitting-financial-return-data-part-2/
#---------------------------------------------------------------------------------------------------

#----------------------------------------------------------
library("quantmod")
library("GLDEX")
#----------------------------------------------------------

start.date <- "1986-01-01"
end.date <- "2014-12-31"

xx <- seq(-25.0, 25.0, 0.1)

#----------------------------------------------------------
# Wilshire 5000
#----------------------------------------------------------
# getSymbols("VTSMX", from = "1994-01-01")
getSymbols("VTSMX", from = start.date, to = end.date)
VTSMX.vec <- as.vector(VTSMX[, 4])

# log-returns
Wilsh5000 <- diff(log(VTSMX.vec), lag = 1)
Wilsh5000 <- 100.0*(exp(Wilsh5000) - 1)

# fit with Generalized Lambda Distr.
W5000.fit.ml <- fun.RMFMKL.ml(Wilsh5000)
W5000.yy.gl <- dgl(xx, W5000.fit.ml)
W5000.yy.n <- dnorm(xx, mean = 0.0, sd = 0.75)

# prepare useful data frames
W5000_data.df <- data.frame(returns = Wilsh5000, stringsAsFactors = FALSE)
W5000_fits.df <- data.frame(xgl = xx, ygl = W5000.yy.gl, yn = W5000.yy.n)

#----------------------------------------------------------
# S&P 500 
#----------------------------------------------------------
getSymbols("^GSPC", from = start.date, to = end.date)
GSPC.vec <- as.vector(GSPC[, 4])

# log-returns
SP500 <- diff(log(GSPC.vec), lag = 1)
SP500 <- 100.0*(exp(SP500) - 1)

# fit with Generalized Lambda Distr.
SP500.fit.ml <- fun.RMFMKL.ml(SP500)
SP500.yy.gl <- dgl(xx, SP500.fit.ml)
SP500.yy.n <- dnorm(xx, mean = 0.0, sd = 0.7)

# prepare useful data frames
SP500_data.df <- data.frame(returns = SP500, stringsAsFactors = FALSE)
SP500_fits.df <- data.frame(xgl = xx, ygl = SP500.yy.gl, yn = SP500.yy.n)

#----------------------------------------------------------
# NASDAQ 100
#----------------------------------------------------------
getSymbols("^NDX", from = start.date, to = end.date)
NDX.vec <- as.vector(NDX[, 4])

# log-returns
N100 <- diff(log(NDX.vec), lag = 1)
N100 <- 100.0*(exp(N100) - 1)

# fit with Generalized Lambda Distr.
N100.fit.ml <- fun.RMFMKL.ml(N100)
N100.yy.gl <- dgl(xx, N100.fit.ml)
N100.yy.n <- dnorm(xx, mean = 0.0, sd = 1.1)

# prepare useful data frames
N100_data.df <- data.frame(returns = N100, stringsAsFactors = FALSE)
N100_fits.df <- data.frame(xgl = xx, ygl = N100.yy.gl, yn = N100.yy.n)

#----------------------------------------------------------

#----------------------------------------------------------
hist(Wilsh5000, breaks = seq(-55.0, 55.0, by = 0.10), xlim = c(-8.0, 8.0), freq = FALSE,
     xlab = "daily returns (%)",
     main = "Wilshire5000")
lines(xx, W5000.yy.n, col = "blue2", lwd = 2)
lines(xx, W5000.yy.gl, col = "red2", lwd = 2)

hist(SP500, breaks = seq(-55.0, 55.0, by = 0.10), xlim = c(-8.0, 8.0), freq = FALSE)
lines(xx, SP500.yy.n, col = "blue2", lwd = 2)
lines(xx, SP500.yy.gl, col = "red2", lwd = 2)

hist(N100, breaks = seq(-55.0, 55.0, by = 0.10), xlim = c(-8.0, 8.0), freq = FALSE)
lines(xx, N100.yy.n, col = "blue2", lwd = 2)
lines(xx, N100.yy.gl, col = "red2", lwd = 2)

#----------------------------------------------------------
library("scales")
mylog_trans <- function(base = exp(1), from = 0) {
    trans <- function(x) log(x, base)-from
    inv <- function(x) base^(x+from)
    trans_new("mylog", trans, inv, log_breaks(base=base), domain = c(base^from, Inf))
} 

pl.w5000 <- ggplot(data = W5000_data.df, aes(x = returns)) + theme_bw() + 
            theme(axis.title = element_text(size = 16),
                  axis.text= element_text(size = 14),
                  axis.line = element_line(size = 1)) +
            xlim(-8.0, 8.0)

pl.w5000.b <- pl.w5000 + geom_histogram(aes(y = ..density..), stat = "bin", drop = TRUE, 
                                        position = "identity", 
                                        binwidth = 0.1, 
                                        width = 0.5,
                                        color = "grey50", fill = "gold", alpha = 0.5)

pl.w5000.b

 
pl.w5000.b + scale_y_continuous(trans = mylog_trans(base = 10, from = -3), 
                                limits = c(0.001, 1.1), 
                                breaks = c(0.001, 0.01, 0.1, 1.0))

pl.w5000.c <- pl.w5000.b + 
                geom_line(data = W5000_fit.df, aes(x = xgl, y = yn), color = "blue2", lwd = 1.5) + 
                geom_line(data = W5000_fit.df, aes(x = xgl, y = ygl), color = "red2", lwd = 1.5)

gg.w5000.c
gg.w5000.c + scale_y_continuous(trans = mylog_trans(base = 10, from = -3), 
                                limits = c(0.001, 1.1), 
                                breaks = c(0.001, 0.01, 0.1, 1.0))

#----------------------------------------------------------

ndays <- length(N100)/25
N <- 1e6

test.N100 <- rep(0, N)
for(j in 1:N) {
    dummy <- rgl(ndays, N100.fit.ml)
    test.N100[j] <- (cumprod(1 + dummy/100)[ndays] - 1.0)*100
}


test.SP500 <- rep(0, N)
for(j in 1:N) {
    dummy <- rgl(ndays, SP500.fit.ml)
    test.SP500[j] <- (cumprod(1 + dummy/100)[ndays] - 1.0)*100
}

# hist(test.N100, breaks = seq(-500.0, 500.0, by = 0.50), xlim = c(-200.0, 300.0), freq = FALSE, border = "red2")
# hist(test.SP500, breaks = seq(-500.0, 500.0, by = 0.50), xlim = c(-200.0, 300.0), freq = FALSE, border = "blue2", add = TRUE)

xx2 <- seq(-100, 200, by = 1.0)
yy.n100.n <- dnorm(xx2, mean = 16.08, sd = 36.13)
yy.sp500.n <- dnorm(xx2, mean = 9.57, sd = 21.97)
yy.n100.n <- dnorm(xx2, mean = mean(test.N100), sd = sd(test.N100))
yy.sp500.n <- dnorm(xx2, mean = mean(test.SP500), sd = sd(test.SP500))


png(file = "sp500_vs_n100_vs_gaussians.png", height = 1024, width = 1024, res = 144)

plot(density(test.SP500), xlim = c(-100.0, 200.0), type = "n", xlab = "annual return [%]", main = "S&P500 vs. NASDAQ100")
grid()
lines(density(test.N100), col = "red2", lwd = 3)
lines(density(test.SP500), col = "blue2", lwd = 3)
lines(xx2, yy.n100.n, col = "pink2", lty = 2, lwd = 3)
lines(xx2, yy.sp500.n, col = "lightblue", lty = 2, lwd = 3)

dev.off()

