#!/bin/tcsh -f 

set RAW_DATA_DIR="/home/gfossati/Learning/Coursera/Specialization/Capstone_Project/data/raw"

set name="news"
set name="twitter"
set name="blogs"

set pass1name="${name}_pass1_from_ORIG_official"
set pass2name="${name}_pass2_from_pass1_from_ORIG_official"
set pass3name="${name}_pass3_from_pass2_from_pass1_from_ORIG_official"
set pass4name="${name}_pass4_from_pass3_from_pass2_from_pass1_from_ORIG_official-emptied_TAGS"

echo "=== "`date`" : starting pass 1"
gzip -dc $RAW_DATA_DIR/en_US.${name}.ORIGINAL.txt.gz | ../regularize_text_pass1_v3.pl > $pass1name

echo "=== "`date`" : starting pass 2"
cat $pass1name | ../regularize_text_pass2_v3.pl > $pass2name

echo "=== "`date`" : starting pass 3"
cat $pass2name | ../regularize_text_pass3_v3.pl > $pass3name

echo "=== "`date`" : starting pass 4"
cat $pass3name | ../regularize_text_pass4_v3.pl | ../remove_tags_content.pl > $pass4name

