library("quantmod")
library("GLDEX")
#----------------------------------------------------------

start.date <- "1986-01-01"
end.date <- "2011-12-31"

xx <- seq(-25.0, 25.0, 0.1)

#----------------------------------------------------------
getSymbols("VTSMX", from = "1994-01-01")
# getSymbols("VTSMX", from = start.date, to = end.date)
VTSMX.vec <- as.vector(VTSMX[, 4])
Wilsh5000 <- diff(log(VTSMX.vec), lag = 1)
Wilsh5000 <- 100.0*(exp(Wilsh5000) - 1)

W5000.fit.ml <- fun.RMFMKL.ml(Wilsh5000)
W5000.yy.gl <- dgl(xx, W5000.fit.ml)
W5000.yy.n <- dnorm(xx, mean = 0.0, sd = 0.75)

#----------------------------------------------------------
getSymbols("^GSPC", from = start.date, to = end.date)
GSPC.vec <- as.vector(GSPC[, 4])
SP500 <- diff(log(GSPC.vec), lag = 1)
SP500 <- 100.0*(exp(SP500) - 1)

SP500.fit.ml <- fun.RMFMKL.ml(SP500)
SP500.yy.gl <- dgl(xx, SP500.fit.ml)
SP500.yy.n <- dnorm(xx, mean = 0.0, sd = 0.7)

#----------------------------------------------------------
getSymbols("^NDX", from = start.date, to = end.date)
NDX.vec <- as.vector(NDX[, 4])
N100 <- diff(log(NDX.vec), lag = 1)
N100 <- 100.0*(exp(N100) - 1)

N100.fit.ml <- fun.RMFMKL.ml(N100)
N100.yy.gl <- dgl(xx, N100.fit.ml)
N100.yy.n <- dnorm(xx, mean = 0.0, sd = 1.1)

#----------------------------------------------------------

#----------------------------------------------------------
hist(Wilsh5000, breaks = seq(-25.0, 25.0, by = 0.20), xlim = c(-8.0, 8.0), freq = FALSE)
lines(xx, W5000.yy.gl, col = "red2")
lines(xx, W5000.yy.n, col = "blue2")

hist(SP500, breaks = seq(-25.0, 25.0, by = 0.10), xlim = c(-6.0, 6.0), freq = FALSE)
lines(xx, SP500.yy.gl, col = "red2")
lines(xx, SP500.yy.n, col = "blue2")

hist(N100, breaks = seq(-55.0, 55.0, by = 0.10), xlim = c(-6.0, 6.0), freq = FALSE)
lines(xx, N100.yy.gl, col = "red2")
lines(xx, N100.yy.n, col = "blue2")

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

