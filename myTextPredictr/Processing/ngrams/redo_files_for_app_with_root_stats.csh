#!/bin/tcsh -f 

#---------------------------------------------------------------------------------------------------
# OLD Normalizations (before "purification"):
#     5-grams : Ng >= 2  Nw >= 5  ====> N_pass^2 :  3950639  (1400948)
#     4-grams : Ng >= 4  Nw >= 5  ====> N_pass^2 :  6415960  ( 714674)
#     3-grams : Ng >= 4  Nw >= 5  ====> N_pass^2 : 25896184  (1899263)
#---------------------------------------------------------------------------------------------------
# Using files already filtered for Ng >= 2 and Nw >= 5
# NEW normalization are: 
#     5-grams : Ng >= 2  Nw >= 5  ====> N_pass^2 :  3950639  (1400948)
#     4-grams : Ng >= 4  Nw >= 5  ====> N_pass^2 :  2039390  ( 337618)
#               Ng >= 3  Nw >= 5  ====> N_pass^2 :  3180038  ( 717834)
#     3-grams : Ng >= 4  Nw >= 5  ====> N_pass^2 :  4545337  ( 755096)
#               Ng >= 3  Nw >= 5  ====> N_pass^2 :  6731428  (1483793)
#---------------------------------------------------------------------------------------------------
# awk -v min=3 'BEGIN{FS=";"}{if($3>=min){n++;s+=$3}}END{printf " %8d  (%8d)\n",s,n}' N4GRAMS_2_5_with_root_stats_PURE
#---

set      go_filter=0
set       go_print=0
set go_print_by_ID=1

#-----
  set ng5=2 ; set Norm5="3950639"  # 2, 5
#-----
# set ng4=4 ; set Norm4="2039390"  # 4, 5
  set ng4=3 ; set Norm4="3180038"  # 3, 5
#-----
# set ng3=4 ; set Norm3="4545337"  # 4, 5
  set ng3=3 ; set Norm3="6731428"  # 3, 5

set SCRIPT="check_ngrams_vs_dictionary_with_root_stats.pl"

if( $go_print ) then
  cat N5GRAMS_2_5_PURE_with_root_stats | ./scripts/$SCRIPT --min_ngra $ng5 --min_word 5 --normalization $Norm5 --save_to_file | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict;Nng;Nroot|;' > n5grams_Ng${ng5}_Nw5_purified.csv
  cat N4GRAMS_2_5_PURE_with_root_stats | ./scripts/$SCRIPT --min_ngra $ng4 --min_word 5 --normalization $Norm4 --save_to_file | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict;Nng;Nroot|;'    > n4grams_Ng${ng4}_Nw5_purified.csv
  cat N3GRAMS_2_5_PURE_with_root_stats | ./scripts/$SCRIPT --min_ngra $ng3 --min_word 5 --normalization $Norm3 --save_to_file | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict;Nng;Nroot|;'       > n3grams_Ng${ng3}_Nw5_purified.csv

  # gzip -9 n5grams_Ng${ng5}_Nw5_purified.csv
  # gzip -9 n4grams_Ng${ng4}_Nw5_purified.csv
  # gzip -9 n3grams_Ng${ng3}_Nw5_purified.csv
endif

if( $go_print_by_ID ) then
# cat N5GRAMS_2_5_PURE_with_root_stats | ./scripts/$SCRIPT --min_ngra $ng5 --min_word 5 --normalization $Norm5 --save_to_file --byID | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;ngFreq;logPdict;Nng;Nroot|;' > n5grams_Ng${ng5}_Nw5_purified_byID.csv
  cat N4GRAMS_2_5_PURE_with_root_stats | ./scripts/$SCRIPT --min_ngra $ng4 --min_word 5 --normalization $Norm4 --save_to_file --byID | perl -pe 's|^HEADER|w1;w2;w3;pred;ngFreq;logPdict;Nng;Nroot|;'    > n4grams_Ng${ng4}_Nw5_purified_byID.csv
  cat N3GRAMS_2_5_PURE_with_root_stats | ./scripts/$SCRIPT --min_ngra $ng3 --min_word 5 --normalization $Norm3 --save_to_file --byID | perl -pe 's|^HEADER|w1;w2;pred;ngFreq;logPdict;Nng;Nroot|;'       > n3grams_Ng${ng3}_Nw5_purified_byID.csv

  # gzip -9 n5grams_Ng${ng5}_Nw5_purified_byID.csv
  # gzip -9 n4grams_Ng${ng4}_Nw5_purified_byID.csv
  # gzip -9 n3grams_Ng${ng3}_Nw5_purified_byID.csv
endif

exit
################################################################################################################################################################
################################################################################################################################################################

# if( $go_filter ) then
#   cat N5GRAMS_2_5_with_root_stats      | ./scripts/$SCRIPT --min_ngra 2 --min_word 5 --save_filtered --normalization  3950639 > cleaned_n5grams_Ng2_Nw5.csv
#   cat N4GRAMS_2_5_with_root_stats_PURE | ./scripts/$SCRIPT --min_ngra 2 --min_word 5 --save_filtered --normalization 13840489 > cleaned_n4grams_Ng2_Nw5.csv
#   cat N3GRAMS_2_5_with_root_stats_PURE | ./scripts/$SCRIPT --min_ngra 2 --min_word 5 --save_filtered --normalization 36397645 > cleaned_n3grams_Ng2_Nw5.csv
# 
#   gzip -9 cleaned_n5grams_Ng2_Nw5.csv
#   gzip -9 cleaned_n4grams_Ng2_Nw5.csv
#   gzip -9 cleaned_n3grams_Ng2_Nw5.csv
# endif

exit
################################################################################################################################################################
################################################################################################################################################################


  gzip -dc cleaned_n5g_ge2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 2 -min_word 2 -save -normal  3959276 | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;logFreq;logP|;' > n5grams_ge2_dict2.csv
# gzip -dc cleaned_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal  8137903 | perl -pe 's|^HEADER|w1;w2;w3;pred;logFreq;logP|;'    > n4grams_ge3_dict2.csv
# gzip -dc cleaned_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 29181407 | perl -pe 's|^HEADER|w1;w2;pred;logFreq;logP|;'       > n3grams_ge3_dict2.csv

  gzip -dc cleaned_n5g_ge2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 2 -min_word 2 -save -normal  3959276 | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;logFreq;logP|;' > n5grams_ge2_dict2.csv
# gzip -dc cleaned_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal  8137903 | perl -pe 's|^HEADER|w1;w2;w3;pred;logFreq;logP|;'    > n4grams_ge3_dict2.csv
  gzip -dc cleaned_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal  6421003 | perl -pe 's|^HEADER|w1;w2;w3;pred;logFreq;logP|;'    > n4grams_ge4_dict2.csv
# gzip -dc cleaned_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 29181407 | perl -pe 's|^HEADER|w1;w2;pred;logFreq;logP|;'       > n3grams_ge3_dict2.csv
  gzip -dc cleaned_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 25921376 | perl -pe 's|^HEADER|w1;w2;pred;logFreq;logP|;'       > n3grams_ge4_dict2.csv
# gzip -dc cleaned_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 63974242 | perl -pe 's|^HEADER|w1;pred;logFreq;logP|;'          > n2grams_ge3_dict2.csv
# gzip -dc cleaned_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 61832095 | perl -pe 's|^HEADER|w1;pred;logFreq;logP|;'          > n2grams_ge4_dict2.csv

  gzip -9 n5grams_ge2_dict2.csv
# gzip -9 n4grams_ge3_dict2.csv
  gzip -9 n4grams_ge4_dict2.csv
# gzip -9 n3grams_ge3_dict2.csv
  gzip -9 n3grams_ge4_dict2.csv
# gzip -9 n2grams_ge3_dict2.csv
# gzip -9 n2grams_ge4_dict2.csv

  gzip -dc cleaned_n5g_ge2.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 2 -min_word 2 -save -normal  3959276 -byID | perl -pe 's|^HEADER|w1;w2;w3;w4;pred;logFreq;logP|;' > n5grams_ge2_dict2_byID.csv
# gzip -dc cleaned_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal  8137903 -byID | perl -pe 's|^HEADER|w1;w2;w3;pred;logFreq;logP|;'    > n4grams_ge3_dict2_byID.csv
  gzip -dc cleaned_n4g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal  6421003 -byID | perl -pe 's|^HEADER|w1;w2;w3;pred;logFreq;logP|;'    > n4grams_ge4_dict2_byID.csv
# gzip -dc cleaned_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 29181407 -byID | perl -pe 's|^HEADER|w1;w2;pred;logFreq;logP|;'       > n3grams_ge3_dict2_byID.csv
  gzip -dc cleaned_n3g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 25921376 -byID | perl -pe 's|^HEADER|w1;w2;pred;logFreq;logP|;'       > n3grams_ge4_dict2_byID.csv
# gzip -dc cleaned_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 3 -min_word 2 -save -normal 63974242 -byID | perl -pe 's|^HEADER|w1;pred;logFreq;logP|;'          > n2grams_ge3_dict2_byID.csv
# gzip -dc cleaned_n2g_ge3.csv.gz | ./scripts/check_ngrams_vs_dictionary.pl -min_ngra 4 -min_word 2 -save -normal 61832095 -byID | perl -pe 's|^HEADER|w1;pred;logFreq;logP|;'          > n2grams_ge4_dict2_byID.csv

  gzip -9 n5grams_ge2_dict2_byID.csv
# gzip -9 n4grams_ge3_dict2_byID.csv
  gzip -9 n4grams_ge4_dict2_byID.csv
# gzip -9 n3grams_ge3_dict2_byID.csv
  gzip -9 n3grams_ge4_dict2_byID.csv
# gzip -9 n2grams_ge3_dict2_byID.csv
# gzip -9 n2grams_ge4_dict2_byID.csv


