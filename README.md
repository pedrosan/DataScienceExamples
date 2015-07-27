# DataScienceExamples

Mix of projects showcasing some of data science work

A __report__ is available for some of them, hosted under pedrosan.github.io using the _pages_ feature.

* Bike Sharing Data Challenge:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Bike_Sharing/)
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Bike_Sharing)

* Baby Names Data Challenge:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Baby_Names/)
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Baby_Names)

* Data Challenge on Synthetic Data Set:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Synthetic_Data/)
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Synthetic_Data)

* Analysis of Human Activity Data:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Human_Activity_1/)
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Human_Activity_1)

* Machine-Learning-based Assessment of The Quality of Weight-lifting Exercises:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Human_Activity_2/)
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Human_Activity_2)

* Human and Economic Cost of Major Storm Events: An Analysis of the NOAA/NCDC Database:
  * [REPORT](http://pedrosan.github.io/DataScienceExamples/Impact_of_Major_Storm_Events/)
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Impact_of_Major_Storm_Events)

* Rent vs. Buy (simulation-based) calculator
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Rent_vs_Buy)

* Text Prediction Application
  * [repository](https://github.com/pedrosan/DataScienceExamples/tree/master/Text_Prediction)
  


### Note on the Reports' _Reproducible_ Format

The reports are generated from _Rmarkdown_ documents that include all code to perform
data processing, modeling, plotting, etc. (except for functions defined in external scripts, 
included in the repositories).

* For readability not all chunks of code are _echoed_ explicitly in the compiled documents.
* In some cases the _full straight reproducibility_ is limited by the fact that in the interest of simplicity
and for computational convenience some parts of the processing have been flagged as _inactive_ 
(`eval = FALSE`), and in some data are instead loaded from previously saved work (_e.g._ the model fitting). 
The document however include the code to perform the entire analysis.


