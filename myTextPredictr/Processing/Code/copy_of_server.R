#---------------------------------------------------------------------------------------------------
# LIBRARIES
#-------------------
library("shiny")
library("plyr")
library("dplyr")
library("hash")

#-------------------
# my functions
#-------------------
# source("scripts/my_functions.R")
source("scripts/my_functions_App_v1.R")
source("scripts/my_functions_App_v2.R")

#-------------------
# data
#-------------------

word_counts <- readRDS("./Application/data/wc_original.RDS")
word_counts <- readRDS("./Application/data/wc_best.RDS")
hash_wc <- hash(word_counts$word, word_counts$count)

#-----------------------
# TESTING READ OPTIONS 
#-----------------------
system.time({
    n3_orig <- readRDS("./Application/data/n3_gt2_words.RDS") %>% mutate(wall = paste(w1, w2, sep = " "))
    n4_orig <- readRDS("./Application/data/n4_gt2_words.RDS") %>% mutate(wall = paste(w1, w2, w3, sep = " "))
    n5_orig <- readRDS("./Application/data/n5_gt2_words.RDS") %>% mutate(wall = paste(w1, w2, w3, w4, sep = " "))
    n6_orig <- readRDS("./n6_words_50pct.RDS")                %>% mutate(wall = paste(w1, w2, w3, w4, w5, sep = " "))
})
rm(n3_orig, n4_orig, n5_orig, n6_orig)

#---------------------------------------

system.time({
    n3_sentences <- readRDS("./Application/data/n3_gt2_sentences.RDS")
    n4_sentences <- readRDS("./Application/data/n4_gt2_sentences.RDS")
    n5_sentences <- readRDS("./Application/data/n5_gt2_sentences.RDS")
    n6_sentences <- readRDS("./Application/data/n6_sentences_50pct.RDS")
})
rm(n3_sentences, n4_sentences, n5_sentences, n6_sentences)

#---------------------------------------------------------------------------------------------------
shinyServer(function(input, output, session) {

  # output$best <- renderPrint({ input$text_to_test })

  #-------------------------------------------------------------------------------
  # The expression is wrapped in a call to "reactive" and
  # therefore should be automatically re-executed when inputs change
  #
    prediction <- reactive( predict_engine(input$text_to_test, n3a, n4a, n5a, n6a, word_counts) )
  
    system.time( top10_v1 <- predict_engine_v1(input_text, n3_orig, n4_orig, n5_orig, n6_orig, hash_wc, debug = FALSE) )

    system.time( top10_v2 <- predict_engine_v2(input_text, n3_sentences, n4_sentences, n5_sentences, n6_sentences, hash_wc, debug = FALSE) )

  # prediction <- reactive({ predict_engine2(input$text_to_test) })
 
  # output$top10 <- renderPrint({ 
  #                     best <- prediction()
  #                     head(best, 5)
  #                         })
 
  output$best <- renderTable({ best <- prediction(); head(best, 5) })
 
  # output$top10 <- renderText({ input$text_to_test })

  # The expression is wrapped in a call to "renderPlot" and therefore
  # it is "reactive" and should be automatically re-executed when inputs change.
  
  # output$top10 <- renderPrint({ prediction() })
  # output$top10 <- ({ prediction() })

})
#---------------------------------------------------------------------------------------------------
