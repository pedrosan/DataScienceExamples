#===================================================================================================
load(file = "my_data/marsN1.RData")
load(file = "my_data/marsN2.RData")
load(file = "my_data/marsN3.RData")
load(file = "my_data/marsN4.RData")
#===================================================================================================
# MARS
#---------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------
# MARS #4 : all data, not with 'caret'
#-----------------------------------------------------------

mars4.model <- earth(target ~ ., data = allTrain, degree =2, nfold = 5, keepxy = TRUE)

summary(mars4.model)

print(mars4.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- mars4.model$cv.oof.rsq.tab[nrow(mars4.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(mars4.model$cv.oof.rsq.tab == max(mars4.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
mars4.predict_train <- predict(mars4.model, allTrain[, -1])

mars4.metrics <- compute_metrics(data = allTrain$target, prediction = mars4.predict_train)
mars4.metrics$MSE
mars4.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(mars4.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(spTrain$target, mars4.predict_train, xlim = 25, ylim = 25, main = "(mars4) Training: ")

# Training set : residuals
plot_data_vs_prediction(spTrain$target, residuals(mars4.model), type = "r", xlim = 25, ylim = 20, main = "(mars4) Training: ")

# Training set : difference between histograms
plot_hist_difference(spTrain$target, mars4.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(mars4.model)
plot(mars4.model, which = 2, info = TRUE)
# plot(mars4.model, which = 1)
# plot(mars4.model, which = 3, info = TRUE)

plot.earth.models(mars4.model$cv.list, which = 1, ylim = c(0, 1.0))
plot(mars4.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)

#---------------------------------------------------------------------------------------------------
# MARS #5 : all data, not with 'caret', more CV
#-----------------------------------------------------------

mars5.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 6, ncross = 5, keepxy = TRUE)

summary(mars5.model)

print(mars5.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- mars5.model$cv.oof.rsq.tab[nrow(mars5.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(mars5.model$cv.oof.rsq.tab == max(mars5.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
mars5.predict_train <- predict(mars5.model, allTrain[, -1])

mars5.metrics <- compute_metrics(data = allTrain$target, prediction = mars5.predict_train)
mars5.metrics$MSE
mars5.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(mars5.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, mars5.predict_train, xlim = 25, ylim = 25, main = "(mars5) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(mars5.model), type = "r", xlim = 25, ylim = 20, main = "(mars5) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, mars5.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(mars5.model)
plot(mars5.model, which = 2, info = TRUE)   # Fig.17
# plot(mars5.model, which = 1)
# plot(mars5.model, which = 3, info = TRUE)

plotmo(mars5.model)

# Fig.16
plot.earth.models(mars5.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(mars5.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)

# RUN 1
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=4, nfold=6, degree=2)
# 
# coefficients
# (Intercept)                            10.8986172
# f_61c                                  -1.8577628
# f_61e                                  -3.4615617
# f_237Mexico                             1.4931164
# f_237USA                                0.5142589
# h(1.75343-f_35)                        -0.8707255
# h(f_35-1.75343)                         0.6209622
# h(-0.331132-f_94)                       8.4661926
# h(f_94- -0.331132)                     -8.3944079
# h(-0.771151-f_175)                     -2.9567168
# h(f_175- -0.771151)                     2.8393653
# h(2.78059-f_205)                       -1.7916660
# h(f_205-2.78059)                        3.2023592
# h(2.76626-f_218)                        6.8123250
# h(f_25-2.28656) * h(f_94- -0.331132)    3.1192608
# h(2.38873-f_94) * h(2.76626-f_218)     -3.1947621
# h(f_94-2.38873) * h(2.76626-f_218)      3.0939008
# 
# Selected 17 of 19 terms, and 10 of 264 predictors 
# Number of terms at each degree of interaction: 1 13 3
# GCV 2.320901  RSS 11414.97  GRSq 0.9161283  RSq 0.9174652  CVRSq 0.8990754

#---------------------------------------------------------------------------------------------------
# MARS #6 : all data, not with 'caret', more CV
#-----------------------------------------------------------

set.seed(24816)
mars6.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 6, ncross = 5, keepxy = TRUE)

summary(mars6.model)
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=4, nfold=6, degree=2)
#...

print(mars6.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- mars6.model$cv.oof.rsq.tab[nrow(mars6.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(mars6.model$cv.oof.rsq.tab == max(mars6.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
mars6.predict_train <- predict(mars6.model, allTrain[, -1])

mars6.metrics <- compute_metrics(data = allTrain$target, prediction = mars6.predict_train)
mars6.metrics$MSE
mars6.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(mars6.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, mars6.predict_train, xlim = 25, ylim = 25, main = "(mars6) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(mars6.model), type = "r", xlim = 25, ylim = 20, main = "(mars6) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, mars6.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(mars6.model)
plot(mars6.model, which = 2, info = TRUE)   # Fig.17
# plot(mars6.model, which = 1)
# plot(mars6.model, which = 3, info = TRUE)

plotmo(mars6.model)

# Fig.16
plot.earth.models(mars6.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(mars6.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)

#-----------------------------
# RUN 6a
#
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=5, nfold=6, degree=2)
# 
# coefficients
# (Intercept)                                -12.022015
# f_61c                                       -1.906893
# f_61e                                       -3.483744
# f_237Mexico                                  1.484509
# f_237USA                                     0.516353
# h(1.71637-f_35)                             -0.867484
# h(f_35-1.71637)                              0.690922
# h(1.91761-f_94)                              8.177387
# h(f_94-1.91761)                             -8.612518
# h(-0.779041-f_175)                          -3.051039
# h(f_175- -0.779041)                          2.882105
# h(0.437056-f_205)                           -1.785630
# h(f_205-0.437056)                            1.855265
# h(2.7266-f_218)                              6.858988
# h(f_218-2.7266)                              3.553351
# h(1.71637-f_35) * h(f_73-2.52208)            2.453241
# h(f_64-1.63996) * h(f_94-1.91761)          -89.036772
# h(2.41079-f_94) * h(2.7266-f_218)           -3.160518
# h(f_94-2.41079) * h(2.7266-f_218)            3.378559
# h(f_161- -0.247147) * h(-0.779041-f_175)     3.453811
# h(-0.779041-f_175) * h(-1.49365-f_179)       3.214365
# 
# Selected 21 of 25 terms, and 13 of 264 predictors 
# Number of terms at each degree of interaction: 1 14 6
# GCV 2.388929  RSS 11702.22  GRSq 0.91367  RSq 0.9153883  CVRSq -1785.581

#-----------------------------
# RUN 6b
#
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=5, nfold=6, degree=2)
# 
# coefficients
# (Intercept)                                -12.022015
# f_61c                                       -1.906893
# f_61e                                       -3.483744
# f_237Mexico                                  1.484509
# f_237USA                                     0.516353
# h(1.71637-f_35)                             -0.867484
# h(f_35-1.71637)                              0.690922
# h(1.91761-f_94)                              8.177387
# h(f_94-1.91761)                             -8.612518
# h(-0.779041-f_175)                          -3.051039
# h(f_175- -0.779041)                          2.882105
# h(0.437056-f_205)                           -1.785630
# h(f_205-0.437056)                            1.855265
# h(2.7266-f_218)                              6.858988
# h(f_218-2.7266)                              3.553351
# h(1.71637-f_35) * h(f_73-2.52208)            2.453241
# h(f_64-1.63996) * h(f_94-1.91761)          -89.036772
# h(2.41079-f_94) * h(2.7266-f_218)           -3.160518
# h(f_94-2.41079) * h(2.7266-f_218)            3.378559
# h(f_161- -0.247147) * h(-0.779041-f_175)     3.453811
# h(-0.779041-f_175) * h(-1.49365-f_179)       3.214365
# 
# Selected 21 of 25 terms, and 13 of 264 predictors 
# Number of terms at each degree of interaction: 1 14 6
# GCV 2.388929  RSS 11702.22  GRSq 0.91367  RSq 0.9153883  CVRSq -0.8590304


#---------------------------------------------------------------------------------------------------
# MARS #7 : all data, only 1st degree
#-----------------------------------------------------------

set.seed(1313)  # run 7b
mars7.model <- earth(target ~ ., data = allTrain, degree = 1, nfold = 8, ncross = 5, keepxy = TRUE)

summary(mars7.model)
#-----------------------------
# RUN 7a
#
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=5, nfold=8, degree=1)
# 
# coefficients
# (Intercept)             4.560783
# f_61c                  -1.771899
# f_61e                  -3.458779
# f_237Mexico             1.650869
# f_237USA                0.660523
# h(1.71637-f_35)        -0.908952
# h(2.41079-f_94)        -0.440046
# h(f_94-2.41079)         3.645939
# h(f_169-1.71855)        5.972175
# h(-0.779041-f_175)     -3.070084
# h(f_175- -0.779041)     2.819910
# h(f_182-2.81658)      -12.659641
# h(-0.300084-f_195)     -0.659158
# h(f_199-2.65335)       12.484831
# h(0.437056-f_205)      -1.670102
# h(f_205-0.437056)       2.028472
# h(f_218-2.58914)      -34.547847
# h(2.7266-f_218)        -0.782008
# h(f_218-2.7266)        50.807583
# h(f_219-2.73476)      -11.213989
# h(-0.158995-f_238)      0.211943
# h(f_238- -0.158995)     0.313169
# 
# Selected 22 of 28 terms, and 15 of 264 predictors 
# Number of terms at each degree of interaction: 1 21 (additive model)
# GCV 11.47133  RSS 56374.36  GRSq 0.5854541  RSq 0.5923906  CVRSq 0.5614142

#-----------------------------
# RUN 7b
#
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=5, nfold=8, degree=1)
# 
# coefficients
# (Intercept)             4.560783
# f_61c                  -1.771899
# f_61e                  -3.458779
# f_237Mexico             1.650869
# f_237USA                0.660523
# h(1.71637-f_35)        -0.908952
# h(2.41079-f_94)        -0.440046
# h(f_94-2.41079)         3.645939
# h(f_169-1.71855)        5.972175
# h(-0.779041-f_175)     -3.070084
# h(f_175- -0.779041)     2.819910
# h(f_182-2.81658)      -12.659641
# h(-0.300084-f_195)     -0.659158
# h(f_199-2.65335)       12.484831
# h(0.437056-f_205)      -1.670102
# h(f_205-0.437056)       2.028472
# h(f_218-2.58914)      -34.547847
# h(2.7266-f_218)        -0.782008
# h(f_218-2.7266)        50.807583
# h(f_219-2.73476)      -11.213989
# h(-0.158995-f_238)      0.211943
# h(f_238- -0.158995)     0.313169
# 
# Selected 22 of 28 terms, and 15 of 264 predictors 
# Number of terms at each degree of interaction: 1 21 (additive model)
# GCV 11.47133  RSS 56374.36  GRSq 0.5854541  RSq 0.5923906  CVRSq 0.5624021


print(mars7.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- mars7.model$cv.oof.rsq.tab[nrow(mars7.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(mars7.model$cv.oof.rsq.tab == max(mars7.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
mars7.predict_train <- predict(mars7.model, allTrain[, -1])

mars7.metrics <- compute_metrics(data = allTrain$target, prediction = mars7.predict_train)
mars7.metrics$MSE
mars7.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(mars7.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, mars7.predict_train, xlim = 25, ylim = 25, main = "(mars7) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(mars7.model), type = "r", xlim = 25, ylim = 20, main = "(mars7) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, mars7.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(mars7.model)
plot(mars7.model, which = 2, info = TRUE)   # Fig.17
# plot(mars7.model, which = 1)
# plot(mars7.model, which = 3, info = TRUE)

plotmo(mars7.model)

# Fig.16
plot.earth.models(mars7.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(mars7.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)


#---------------------------------------------------------------------------------------------------
# MARS #8 : all data, not with 'caret', more CV
#-----------------------------------------------------------

set.seed(7878)
mars8.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 5, ncross = 6, keepxy = TRUE)

summary(mars8.model)
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=6, nfold=5, degree=2)
# 
# coefficients
# (Intercept)                                -12.022015
# f_61c                                       -1.906893
# f_61e                                       -3.483744
# f_237Mexico                                  1.484509
# f_237USA                                     0.516353
# h(1.71637-f_35)                             -0.867484
# h(f_35-1.71637)                              0.690922
# h(1.91761-f_94)                              8.177387
# h(f_94-1.91761)                             -8.612518
# h(-0.779041-f_175)                          -3.051039
# h(f_175- -0.779041)                          2.882105
# h(0.437056-f_205)                           -1.785630
# h(f_205-0.437056)                            1.855265
# h(2.7266-f_218)                              6.858988
# h(f_218-2.7266)                              3.553351
# h(1.71637-f_35) * h(f_73-2.52208)            2.453241
# h(f_64-1.63996) * h(f_94-1.91761)          -89.036772
# h(2.41079-f_94) * h(2.7266-f_218)           -3.160518
# h(f_94-2.41079) * h(2.7266-f_218)            3.378559
# h(f_161- -0.247147) * h(-0.779041-f_175)     3.453811
# h(-0.779041-f_175) * h(-1.49365-f_179)       3.214365
# 
# Selected 21 of 25 terms, and 13 of 264 predictors 
# Number of terms at each degree of interaction: 1 14 6
# GCV 2.388929  RSS 11702.22  GRSq 0.91367  RSq 0.9153883  CVRSq -150310.8

evimp(mars8.model)
imp_vars <- row.names(evimp(mars8.model)) %>% gsub("[A-Za-z]*$", "", .) %>% unique(.)

print(mars8.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- mars8.model$cv.oof.rsq.tab[nrow(mars8.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(mars8.model$cv.oof.rsq.tab == max(mars8.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
mars8.predict_train <- predict(mars8.model, allTrain[, -1])

mars8.metrics <- compute_metrics(data = allTrain$target, prediction = mars8.predict_train)
mars8.metrics$MSE
mars8.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(mars8.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, mars8.predict_train, xlim = 25, ylim = 25, main = "(mars8) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(mars8.model), type = "r", xlim = 25, ylim = 20, main = "(mars8) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, mars8.predict_train)

par(mfcol = c(1, 1))
#--------------------------------------#

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(mars8.model)
plot(mars8.model, which = 2, info = TRUE)   # Fig.17
# plot(mars8.model, which = 1)
# plot(mars8.model, which = 3, info = TRUE)

plotmo(mars8.model)

# Fig.16
plot.earth.models(mars8.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(mars8.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)


#---------------------------------------------------------------------------------------------------
# MARS #N1 = #2931a : all data, not with 'caret', more CV
#-----------------------------------------------------------

set.seed(293111)
marsN1.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 5, ncross = 6, keepxy = TRUE)

summary(marsN1.model)
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=6, nfold=5, degree=2)
# 
# coefficients
# (Intercept)                               -7.778593
# f_61c                                     -1.892951
# f_61e                                     -3.443103
# f_237Mexico                                1.515953
# f_237USA                                   0.508410
# h(-0.45462-f_35)                          -0.863094
# h(f_35- -0.45462)                          0.856960
# h(1.84129-f_94)                            8.185400
# h(f_94-1.84129)                           -8.615932
# h(-0.350485-f_175)                        -2.897314
# h(f_175- -0.350485)                        2.824960
# h(2.7609-f_205)                           -1.794493
# h(f_205-2.7609)                            3.195921
# h(2.7266-f_218)                            6.762135
# h(f_218-2.7266)                            3.090793
# h(f_85-1.7543) * h(f_94-1.84129)        -267.598442
# h(2.38873-f_94) * h(2.7266-f_218)         -3.166116
# h(f_94-2.38873) * h(2.7266-f_218)          3.419594
# h(f_161-0.561281) * h(-0.350485-f_175)    14.264592
# 
# Selected 19 of 21 terms, and 11 of 264 predictors 
# Importance: f_175, f_205, f_94, f_218, f_61e, f_35, f_61c, f_237Mexico, f_85, f_237USA, f_161, f_0-unused, f_1-unused, f_2-unused, f_3-unused, f_4-unused, ...
# Number of terms at each degree of interaction: 1 14 4

evimp(marsN1.model)
#             nsubsets   gcv    rss
# f_175             18 100.0  100.0
# f_205             16  72.4   72.4
# f_94              15  72.6>  72.5>
# f_218             15  72.6   72.5
# f_61e             12  37.1   37.2
# f_35              11  28.7   28.7
# f_61c             10  23.7   23.8
# f_237Mexico        9  18.5   18.6
# f_85               5   7.7    8.0
# f_237USA           4   6.1    6.4
# f_161              3   4.6    4.8

imp_vars <- row.names(evimp(marsN1.model)) %>% gsub("[A-Za-z]*$", "", .) %>% unique(.)

#...

print(marsN1.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- marsN1.model$cv.oof.rsq.tab[nrow(marsN1.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(marsN1.model$cv.oof.rsq.tab == max(marsN1.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
marsN1.predict_train <- predict(marsN1.model, allTrain[, -1])

marsN1.metrics <- compute_metrics(data = allTrain$target, prediction = marsN1.predict_train)
marsN1.metrics$MSE
marsN1.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(marsN1.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, marsN1.predict_train, xlim = 25, ylim = 25, main = "(marsN1) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(marsN1.model), type = "r", xlim = 25, ylim = 20, main = "(marsN1) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, marsN1.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(marsN1.model)
plot(marsN1.model, which = 2, info = TRUE)   # Fig.17
# plot(marsN1.model, which = 1)
# plot(marsN1.model, which = 3, info = TRUE)

plotmo(marsN1.model, ylim = NA)

# Fig.16
plot.earth.models(marsN1.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(marsN1.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)


#---------------------------------------------------------------------------------------------------
# MARS #N2 = #7777a : all data, not with 'caret', more CV
#-----------------------------------------------------------

set.seed(777711)
marsN2.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 5, ncross = 6, keepxy = TRUE)

summary(marsN2.model)
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=6, nfold=5, degree=2)
# 
# coefficients
# (Intercept)                            4.3932656
# f_61c                                 -1.8484281
# f_61e                                 -3.4518793
# f_237Mexico                            1.5382089
# f_237USA                               0.5066329
# h(-0.516529-f_35)                     -0.9285587
# h(f_35- -0.516529)                     0.8411785
# h(-0.317052-f_94)                      8.1908066
# h(f_94- -0.317052)                    -8.0570019
# h(-0.79197-f_175)                     -2.9264043
# h(f_175- -0.79197)                     2.8666916
# h(0.443702-f_205)                     -1.7953955
# h(f_205-0.443702)                      1.8313630
# h(2.7266-f_218)                        6.6858965
# h(f_218-2.7266)                        2.8493045
# h(-0.516529-f_35) * h(f_73-2.35286)    7.6485434
# h(2.38873-f_94) * h(2.7266-f_218)     -3.1406172
# h(f_94-2.38873) * h(2.7266-f_218)      3.1285533
# 
# Selected 18 of 19 terms, and 10 of 264 predictors 
# Importance: f_175, f_205, f_94, f_218, f_61e, f_35, f_61c, f_237Mexico, f_237USA, f_73, f_0-unused, f_1-unused, f_2-unused, f_3-unused, f_4-unused, f_5-unused, ...
# Number of terms at each degree of interaction: 1 14 3

evimp(marsN2.model)
#             nsubsets   gcv    rss
# f_175             17 100.0  100.0
# f_205             15  71.5   71.5
# f_94              14  72.7>  72.6>
# f_218             14  72.7   72.6
# f_61e             12  48.4   48.4
# f_35               9  30.7   30.7
# f_61c              8  26.1   26.1
# f_237Mexico        6  16.4   16.5
# f_237USA           3   5.7    5.9
# f_73               2   3.9    4.1

imp_vars <- row.names(evimp(marsN2.model)) %>% gsub("[A-Za-z]*$", "", .) %>% unique(.)

#...

print(marsN2.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- marsN2.model$cv.oof.rsq.tab[nrow(marsN2.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(marsN2.model$cv.oof.rsq.tab == max(marsN2.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
marsN2.predict_train <- predict(marsN2.model, allTrain[, -1])

marsN2.metrics <- compute_metrics(data = allTrain$target, prediction = marsN2.predict_train)
marsN2.metrics$MSE
marsN2.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(marsN2.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, marsN2.predict_train, xlim = 25, ylim = 25, main = "(marsN2) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(marsN2.model), type = "r", xlim = 25, ylim = 20, main = "(marsN2) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, marsN2.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(marsN2.model)
plot(marsN2.model, which = 2, info = TRUE)   # Fig.17
# plot(marsN2.model, which = 1)
# plot(marsN2.model, which = 3, info = TRUE)

plotmo(marsN2.model)

# Fig.16
plot.earth.models(marsN2.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(marsN2.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)

#---------------------------------------------------------------------------------------------------
# MARS #N3 = #4853a : all data, not with 'caret', more CV
#-----------------------------------------------------------

set.seed(485311)
marsN3.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 5, ncross = 6, keepxy = TRUE)

summary(marsN3.model)
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=6, nfold=5, degree=2)
# 
# coefficients
# (Intercept)                            -11.6446232
# f_61c                                   -1.9671706
# f_61e                                   -3.5421656
# f_237Mexico                              1.5034153
# f_237USA                                 0.5388568
# h(-1.74871-f_35)                        -0.8884175
# h(f_35- -1.74871)                        0.8496770
# h(f_73-2.69681)                          7.0882725
# h(2.18198-f_94)                          8.2395910
# h(f_94-2.18198)                         -9.7848048
# h(-0.38468-f_175)                       -2.9482687
# h(f_175- -0.38468)                       2.8377941
# h(2.7609-f_205)                         -1.8021526
# h(f_205-2.7609)                          3.1149184
# h(2.76626-f_218)                         6.6460353
# h(f_218-2.76626)                         3.0407269
# h(2.38873-f_94) * h(2.76626-f_218)      -3.1416510
# h(f_94-2.38873) * h(2.76626-f_218)       3.7895943
# h(f_161-0.106835) * h(-0.38468-f_175)    4.0771906
# 
# Selected 19 of 21 terms, and 11 of 264 predictors 
# Importance: f_175, f_205, f_94, f_218, f_61e, f_35, f_61c, f_237Mexico, f_237USA, f_161, f_73, f_0-unused, f_1-unused, f_2-unused, f_3-unused, f_4-unused, ...
# Number of terms at each degree of interaction: 1 15 3

evimp(marsN3.model)
#             nsubsets   gcv    rss
# f_175             18 100.0  100.0
# f_205             16  71.9   72.0
# f_94              15  72.7>  72.6>
# f_218             15  72.7   72.6
# f_61e             13  43.2   43.2
# f_35              11  27.1   27.1
# f_61c             10  20.9   21.1
# f_237Mexico        9  14.2   14.4
# f_237USA           8   8.2    8.6
# f_161              5   5.5    5.9
# f_73               4   4.3    4.7

imp_vars <- row.names(evimp(marsN3.model)) %>% gsub("[A-Za-z]*$", "", .) %>% unique(.)

#...

print(marsN3.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- marsN3.model$cv.oof.rsq.tab[nrow(marsN3.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(marsN3.model$cv.oof.rsq.tab == max(marsN3.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
marsN3.predict_train <- predict(marsN3.model, allTrain[, -1])

marsN3.metrics <- compute_metrics(data = allTrain$target, prediction = marsN3.predict_train)
marsN3.metrics$MSE
marsN3.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(marsN3.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, marsN3.predict_train, xlim = 25, ylim = 25, main = "(marsN3) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(marsN3.model), type = "r", xlim = 25, ylim = 20, main = "(marsN3) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, marsN3.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(marsN3.model)
plot(marsN3.model, which = 2, info = TRUE)   # Fig.17
# plot(marsN3.model, which = 1)
# plot(marsN3.model, which = 3, info = TRUE)

plotmo(marsN3.model)

# Fig.16
plot.earth.models(marsN3.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(marsN3.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)


#---------------------------------------------------------------------------------------------------
# MARS #N4 = #6464a : all data, not with 'caret', more CV
#-----------------------------------------------------------

set.seed(646411)
marsN4.model <- earth(target ~ ., data = allTrain, degree = 2, nfold = 5, ncross = 6, keepxy = TRUE)

summary(marsN4.model)
# Call: earth(formula=target~., data=allTrain, keepxy=TRUE, ncross=6, nfold=5, degree=2)
# 
# coefficients
# (Intercept)                               -5.4517654
# f_61c                                     -1.8611246
# f_61e                                     -3.5208894
# f_237Mexico                                1.5330420
# f_237USA                                   0.5114941
# h(1.74462-f_35)                           -0.8745734
# h(f_35-1.74462)                            0.8686218
# h(1.05346-f_94)                            8.2623995
# h(f_94-1.05346)                           -7.9723987
# h(-0.800929-f_175)                        -2.9821025
# h(f_175- -0.800929)                        2.8492932
# h(0.143952-f_205)                         -1.7799823
# h(f_205-0.143952)                          1.8365448
# h(2.7266-f_218)                            6.5775061
# h(f_218-2.7266)                            2.9554053
# h(2.32379-f_94) * h(2.7266-f_218)         -3.1800323
# h(f_94-2.32379) * h(2.7266-f_218)          3.0405692
# h(f_161-0.0836778) * h(-0.800929-f_175)    7.1635419
# 
# Selected 18 of 19 terms, and 10 of 264 predictors 
# Importance: f_175, f_205, f_94, f_218, f_61e, f_35, f_61c, f_237Mexico, f_237USA, f_161, f_0-unused, f_1-unused, f_2-unused, f_3-unused, f_4-unused, f_5-unused, ...
# Number of terms at each degree of interaction: 1 14 3

evimp(marsN4.model)
#             nsubsets   gcv    rss
# f_175             17 100.0  100.0
# f_205             15  72.8   72.8
# f_94              14  74.0>  73.9>
# f_218             14  74.0   73.9
# f_61e             12  49.6   49.6
# f_35               9  32.0   32.0
# f_61c              7  20.8   20.9
# f_237Mexico        6  15.1   15.2
# f_237USA           4   5.8    6.1
# f_161              3   4.1    4.4

imp_vars <- row.names(evimp(marsN4.model)) %>% gsub("[A-Za-z]*$", "", .) %>% unique(.)

#----

print(marsN4.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- marsN4.model$cv.oof.rsq.tab[nrow(marsN4.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(marsN4.model$cv.oof.rsq.tab == max(marsN4.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
marsN4.predict_train <- predict(marsN4.model, allTrain[, -1])

marsN4.metrics <- compute_metrics(data = allTrain$target, prediction = marsN4.predict_train)
marsN4.metrics$MSE
marsN4.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(marsN4.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, marsN4.predict_train, xlim = 25, ylim = 25, main = "(marsN4) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(marsN4.model), type = "r", xlim = 25, ylim = 20, main = "(marsN4) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, marsN4.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(marsN4.model)
plot(marsN4.model, which = 2, info = TRUE)   # Fig.17
# plot(marsN4.model, which = 1)
# plot(marsN4.model, which = 3, info = TRUE)

plotmo(marsN4.model)

# Fig.16
plot.earth.models(marsN4.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(marsN4.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)



#---------------------------------------------------------------------------------------------------
# MARS #Top1 : on just important variables
#-----------------------------------------------------------
marsAll.impvars <- c("f_175", "f_205", "f_94", "f_218", "f_35", "f_85", "f_161", "f_73", "f_61", "f_237")
marsTop1.formula <- paste("target", paste0(marsAll.impvars, collapse = " + "), sep = " ~ ")

set.seed(293112)
marsTop1.model <- earth(as.formula(marsTop1.formula), data = allTrain, degree = 2, nfold = 5, ncross = 6, keepxy = TRUE)

summary(marsTop1.model)

evimp(marsTop1.model)

#----

print(marsTop1.model$cv.oof.rsq.tab, digits = 3)
mean.off.rsq.per.subset <- marsTop1.model$cv.oof.rsq.tab[nrow(marsTop1.model$cv.oof.rsq.tab), ]
n_prune_terms_selected_by_CV <- which.max(mean.off.rsq.per.subset)
which(marsTop1.model$cv.oof.rsq.tab == max(marsTop1.model$cv.oof.rsq.tab), arr.ind = TRUE)

#-----------------------------
# Predict on train
#-----------------------------
marsTop1.predict_train <- predict(marsTop1.model, allTrain[, -1])

marsTop1.metrics <- compute_metrics(data = allTrain$target, prediction = marsTop1.predict_train)
marsTop1.metrics$MSE
marsTop1.metrics$R2

#-----------------------------
# histograms
#-----------------------------
hist(allTrain$target,     breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)
hist(marsTop1.predict_train, breaks = seq(-30, 30, by = 1), xlim = c(-30, 30), col = "cadetblue", freq = FALSE)

#-----------------------------
# DIAGNOSTIC PLOTS 
#-----------------------------
par(mfcol = c(3, 1))

# Training set : predicted vs. observed
plot_data_vs_prediction(allTrain$target, marsTop1.predict_train, xlim = 25, ylim = 25, main = "(marsTop1) Training: ")

# Training set : residuals
plot_data_vs_prediction(allTrain$target, residuals(marsTop1.model), type = "r", xlim = 25, ylim = 20, main = "(marsTop1) Training: ")

# Training set : difference between histograms
plot_hist_difference(allTrain$target, marsTop1.predict_train)

par(mfcol = c(1, 1))

#-----------------------------
# MARS-specific diagnostics plots
#-----------------------------
plot(marsTop1.model)
plot(marsTop1.model, which = 2, info = TRUE)   # Fig.17
# plot(marsTop1.model, which = 1)
# plot(marsTop1.model, which = 3, info = TRUE)

plotmo(marsTop1.model)

# Fig.16
plot.earth.models(marsTop1.model$cv.list, which = 1, ylim = c(0, 1.0))
# Fig.19
plot(marsTop1.model, which = 1, col.mean.infold.rsq = "blue", col.infold.rsq = "lightblue", col.grsq = 0, col.rsq = 0, col.vline = 0, col.oof.vline = 0)


#===================================================================================================
