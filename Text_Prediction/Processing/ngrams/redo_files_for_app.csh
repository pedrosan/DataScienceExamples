#!/bin/tcsh -f 

# 5-grams : Ng >= 2  Nw >= 2  ====> N_pass^2 :  3955217  (1404638)
#           Ng >= 2  Nw >= 3  ====> N_pass^2 :  3953414
#           Ng >= 2  Nw >= 5  ====> N_pass^2 :  3950639
#
# 4-grams : Ng >= 2  Nw >= 2  ====> N_pass^2 : 13857439  (4158915)
#           Ng >= 2  Nw >= 3  ====> N_pass^2 : 13850469
#           Ng >= 2  Nw >= 5  ====> N_pass^2 : 13840489 
#
# 3-grams : Ng >= 2  Nw >= 2  ====> N_pass^2 : 36424192  (6634804)
#           Ng >= 2  Nw >= 3  ====> N_pass^2 : 36413557 
#           Ng >= 2  Nw >= 5  ====> N_pass^2 : 36397645

set go_filter=0
set go_print=0
set go_print_by_ID=1

if( $go_filter ) then
  gzip -dc clean_n5grams_Ng2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 2 --min_word 5 --save_filtered --normalization  3950639 > clean_n5grams_Ng2_Nw5.csv
  gzip -dc clean_n4grams_Ng2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 2 --min_word 5 --save_filtered --normalization 13840489 > clean_n4grams_Ng2_Nw5.csv
  gzip -dc clean_n3grams_Ng2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 2 --min_word 5 --save_filtered --normalization 36397645 > clean_n3grams_Ng2_Nw5.csv

  gzip -9 clean_n5grams_Ng2_Nw5.csv
  gzip -9 clean_n4grams_Ng2_Nw5.csv
  gzip -9 clean_n3grams_Ng2_Nw5.csv
endif

# 5-grams : Ng >= 2  Nw >= 5  ====> N_pass^2 :  3950639  (1400948)
#           Ng >= 3  Nw >= 5  ====> N_pass^2 :  1891125  ( 371191)
# 4-grams : Ng >= 4  Nw >= 5  ====> N_pass^2 :  6415960  ( 714674)
# 3-grams : Ng >= 4  Nw >= 5  ====> N_pass^2 : 25896184  (1899263)

if( $go_print ) then
  gzip -dc clean_n5grams_Ng2_Nw5.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 2 --min_word 5 --save_to_file --normalization  3950639 | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict|;' > n5grams_Ng2_Nw5.csv
  gzip -dc clean_n4grams_Ng2_Nw5.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 4 --min_word 5 --save_to_file --normalization  6415960 | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_Ng4_Nw5.csv
  gzip -dc clean_n3grams_Ng2_Nw5.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 4 --min_word 5 --save_to_file --normalization 25896184 | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_Ng4_Nw5.csv

  gzip -9 n5grams_Ng2_Nw5.csv
  gzip -9 n4grams_Ng4_Nw5.csv
  gzip -9 n3grams_Ng4_Nw5.csv
endif

if( $go_print_by_ID ) then
  gzip -dc clean_n5grams_Ng2_Nw5.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 2 --min_word 5 --save_to_file --normalization  3950639 --byID | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict|;' > n5grams_Ng2_Nw5_byID.csv
  gzip -dc clean_n4grams_Ng2_Nw5.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 4 --min_word 5 --save_to_file --normalization  6415960 --byID | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_Ng4_Nw5_byID.csv
  gzip -dc clean_n3grams_Ng2_Nw5.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl --min_ngra 4 --min_word 5 --save_to_file --normalization 25896184 --byID | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_Ng4_Nw5_byID.csv

  gzip -9 n5grams_Ng2_Nw5_byID.csv
  gzip -9 n4grams_Ng4_Nw5_byID.csv
  gzip -9 n3grams_Ng4_Nw5_byID.csv
endif


exit
################################################################################################################################################################
################################################################################################################################################################


  gzip -dc clean_n5g_ge2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 2 -min_word 2 -save -normal  3959276 | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict|;' > n5grams_ge2_dict2.csv
# gzip -dc clean_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal  8137903 | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_ge3_dict2.csv
# gzip -dc clean_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 29181407 | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_ge3_dict2.csv

  gzip -dc clean_n5g_ge2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 2 -min_word 2 -save -normal  3959276 | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict|;' > n5grams_ge2_dict2.csv
# gzip -dc clean_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal  8137903 | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_ge3_dict2.csv
  gzip -dc clean_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal  6421003 | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_ge4_dict2.csv
# gzip -dc clean_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 29181407 | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_ge3_dict2.csv
  gzip -dc clean_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 25921376 | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_ge4_dict2.csv
# gzip -dc clean_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 63974242 | perl -pe 's|^HEADER|w1;pred;ngFreq;logPdict|;'          > n2grams_ge3_dict2.csv
# gzip -dc clean_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 61832095 | perl -pe 's|^HEADER|w1;pred;ngFreq;logPdict|;'          > n2grams_ge4_dict2.csv

  gzip -9 n5grams_ge2_dict2.csv
# gzip -9 n4grams_ge3_dict2.csv
  gzip -9 n4grams_ge4_dict2.csv
# gzip -9 n3grams_ge3_dict2.csv
  gzip -9 n3grams_ge4_dict2.csv
# gzip -9 n2grams_ge3_dict2.csv
# gzip -9 n2grams_ge4_dict2.csv

  gzip -dc clean_n5g_ge2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 2 -min_word 2 -save -normal  3959276 -byID | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict|;' > n5grams_ge2_dict2_byID.csv
# gzip -dc clean_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal  8137903 -byID | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_ge3_dict2_byID.csv
  gzip -dc clean_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal  6421003 -byID | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict|;'    > n4grams_ge4_dict2_byID.csv
# gzip -dc clean_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 29181407 -byID | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_ge3_dict2_byID.csv
  gzip -dc clean_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 25921376 -byID | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict|;'       > n3grams_ge4_dict2_byID.csv
# gzip -dc clean_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 63974242 -byID | perl -pe 's|^HEADER|w1;pred;ngFreq;logPdict|;'          > n2grams_ge3_dict2_byID.csv
# gzip -dc clean_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 61832095 -byID | perl -pe 's|^HEADER|w1;pred;ngFreq;logPdict|;'          > n2grams_ge4_dict2_byID.csv

  gzip -9 n5grams_ge2_dict2_byID.csv
# gzip -9 n4grams_ge3_dict2_byID.csv
  gzip -9 n4grams_ge4_dict2_byID.csv
# gzip -9 n3grams_ge3_dict2_byID.csv
  gzip -9 n3grams_ge4_dict2_byID.csv
# gzip -9 n2grams_ge3_dict2_byID.csv
# gzip -9 n2grams_ge4_dict2_byID.csv


