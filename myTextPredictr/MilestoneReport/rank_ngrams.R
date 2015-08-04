
n4g.t <- subset(n4g.twitter.freq, count >= 50)
n4g.t$flag <- "twitter"
n4g.b <- subset(n4g.blogs.freq, count >= 50)
n4g.b$flag <- "blogs"
n4g.n <- subset(n4g.news.freq, count >= 50)
n4g.n$flag <- "news"

n4g.high <- rbind(n4g.b, n4g.n, n4g.t)
row.names(n4g.high) <- NULL
n4g.high.sorted <- n4g.high[order(n4g.high$count, decreasing = TRUE), ]
row.names(n4g.high.sorted) <- NULL


