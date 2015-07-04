Text Prediction Challenge
===
author: Giovanni Fossati
date: April 26 2015
transition: rotate
css: styling.css

Rice University   
Astrophysicist   

<div style="color: #EEDD00;">
The application is deployed at : <a href="https://pedrosan.shinyapps.io/myTextPredictr/">this URL</a>
</div>


The Challenge
===

- The goal of the project was to develop an application able to produce sensible prediction for the words following a short submitted text.
- As a playground a fairly substantial dataset was made available, comprising text from
various heterogenous sources (blogs, news, twitter).
Despite its size, it did not take much to appreciate that the dataset could at
best give a rough guidance.
- I decided to invest a significant amount of time to explore the data, and delved deeply (perhaps
too much) into the cleaning of the _corpus_, making the assumption that
the effort would have paid off by making any algorithm more robust.
- What you will see probably is not the most inspired and smartest application, but under the hood
I put a substantial amount of thinking about language processing and the algorithm.
- __Performance issues__: it is worth mentioning that one of the main challenges has been
dealing smartly with the computational load, that turned out to be a serious limiting factor,
even on a powerful workstation.
    - I did not use the `tm` suite.  Too heavy and cumbersome.
    - Instead I heavily on `perl` and in `R` mainly `dplyr`, `NLP` and `RWeka`.
    - Most of the work was done with `perl` "offline" (can't beat it for `regex` work).    
    To match the application input with the data on which the application is built, all operations 
    were ported to `R` either directly or by relying on an external perl script.   


Data Processing
===

As noted I put a major effort into understanding the idiosyncrasies of the textual data, with the
expectation that a deep cleaning would truly make a difference in the prediction context.
- One example of what I had in mind is that the predictive capability of any algorithm would 
  be strengthened by transforming to categorical generic "tag" frequent "items" with a lot of 
  variations but broadly similar meaning (e.g. dates, money, possessive pronouns).   
  
Among the main transformations applied to the text:
- __Contractions__ (_e.g._ don't, isn't, I'll): this seem to be more commonly regarded as 
      stopword, hence removed.  My take has been that they can provide meaning and it was worth 
      preserving them, as well as they non-contracted counterparts.  I homogeneized all 
      of them in forms like "I_will", "do_not", with an underscore gluing them together.
- __Possessive pronouns__: As noted I worked under the assumption that they can be predictive instead
of being a nuisance, even more so if considered as a "category". 
I implemented a replaced-and-tag approach to them as well.
- __Profanity filtering__: I based my cleaning on the "7 dirt words", and some words rooted on them.
    + To preserve their potential predictive value, I replace them with a tag `<PROFANITY>`.
    + User input is also filtered, but the information carried by a possible profanity can be used.
- __Emoticons__: Recognized them with regex.  Marked with a tag, `<EMOJ>`.
- __#hashtags__: also picked out of the text with regex and replaced with a generic `<HASHTAG>`.
    

About The Algorithm
===
My final algorithm is basically a _linear interpolation of 3-/4-/5-grams_.
- Data are loaded in form of separate data frames for 3-,4-,5- grams.  
    - Words are stored as numeric keys resolved by an accompanying dictionary.
    - Testing showed that this yields a substantial speed improvement. 
- The _input text_ is cleaned with the same procedures applied to the Corpus 
  (passing through an external `perl` script).
- The _input text_ is checked against n-gram of different order using the words numeric IDs (i.e. a very literal matching).
    - Originally I tried an approach based on loser matching with `agrep`. 
      It was great, but extremely computationally expensive. 
    - My tests suggests that the quality of overall matches is noticeably improved by also testing 
      combinations of the words in the n-gram and/or input text resulting from some shuffling and skipping: 
        - E.g. for 4 words also search/compare 2-3-4, 1-3-4, 1-2-4, 1-2-3 subsets.
- For further processing I only use the union of the n-grams of different order passing a rejection threshold 
that takes into account for instance:
    - the number of word matches,  
    - the location of the matches in the n-grams/input text, 
    - the naive likelihood of n-grams and predicted words based on their general frequency.
    - Internally the a loop adjusts the rejection threshold of aiming at a 20-100 matches.

More About The Algorithm
===
- With this more manageable dataset I refine the search and score predictions in different ways:
    - Use `agrep` to evaluate the closeness of n-grams to the input text.
    - Various _likelihood_-related metrics such as those mentioned above, for instance 
      comparing the occurrence of a word or n-gram in the working set with what expected from
      statistics on the general corpus.
- The matches, _i.e._ predicted _next-word_, obtained from the n-grams and their several 
  shuffled/skipped versions, are then combined, taking into account several weighting factors 
  considering for instance:
    - the order of the matching n-gram (higher for 5-grams than for 3-grams).
    - kind of _skipping/shuffling_ of words.
    - frequency of the prediction candidate in the dictionary.
    - frequency of matching (n-1) grams among the "dictionary" of n-gram roots.
- This effectively corresponds to a linear combination of the data.
- I only did some informal testing of how changing the weights and the shuffling affected
the results, a "poor-man" training/testing protocol, and settled on some values that
seemed to yield acceptable results (which is far from meaning that it predicts with
great "accuracy" or good sense...)

__I hope it will work well once deployed and that you will enjoy it__ (and I wish I had more space to illustrate the technical details.)



        

