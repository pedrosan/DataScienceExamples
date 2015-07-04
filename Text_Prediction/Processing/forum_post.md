Lots of good stuff in this thread... no time to keep up, and even less to review and learn... damn!
I am a bit self-conscious about my app, but I think it would be worth sharing some info about it and I'll try to carve out some time.  
For now I will just say that I did a lot of my pre-processing with `perl`. 

* I cleaned the most pathological issues of the text in `perl` before feeding it to `R`.  
* In `perl` I did some more useful regex parsing to catch things like emoticon, hashtags, abbreviations, number-related pieces, profanities (I learned an awful lot more than I thought it would be possible on regex!!!  I confess I did not know about the lookahead/lookbehind magic)
* In `R` I tokenize it into sentences (with NLP::annotate), because it seemed to improve n-gram tokenization, but in terms of speed and quality.
* In `perl` I did another pass at cleaning the sentences.
* With cleaned sentences, back to `R` for n-gram tokenization, 2/3/4/5-grams (did not use 2-grams.)
* Back to `perl` for validation of the n-grams.  If it seems like a lot of back and forth... in good part it is because
some issues became more visible (literally speaking) after each tokenization.
* In `perl` I extracted a census of words from the sentences (I would cal that a _dictionary_).  At first I was doing this from
the n-grams until it dawned on me that it was overcounting words because of the shifting-window nature of n-grams.
* I handled the census of n-grams with good old command line!  Pretty much piping into `sort` to `uniq -c` to `sort -k 1nr` and
finally for formatting (n-grams were ";" separated words, and the above pipe leaves space separated count and string) an easy
`awk`.  Final table was something like this:
```
881;thanks;for;the;shout;out
767;for;the;first;time;since
619;let;me;know;if;you
606;thank;you;for;the;follow
541;i;thought;it;would;be
419;this;is;the;first;time
385;let;me;know;what;you
```
It was faster (not-slower) than doing this in R. with the gained convenience of infinitely easier "access" to files for inspection
and such.

More `perl` for a couple more "advanced" operations:
* Rejecting n-grams containing words not occurring at a minimum number of times in the dictionary. 
In the end I cut at 5, leaving 126,000 words in the dictionary (out of > 400,000) but accounting for 99.5% 
of the coverage.
* Making a census of n-gram "roots" (i.e. the first 4 words in a 5-gram), which I used (sort of) in the prediction 
  process.  Kind of like using the probability (frequency) of a word in a corpus as a discounting factor.
* This also gives relative frequencies of 5-th word for a given "root", also potentially useful/usable information.
The new 5-gram table looks like this now:
```
921;4;881;thanks;for;the;shout;out
4325;243;767;for;the;first;time;since
1257;37;619;let;me;know;if;you
2384;196;606;thank;you;for;the;follow
620;18;541;i;thought;it;would;be
735;58;419;this;is;the;first;time
540;28;385;let;me;know;what;you
```
* First column is the total number of times the 4-subgram appears in the 5-grams set
* Second colum is how many different 5-grams have that 4-subgram as their root.
* Third column is the count of this particular 5-gram.
For this particular "root" for instance these are its 5-grams.
```
921;4;881;thanks;for;the;shout;out
921;4;36;thanks;for;the;shout;outs
921;4;2;thanks;for;the;shout;last
921;4;2;thanks;for;the;shout;buddy
```

For efficiency I also (again in `perl`) checked 3-grams agains 4- and 5-grams to keep only the 3-grams that 
were not contained in those higher order sets. Same for 4-grams against 5-grams.  This decreased the size
of the 3-grams and 4-grams data sets significantly:
* for n-grams occurring at least 2 times: 3-grams went from 6.6M to 4.1M, 4-grams from 4.2M to 2.9M,
* for n-grams occurring at least 4 times: 3-grams went from 1.9M to 0.75M, 4-grams from 700k to 337M.

I also cut 3- and 4-grams at a minimum count of 4, and 5-grams at 2.
With these cuts, the final tally was 755k 3-grams, 337K 4-grams, 1.4M 5-grams.

I coded words as numbers, and look these up in the dictionary.  
In the end I did not rely on hashes for this because it did not quite provide such a spectacular
performance improvement over more mundane arrays.  I split the dictionary data frame (ID, word, count)
in two vectors for word and counts indexed on the ID (the fact that some ID were not used because
I dropped some words is not really a huge waste of memory, these are very small arrays).
Getting ID from words by a plain `dict$word == "text"`, and then count as `count[ID]` is fast enough.
Moreover, creating this couple of arrays from the data frame turned out to be massively quicker
than creating the hash, pretty much non-measureable compared to few seconds.  Not worth the hassle
especially considering that the delay in creating the hash when the application start can be annoying.

I'll stop here... end of lunch break.
I might come back to illustrate the prediction algorithm based on these data.  
I was satisfied by its performance, both for speed and accuracy, but not too happy about the latter because it
tends to give higher priority to short words.  One easy improvement would be to increase the weight of
"full n-gram matches" when they exist, because right now they can be diluted by the results of sub-n-gram matches.

My slides are at http://rpubs.com/PedroSan/myTextPredictr (app URL in on them).

Best,

Giovanni

