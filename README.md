# Data Science 

Mix of projects showcasing some of data science work

A __report__ is available for some of them, hosted under pedrosan.github.io using the _pages_ feature.

* Rent vs. Buy (simulation-based) Calculator
  * [The Calculator on _shinyapps.io](https://pedrosan.shinyapps.io/AdvBvsR/)
  * [Introduction and general information](http://pedrosan.github.io/DataScience/Rent_vs_Buy/intro.html)
  * [Analysis of stock market returns](http://pedrosan.github.io/DataScience/Rent_vs_Buy/returns.html) 
    (indices) to get a handle on how to include them in the _calculator_.
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Rent_vs_Buy)

* Bike Sharing Data: 
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Bike_Sharing/)
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Bike_Sharing)

* Baby Names Data:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Baby_Names/)
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Baby_Names)

* Synthetic Data Set (challenge):
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Synthetic_Data/)
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Synthetic_Data)

* Analysis of Human Activity Data: Steps History and Patterns
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Human_Activity_1/)
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Human_Activity_1)

* ML-based Assessment of the Quality of Weight-lifting Exercises:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Weight_Lifting/)
  * [REPORT (alt)](http://pedrosan.github.io/DataScience/Weight_Lifting/)
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Weight_Lifting)

* Human and Economic Cost of Major Storm Events: An Analysis of the NOAA/NCDC Database:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Impact_of_Major_Storm_Events/)
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Impact_of_Major_Storm_Events)

* Text Prediction Application
  * [Repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Text_Prediction)
  * [Progress Report](http://pedrosan.github.io/DataScienceExamples/Text_Prediction/MilestoneReport/)
  * ["pitch" slides](http://pedrosan.github.io/DataScienceExamples/Text_Prediction/Application/Slides/)
  

### Note on the Reports' _Reproducible_ Format

The reports are generated from _Rmarkdown_ documents that include all code to perform
data processing, modeling, plotting, etc. (except for functions defined in external scripts, 
included in the repositories).

* For readability not all chunks of code are _echoed_ explicitly in the compiled documents.
* In some cases the _full straight reproducibility_ is limited by the fact that in the interest of simplicity
and for computational convenience some parts of the processing have been flagged as _inactive_ 
(`eval = FALSE`), and in some data are instead loaded from previously saved work (_e.g._ the model fitting). 
The document however include the code to perform the entire analysis.


