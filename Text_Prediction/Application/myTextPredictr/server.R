#---------------------------------------------------------------------------------------------------
# LIBRARIES
#-------------------
library("shiny")
library("dplyr")
library("magrittr")
library("stringr")

#-------------------
# data
#-------------------
dict <- readRDS(file = "./data/dict_Nw5_OK.RDS")
n3g  <- readRDS(file = "./data/n3grams_Ng4_Nw5_pure_byID.RDS")
n4g  <- readRDS(file = "./data/n4grams_Ng4_Nw5_pure_byID.RDS")
n5g  <- readRDS(file = "./data/n5grams_Ng2_Nw5_pure_byID.RDS")

#-------------------
# my functions
#-------------------
source("scripts/my_functions.R")

vec_words  <- vector(mode = "character", length = nrow(dict))
vec_counts <- vector(mode = "integer", length = nrow(dict))
vec_words[dict$ID] <- dict$word
vec_counts[dict$ID] <- dict$count
dict_size <- sum(dict$count)

n3g_norm <- sum(n3g$ngFreq)
n4g_norm <- sum(n4g$ngFreq)
n5g_norm <- sum(n5g$ngFreq)
n3g <- mutate(n3g, logPng = -1.0*log10(ngFreq/n3g_norm))
n4g <- mutate(n4g, logPng = -1.0*log10(ngFreq/n4g_norm))
n5g <- mutate(n5g, logPng = -1.0*log10(ngFreq/n5g_norm))

#---------------------------------------------------------------------------------------------------
# shinyServer(function(input, output, session) {
shinyServer(function(input, output) {

    #-------------------------------------------------------------------------------
    prediction <- reactive( predict_engine(input$text_to_test, n3g, n4g, n5g, dict, vec_words, vec_counts, how_many = 5, debug = FALSE) )

    # output$debug1 <- renderText({ 
    #                     out_nrow <- nrow(prediction())
    #                     paste0("nrows : ", out_nrow);
    #                 })

    # output$debug2 <- renderText({ 
    #                     out <- str(prediction())
    #                     out_structure <- str(out)
    #                     paste0("structure : ", out_structure);
    #                 })

    output$top5 <- renderTable({ prediction() })
    
    output$bestWord <- renderText({ 
                        bestW <- prediction()$prediction[1];
                        oText <- paste0("<p style='color: #006600;'>Top ranked suggestion is : <span class='best_word'>", bestW, "</span></p>"); 
                        return(oText);
                    })
 
})
#---------------------------------------------------------------------------------------------------
