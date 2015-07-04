#---------------------------------------------------------------------------------------------------
# from: purl("Part2.Rmd")
#---------------------------------------------------------------------------------------------------

## ----setup, cache = FALSE, echo = FALSE, message = FALSE, warning = FALSE, tidy = FALSE----
require(knitr)
options(width = 100, 
        scipen = 5)
opts_chunk$set(message = FALSE, 
               error = FALSE, 
               warning = FALSE, 
               collapse = TRUE, 
               tidy = FALSE,
               cache = FALSE, 
               cache.path = '.cache/', 
               comment = '#',
               fig.align = 'center', 
               dpi = 100, 
               fig.path = 'figures/Part1/')

# required libraries
library("dplyr")
library("tidyr")
library("magrittr")
library("stringr")
library("ggplot2")

## ----load_packages, cache = FALSE, echo = FALSE, message = FALSE, warning = FALSE, tidy = FALSE----
source("./scripts/my_functions_baby_names.R")

## ----data_loading, cache = TRUE------------------------------------------
states_codes <- list.files("./data/", pattern = "*.TXT") %>% gsub("\\.TXT", "", ., perl = TRUE)
data_dir <- "data"

# reading and merging them directly in a single data frame
df <- do.call(bind_rows, lapply( list.files(data_dir, pattern = "[A-Z][A-Z].TXT.gz", full.names = TRUE), 
                function(x) { read.csv(x, header = FALSE, stringsAsFactors = FALSE) }) )
colnames(df) <- c("state", "gender", "year", "name", "count")

## ----more_preparation, cache = TRUE, echo = FALSE------------------------
unique_names_F <- filter(df, gender == "F") %>% dplyr::select(name) %>% unique(.)
unique_names_M <- filter(df, gender == "M") %>% dplyr::select(name) %>% unique(.) 
unique_names <- list(F = as.vector(unique_names_F), M = as.vector(unique_names_M))
bisex_names <- intersect(unique_names$F, unique_names$M)

rm(unique_names_F, unique_names_M)

## ----q1-show_lines_of_data_file------------------------------------------
file.head("data/AK.TXT.gz", n = 10)

## ----q1-show_lines_of_data_frame-----------------------------------------
df[sample(1:nrow(df), 12), ]

## ----plot_power_law_distribution_example_x4, fig.width = 7, fig.height = 4, echo = FALSE----
par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 1)+0.1, cex.axis = 1.0)
single_panel_mar <- c(2, 2, 2, 1)
single_panel_oma <- c(0 ,0, 2, 0)
gr_par <- list( mar = single_panel_mar, oma = single_panel_oma, 
                cex = 1.0, cex.axis = 0.8, cex.lab = 1.0, 
                las = 0, mgp = c(1.0, 0.0, 0),
                tcl = 0.3)
par(gr_par)

mat.layout <- matrix(1:2, nrow = 1, byrow = TRUE)
layout(mat.layout)

plot_hist_state_year_with_fit(data = df, STATE = "OK", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "TX", YEAR = 2009:2013, subset = quote(y > log10(25)))

par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 1)+0.1, cex.axis = 1.0)
title("Examples of Distributions of Names by Count", cex.main = 1.25, outer = TRUE)

## ----q2-prep_top_10_lists, echo = FALSE----------------------------------
top10_FM  <- group_by(df, name) %>% summarize(n = sum(count)) %>% arrange(desc(n)) %>% head( . , 10)
top10_F   <- filter(df, gender == "F") %>% group_by(name) %>% summarize(n = sum(count)) %>% arrange(desc(n)) %>% head( . , 10)
top10_M   <- filter(df, gender == "M") %>% group_by(name) %>% summarize(n = sum(count)) %>% arrange(desc(n)) %>% head( . , 10)
top10_all <- bind_cols(top10_FM, top10_F, top10_M)
colnames(top10_all) <- c("AnyGender", "N_any", "Female", "N_female", "Male", "N_male")

## ----q1-print_rankings_table, echo = FALSE-------------------------------
print(top10_all, print.gap = 5)

## ----q3-most_ambiguous_names-prepare_data, echo = FALSE------------------
# Preparing the relevant data frames
c2013 <- intersect_MF_names_1year(data = df, select_year = 2013)$common
c1945 <- intersect_MF_names_1year(data = df, select_year = 1945)$common

# how many rows to show
N_show <- 5

# Accepted F/M ratio for method #3, and corresponding normalized difference.
r_threshold <- 0.8
rn <- abs((r_threshold - 1)/(r_threshold + 1))

## ----q3-most_ambiguous_2013-method1, echo = FALSE------------------------
# diff = 0, sorted by total number
top2013a <- filter(c2013, diff == 0) %>% arrange(desc(N_tot)) %>% as.data.frame(.) %>% head( . , N_show)
kable(top2013a, row.names = TRUE)

## ----q3-most_ambiguous_2013-method2a, echo = FALSE-----------------------
# diff > 0, sorted by normalized difference
top2013a <- filter(c2013, diff > 0) %>% arrange(diff_norm) %>% as.data.frame(.) %>% head( . , N_show)
kable(top2013a, row.names = TRUE)

## ----q3-most_ambiguous_2013-method3, echo = FALSE------------------------
top2013 <- filter(c2013, diff_norm <= rn) %>% arrange(desc(N_tot)) %>% as.data.frame(.) %>% head( . , N_show)
kable(top2013, row.names = TRUE)


## ----q3-most_ambiguous_2013-method3-plot, echo = FALSE, fig.width = 6.0, fig.height = 6.0----
single_panel_mar <- c(3, 3, 2, 2)
single_panel_oma <- c(0 ,0, 2, 0)
gr_par <- list( mar = single_panel_mar, oma = single_panel_oma, 
                cex = 1.2, cex.axis = 1.0, cex.lab = 1.2, cex.main = 1.0,
                las = 0, mgp = c(1.75, 0.5, 0),
                tcl = 0.3)
par(gr_par)
lab_x <- top2013[, "N_female"]
lab_y <- top2013[, "N_male"]
lab_s <- top2013[, "Name"]
lab_pos <- rep(c(4, 2), length.out = N_show)

x  <- seq(5, 30000, by = 100)
y1 <- (1 - rn)/(1 + rn)*x
y2 <- (1 + rn)/(1 - rn)*x

plot(c2013$N_female, c2013$N_male, log = "xy", 
     xlim = c(4, 20000), ylim = c(4, 20000), asp = 1,
     pch = 21, col = "orangered2", bg = rgb(0.8, 0.3, 0, 0.3),
     xlab = "N female",
     ylab = "N male",
     main = "Male/Female Counts of Ambiguous Names (2013)")
points(c2013$N_female[c2013$diff_norm <= abs(rn)], c2013$N_male[c2013$diff_norm <= abs(rn)], 
                    pch = 23, col = "darkgreen", bg = rgb(0, 0.9, 0, 0.3))
points(c2013$N_female[c2013$diff == 0], c2013$N_male[c2013$diff == 0], 
                    pch = 23, col = "blue2", bg = rgb(0, 0, 0.9, 0.3))
lines(x, y1, lty = 4, lwd = 1.5, col = "forestgreen")
lines(x, y2, lty = 4, lwd = 1.5, col = "forestgreen")
grid()
text(lab_x, lab_y, labels = lab_s, pos = lab_pos, cex = 0.9, adj = c(NA, 0))

## ----q3-most_ambiguous_1945-method3_v2, echo = FALSE---------------------
top1945 <- filter(c1945, diff_norm <= rn) %>% arrange(desc(N_tot)) %>% as.data.frame(.) %>% head( . , N_show)
kable(top1945, row.names = TRUE)

## ----q3-most_ambiguous_1945-method3-plot, echo = FALSE, fig.width = 6.0, fig.height = 6.0----
par(gr_par)
lab_x <- top1945[, "N_female"]
lab_y <- top1945[, "N_male"]
lab_s <- top1945[, "Name"]

plot(c1945$N_female, c1945$N_male, log = "xy", 
     xlim = c(4, 20000), ylim = c(4, 20000), asp = 1,
     pch = 21, col = "orangered2", bg = rgb(0.8, 0.3, 0, 0.3),
     xlab = "N female",
     ylab = "N male",
     main = "Male/Female Counts of Ambiguous Names (1945)")
points(c1945$N_female[c1945$diff_norm <= abs(rn)], c1945$N_male[c1945$diff_norm <= abs(rn)], 
                    pch = 23, col = "darkgreen", bg = rgb(0, 0.9, 0, 0.3))
points(c1945$N_female[c1945$diff == 0], c1945$N_male[c1945$diff == 0], 
                    pch = 23, col = "blue2", bg = rgb(0, 0, 0.9, 0.3))
lines(x, y1, lty = 4, lwd = 1.5, col = "forestgreen")
lines(x, y2, lty = 4, lwd = 1.5, col = "forestgreen")
grid()
text(lab_x, lab_y, labels = lab_s, pos = lab_pos, cex = 0.9, adj = c(NA, 0))

## ----q4-largest_changes-prepare_data, echo = FALSE-----------------------
all1980 <- filter(df, year == 1980) %>% mutate(nameg = paste0(name, "_", gender)) %>% 
                                        group_by(nameg) %>% 
                                        summarize(n1980 = sum(count))

all2013 <- filter(df, year == 2013) %>% mutate(nameg = paste0(name, "_", gender)) %>% 
                                        group_by(nameg) %>% 
                                        summarize(n2013 = sum(count))

#---------
inboth_namesG <- inner_join(all1980, all2013, by = "nameg") %>% mutate(ntot = n1980 + n2013, 
                                                                       change_pct = 100*(n2013 - n1980)/n1980,
                                                                       rev_pct = 100*(n1980 - n2013)/n2013,
                                                                       gender = str_sub(nameg, start = -1),
                                                                       name = str_replace(nameg, "_[FM]", "")) 
inboth_names <- inboth_namesG[, c(8, 7, 2:6)]
rm(inboth_namesG)

max_increase <- max(inboth_names$change_pct)
max_rev_decrease <- max(inboth_names$rev_pct)
#---------
# data for question 5
in2013_not1980 <- anti_join(all2013, all1980, by = "nameg") %>% mutate(change_if_1 = 100*(n2013 - 1),
                                                                       gender = str_sub(nameg, start = -1),
                                                                       name = str_replace(nameg, "_[FM]", ""))
in1980_not2013 <- anti_join(all1980, all2013, by = "nameg") %>% mutate(rev_change_if_1 = 100*(n1980 - 1),
                                                                       gender = str_sub(nameg, start = -1),
                                                                       name = str_replace(nameg, "_[FM]", ""))
in2013_not1980 <- in2013_not1980[, c(5, 4, 2, 3)]
in1980_not2013 <- in1980_not2013[, c(5, 4, 2, 3)]

#---------
# how many names to print
N_show <- 5

## ----q4-largest_change-prepare_data-exclusive_and_common_names, echo = FALSE----
names_in_both   <-  (all1980$nameg %in% all2013$nameg)
names_only_1980 <- !(all1980$nameg %in% all2013$nameg)
names_only_2013 <- !(all2013$nameg %in% all1980$nameg)

## ----q4-largest_increase_table, echo = FALSE-----------------------------
tab4a <- arrange(inboth_names, desc(change_pct)) %>% dplyr::select( . , -ntot, -rev_pct) 
kable(head(tab4a, N_show), row.names = TRUE, digits = 0)

# for stats inline comments
frac_up_F_20 <- sum(head(tab4a, 20)$gender == "F")/20
frac_up_F_50 <- sum(head(tab4a, 50)$gender == "F")/50

## ----q4-largest_decrease_table, echo = FALSE-----------------------------
tab4b <- arrange(inboth_names, change_pct) %>% dplyr::select( . , -ntot)
digits_vec <- rep(0, ncol(tab4b)) 
digits_vec[which(colnames(tab4b)=="change_pct")] <- 2
kable(head(tab4b, N_show), row.names = TRUE, digits = digits_vec)

# for stats inline comments
frac_down_F_20 <- sum(head(tab4b, 20)$gender == "F")/20
frac_down_F_50 <- sum(head(tab4b, 50)$gender == "F")/50

## ----q5-max_potential_increase, echo = FALSE-----------------------------
tab5a <- filter(in2013_not1980, change_if_1 > max_increase) %>% arrange(desc(change_if_1))

kable(head(tab5a, N_show), row.names = TRUE, digits = 2)

## ----q5-max_potential_decrease, echo = FALSE-----------------------------
tab5b <- filter(in1980_not2013, rev_change_if_1 > max_rev_decrease) %>% arrange(desc(rev_change_if_1))

kable(head(tab5b, N_show), row.names = TRUE, digits = 0)

## ----other-prepare_data_by_year_by_gender, cache = TRUE, echo = FALSE----
by_year_by_gender <- group_by(df, year, gender) %>% summarize(n = n(), 
                                                              tot_count = sum(count/1000), 
                                                              n_dist = n_distinct(name),
                                                              ratio1 = tot_count / n_dist, 
                                                              ratio2 = n_dist / tot_count)


## ----other-plot_number_of_distinct_names, fig.width = 7, fig.height = 5, echo = FALSE----
colors_FM <- c("pink2", "dodgerblue2")

ggplot(by_year_by_gender, aes(x = year, y = n_dist)) + theme_bw() + 
            theme(legend.position = c(0.15, 0.85),
                axis.title = element_text(size = 14),
                axis.text= element_text(size = 12),
                axis.line = element_line(size = 1)
                ) +
       scale_color_manual(values = colors_FM) + 
       scale_fill_manual(values = colors_FM) + 
       scale_y_log10(breaks = c(1000, 2000, 4000)) + 
       labs(title = "Number of Distinct Names") + 
       ylab("Count") +
       geom_line(aes(color = gender), size = 1.2) + 
       geom_point(aes(fill = gender), alpha = 0.75, pch = 21, size = 3) 

## ----other-plot_total_counts, fig.width = 7, fig.height = 5, echo = FALSE----
ggplot(by_year_by_gender, aes(x = year, y = tot_count)) + theme_bw() + 
       theme(legend.position = c(0.15, 0.85),
           axis.title = element_text(size = 14),
           axis.text= element_text(size = 12),
           axis.line = element_line(size = 1)
           ) +
       scale_color_manual(values = colors_FM) + 
       scale_fill_manual(values = colors_FM) + 
       scale_y_log10(breaks = 100*2**(1:7)) +
       coord_cartesian(ylim = c(300, 3000)) +
       labs(title = "Total count (~ total number of births?)") +
       ylab("Count (thousands)") +
       geom_line(aes(color = gender), size = 1.2) + 
       geom_point(aes(fill = gender), alpha = 0.75, pch = 21, size = 3) 

## ----other-names_coverage-some_aggregation, cache = TRUE, echo = FALSE----
for_coverage2a <- group_by(df, year, name) %>% summarize(tot_count = sum(count)) %>% 
                                               arrange(year, desc(tot_count)) %>% 
                                               summarise(fn90 = get_coverage(tot_count, 90)$Fcov,
                                                         fn95 = get_coverage(tot_count, 95)$Fcov,
                                                         fn99 = get_coverage(tot_count, 99)$Fcov)

for_coverage2 <- gather(for_coverage2a, cutoff, fcov, fn90, fn95, fn99, -year)

## ----other-names_coverage-plot, fig.width = 7, fig.height = 5.5, echo = FALSE----
cols <- c("red2", "blue2", "orange")
ggplot(for_coverage2, aes(x = year, y = fcov)) + theme_bw() + 
            theme(legend.position = c(0.2, 0.85),
                  axis.title = element_text(size = 14),
                  axis.text= element_text(size = 12),
                  axis.line = element_line(size = 1)
                  ) +
            scale_color_manual(values = cols) + 
            scale_fill_manual(values = cols) + 
            coord_cartesian(ylim = c(0.0, 0.8)) +
            labs(title = "Fraction of Names Needed to Cover Given Fraction of Newborn)") + 
            geom_line(aes(color = cutoff), size = 1.2) + 
            geom_point(aes(fill = cutoff), alpha = 0.75, pch = 21, size = 3) 

## ----other-plot_power_law_distribution_examples, fig.width = 7, fig.height = 10, echo = FALSE----
par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 1)+0.1, cex.axis = 1.0)
single_panel_mar <- c(2, 2, 2, 1)
single_panel_oma <- c(0 ,0, 2, 0)
gr_par <- list( mar = single_panel_mar, oma = single_panel_oma, 
                cex = 1.0, cex.axis = 0.8, cex.lab = 1.0, 
                las = 0, mgp = c(1.0, 0.0, 0),
                tcl = 0.3)

par(gr_par)

mat.layout <- matrix(1:8, nrow = 4, byrow = TRUE)
layout(mat.layout)

plot_hist_state_year_with_fit(data = df, STATE = "AZ", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "CA", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "CO", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "DE", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "OK", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "SC", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "TN", YEAR = 2009:2013, subset = quote(y > log10(25)))
plot_hist_state_year_with_fit(data = df, STATE = "TX", YEAR = 2009:2013, subset = quote(y > log10(25)))

par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 1)+0.1, cex.axis = 1.0)
title("Distributions", cex.main = 1.25, outer = TRUE)

## ----other-prepare_data-power_law_fits, cache = TRUE, echo = FALSE, eval = FALSE----
## powerlaw_fits <- prepare_powerlaw_fits_data_frame(data = df)

## ----other-prepare_data-load_saved_power_law_fits, cache = TRUE, echo = FALSE----
powerlaw_fits <- readRDS("my_data/powerlaw_fits.RDS")

## ----other-plot-power_law_fits_slope_F, fig.width = 7, fig.height = 7, echo = FALSE----
ggplot(powerlaw_fits, aes(x = Time, y = slopeF, color = State)) + theme_bw() + 
        theme(legend.position = "top", legend.title = element_blank()) +
        guides(col = guide_legend(nrow = 4, byrow = TRUE)) + 
        ylim(-2.2, -0.3) +
        geom_line(aes(group = State)) + 
        geom_point() +
        stat_summary(fun.y = "mean", geom = "line", aes(group=1), size = 2.0, lty = 5) +
        labs(title = "Slope of Power Law Fit to Female Names Count Distributions")

## ----other-plot-power_law_fits_slope_M, fig.width = 7, fig.height = 7, echo = FALSE----
ggplot(powerlaw_fits, aes(x = Time, y = slopeM, color = factor(State))) + theme_bw() + 
        theme(legend.position = "top", legend.title = element_blank()) +
        guides(col = guide_legend(nrow = 4, byrow = TRUE)) + 
        ylim(-2.2, -0.3) +
        geom_line(aes(group = State)) + 
        geom_point() +
        stat_summary(fun.y = "mean", geom = "line", aes(group=1), size = 2.0, lty = 5) +
        labs(title = "Slope of Power Law Fit to Male Names Count Distributions")

## ----other-plot-power_law_fits_slope_delta, fig.width = 7, fig.height = 7, echo = FALSE----
ggplot(powerlaw_fits, aes(x = Time, y = slopeM-slopeF, color = factor(State))) + theme_bw() + 
        theme(legend.position = "top", legend.title = element_blank()) +
        guides(col = guide_legend(nrow = 4, byrow = TRUE)) + 
        ylim(-0.3, 0.9) +
        geom_line(aes(group = State)) + 
        geom_point() + 
        stat_summary(fun.y = "mean", geom = "line", aes(group=1), size = 2.0, lty = 5) +
        geom_abline(slope = 0, lty = 2, col = "grey40", size = 1) +
        labs(title = "Difference b/w Male and Female Power Law Slopes")

## ----R_session_info------------------------------------------------------
sessionInfo()

