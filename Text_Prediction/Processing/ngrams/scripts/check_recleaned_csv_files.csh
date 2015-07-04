#!/bin/tcsh -f 


if( $#argv != 1 ) then
    echo " Give one argument, the number corresponding to the source n-grams "
    echo "   check_recleaned_csv_files.csh 5 "
    exit "" 
endif

echo "--- 1-grams --- "
awk -F ";" '{print NF}' tmp_n1g_from_n$1g_recleaned.csv | sort -k 1n | uniq -c

echo "--- 2-grams --- "
awk -F ";" '{print NF}' tmp_n2g_from_n$1g_recleaned.csv | sort -k 1n | uniq -c

echo "--- 3-grams --- "
awk -F ";" '{print NF}' tmp_n3g_from_n$1g_recleaned.csv | sort -k 1n | uniq -c

echo "--- 4-grams --- "
awk -F ";" '{print NF}' tmp_n4g_from_n$1g_recleaned.csv | sort -k 1n | uniq -c

echo "--- 5-grams --- "
awk -F ";" '{print NF}' tmp_n5g_from_n$1g_recleaned.csv | sort -k 1n | uniq -c

echo "--- N-grams --- "
awk -F ";" '{print NF}' tmp_nNg_from_n$1g_recleaned.csv | sort -k 1n | uniq -c

