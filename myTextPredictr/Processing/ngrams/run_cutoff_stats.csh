#/bin/tcsh -f 


set min_ng = (  3  3  3  3  3  4  4  4  4  4 )
set min_nw = (  2  3  5 10 20  2  3  5 10 20 )

set min_ng = (  2  2  2  2  2  )
set min_nw = (  2  3  5 10 20  )

set order=3

foreach i (` seq 1 $#min_ng `)
  set n1=$min_ng[$i]
  set n2=$min_nw[$i]
  gzip -dc cleaned_n${order}g_ALL_sorted.csv.gz | ./scripts/quick_check_ngrams_vs_dictionary.pl -min_ngram $n1 -min_word $n2
end



