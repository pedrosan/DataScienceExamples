
source("scripts/my_functions.R")

# input_text <- "there are signs of economic"

input_refmt <- system2("./scripts/regularize_for_R.pl", input = input_text, stdout = TRUE)
words_all <- unlist(strsplit(input_refmt, split = "[ ;,.\"\t\r\n()!?:]+"))
nwords <- min(5, length(words_all))
    
if( nwords >= 5 ) {
    # words_select <- words_all[(length(words_all)-4):length(words_all)]
    words_select <- tail(words_all, 4)
} else {
    words_select <- words_all
}
print(words_select)
    
w_counts <- sapply(words_select, function(x) { get_word_count(x) }, USE.NAMES = FALSE )
w_IDs    <- sapply(words_select, function(x) { get_word_ID(x) }, USE.NAMES = FALSE )

print(w_counts)
print(w_IDs)

#-----------------------------------------------------------
threshold <- 1e6

n3s <- select_ngrams_xnew(ngrams = n3w, 
                          columns = 1:2, 
                          words = tail(w_IDs, 2), 
                          counts = tail(w_counts, 2), 
                          c_threshold = threshold) 

n4s <- select_ngrams_xnew(ngrams = n4w, 
                          columns = 1:3, 
                          words = tail(w_IDs, 3), 
                          counts = tail(w_counts, 3), 
                          c_threshold = threshold) 

n5s <- select_ngrams_xnew(ngrams = n5w, 
                          columns = 1:4, 
                          words = tail(w_IDs, 4), 
                          counts = tail(w_counts, 4), 
                          c_threshold = threshold) 

# ALT
# n4s_alt <- select_ngrams_xnew(ngrams = n4w, 
#                               columns = 1:3, 
#                               words = w_IDs[-2], 
#                               counts = w_counts[-2],
#                               c_threshold = threshold) 


#-------------------
bs_exp <- 0:3
bs_w2 <- 2^bs_exp 
bs_w3 <- 3^bs_exp 

binscore5_w2 <- apply(n5s$flags, 1, function(x) { x %*% bs_w2 } )
binscore5_w3 <- apply(n5s$flags, 1, function(x) { x %*% bs_w3 } )
n5text <- n5s$matches
n5text$logFreq <- NULL
n5text <- mutate(n5text, w1 = vec_words[w1], w2 = vec_words[w2], w3 = vec_words[w3], w4 = vec_words[w4], 
                 logP_pred = -1*(log10(vec_counts[pred])-7), logP = as.numeric(logP),
                 pred = vec_words[pred])
n5text$nm <- rowSums(n5s$flags)
n5text$bs2 <- binscore5_w2
n5text$bs3 <- binscore5_w3
group_by(n5text, nm) %>% summarise( n = n())
table(n5text$bs2, n5text$nm)
table(n5text$bs3, n5text$nm)

#-------------------
binscore4_w2 <- apply(n4s$flags, 1, function(x) { x %*% c(bs_w2[2:4], 0) } )
binscore4_w3 <- apply(n4s$flags, 1, function(x) { x %*% c(bs_w3[2:4], 0) } )
n4text <- n4s$matches
n4text$logFreq <- NULL
n4text <- mutate(n4text, w1 = vec_words[w1], w2 = vec_words[w2], w3 = vec_words[w3], 
                 logP_pred = -1*(log10(vec_counts[pred])-7), logP = as.numeric(logP),
                 pred = vec_words[pred])
n4text$nm <- rowSums(n4s$flags)
n4text$bs2 <- binscore4_w2
n4text$bs3 <- binscore4_w3
group_by(n4text, nm) %>% summarise( n = n())
table(n4text$bs2, n4text$nm)
table(n4text$bs3, n4text$nm)

#-------------------
binscore3_w2 <- apply(n3s$flags, 1, function(x) { x %*% c(bs_w2[3:4], 0, 0) } )
binscore3_w3 <- apply(n3s$flags, 1, function(x) { x %*% c(bs_w3[3:4], 0, 0) } )
n3text <- n3s$matches
n3text$logFreq <- NULL
n3text <- mutate(n3text, w1 = vec_words[w1], w2 = vec_words[w2], 
                 logP_pred = -1*(log10(vec_counts[pred])-7), logP = as.numeric(logP),
                 pred = vec_words[pred])
n3text$nm <- rowSums(n3s$flags)
n3text$bs2 <- binscore3_w2
n3text$bs3 <- binscore3_w3
group_by(n3text, nm) %>% summarise( n = n())
table(n3text$bs2, n3text$nm)
table(n3text$bs3, n3text$nm)




#--------------------[ 5-grams ]--------------------#

t( apply(n5s$matches[rowSums(n5s$flags) == 3, 1:4], 1, function(x) { vec_words[x] }))
t( apply(n5s$matches[rowSums(n5s$flags) == 3, 1:5], 1, function(x) { c(vec_words[x], vec_counts[x]) }))
t( apply(n5s$matches[rowSums(n5s$flags) == 4, 1:5], 1, function(x) { c(vec_words[x], vec_counts[x]) }))

n5text[(n5text$nm) == 1, 1:5]
n5text[(n5text$nm) == 2, 1:5]
n5text[(n5text$nm) == 3, 1:5]
n5text[(n5text$nm) == 4, 1:5]

#--------------------[ 4-grams ]--------------------#

t( apply(n4s$matches[rowSums(n4s$flags) == 2, 1:4], 1, function(x) { c(vec_words[x], vec_counts[x]) }))

# t( apply(n4s[, c(1:3, 7:9)], 1, function(x) c(vec_words[x[1:3]], x[4:6])) )

# qqq <- apply(n4s$matches[, c(1:3)], 1, function(x) c(vec_words[x]))
# t(qqq)
# 
# pop1 <- n4grams[n4grams$w1 == "251469", 1:3]
# nrow(pop1)
# t(apply(head(pop1, 20), 1, function(x) {vec_words[x]}))
# 
# pop2 <- n4grams[n4grams$w2 == "256331", 1:3]
# nrow(pop2)
# t(apply(head(pop2, 20), 1, function(x) {vec_words[x]}))
# 
# pop3 <- n4grams[n4grams$w3 == "188373", 1:3]
# nrow(pop3)
# t(apply(head(pop3, 20), 1, function(x) {vec_words[x]}))

n4grams[rowSums(n4s$flags) == 2, ]
t( apply(n4grams[rowSums(n4s$flags) == 2, 1:3], 1, function(x) { vec_words[x] }))

n4grams[rowSums(n4s$flags) == 3, ]
t( apply(n4grams[rowSums(n4s$flags) == 3, 1:3], 1, function(x) { vec_words[x] }))

t( apply(n4grams[rowSums(dff4$flags) == 3, 1:4], 1, function(x) { c(vec_words[x], vec_counts[x]) }))

# ALT

t( apply(n4grams[rowSums(n4s_alt$flags) == 2, 1:3], 1, function(x) { vec_words[x] }))
t( apply(n4grams[rowSums(n4s_alt$flags) == 2, 1:4], 1, function(x) { c(vec_words[x], vec_counts[x]) }))
t( apply(n4grams[rowSums(n4s_alt$flags) == 3, 1:4], 1, function(x) { c(vec_words[x], vec_counts[x]) }))

#--------------------[ 3-grams ]--------------------#

sum(rowSums(n3s$flags) > 0)
sum(rowSums(n3s$flags) == 1)
sum(rowSums(n3s$flags) == 2)

t( apply(n3grams[rowSums(n3s$flags) == 2, 1:2], 1, function(x) { vec_words[x] }))
t( apply(n3grams[rowSums(n3s$flags) == 2, 1:3], 1, function(x) { c(vec_words[x], vec_counts[x]) }))


