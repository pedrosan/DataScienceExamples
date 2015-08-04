#-------------------
library("shiny")

# padding/margin values are : top, right, bottom, left

shinyUI(fluidPage(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "my_style.css")
  ),

  # title = "myTextPredictR : Text Predictor",
  # titlePanel("myTextPredictR :<br /> a simple Text Predictor for the Coursera Data Science Capstone Project"),

  # div("", style = "padding: 10px 0px 0px 0px !important; width: 100%; "),

  wellPanel(
     fluidRow(
         column(7, offset = 2, 
            h2("myTextPredictR"),
            h4("A Text Prediction App for the Coursera Data Science Capstone Project")
        )
  )), 

#----

  wellPanel(
     fluidRow(
       column(7, offset = 2, 
          p(style = "padding: 0px 12px 0px 6px; font-size: large !important; color: #000000;",
               "The prediction is based on a", em("linear interpolation algorithm"), " using 3-/4-/5- grams.")
          , 
          # br(),
          p(style = "padding: 0px 12px 0px 6px; color: #333333;",
               "Slides providing a little additional information are posted at:", a("http://rpubs.com/PedroSan/myTextPredictr"))
          ,
          p(style = "padding: 0px 12px 0px 6px; color: #994444; font-style: slanted !important; ",
               "Please note that occasionally it is not blazingly fast, 
                and I have not found a way to give a sign of life while it processes.")
      )
  )),

#----

  wellPanel(
  fluidRow(
    column(7, offset = 2, 
      textInput("text_to_test", label = h3("Text Input > "), value = "There are signs of economic")
      #, 
      #submitButton("Try It")
      ,
      p(style = "padding: 0px 12px 0px 6px; margin-top: 12px; color: #000000;",
           "The output should appear here below as a list of top words according to a", em("metric"),
            "computed on the basis of", em("linear combination"), " of 3-/4-/5-grams: ")
    )
  )),

#----

  wellPanel(
  fluidRow(
    column(7, offset = 2, 
      htmlOutput("bestWord")
    )
  )), 

#----

  wellPanel(
  fluidRow(
    column(7, offset = 2, 
      p(style = "padding: 0px 12px 0px 6px; margin-top: 12px; color: #000000;",
           "Longer set of high-ranked words:")
      ,
      tableOutput("top5")
    )
  ))

) #--- closes fluidPage()
) #--- closes shinyUI()

