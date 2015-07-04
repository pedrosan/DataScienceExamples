#!/usr/bin/perl -w 
#
#---------------------------------------------------------------------------------------------------
# script to (re)score n-grams using information about word frequency from a dictionary
#  prepared from the sentences database (instead of n-grams themselves to avoid the 
#  problem of overcounting their occurrences, artificially inflated by the replication over
#  many partially overlapping n-grams).

use feature 'unicode_strings';  # CHECK THIS SETTING (http://perldoc.perl.org/perlunifaq.html)
use utf8;

# use Text::Unidecode;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

use Getopt::Long;
Getopt::Long::Configure('no_ignore_case');

$debug=0;
$debug2=0;
$min_ngram_freq=2;
$min_word_count=2;
$flag_quick_check=0;
$skip_this=0;
GetOptions ('d|debug' => \$debug, 
            'min_ngram_freq=i'  => \$min_ngram_freq,
            'min_word_count=i'  => \$min_word_count,
            'quick_check'       => \$flag_quick_check,
            'd2|debug2' => \$debug2 );

if( $flag_quick_check ) { $skip_this = 1; }
# keys(%dict) = 267992;
keys(%ID) = 537968;
keys(%flag) = 537968;
keys(%counts) = 537968;

if( $debug ) {
    print "# min ngram freq = $min_ngram_freq\n";
    print "# min word  cnt  = $min_word_count\n";
}

# open(WCFILE,"./wc_new.csv");
open(WCFILE,"./dictionary_for_hash.csv");
binmode WCFILE, ':encoding(UTF-8)';

# Number of words in sentences
# $N_words_in_corpus=93817226;

$Ndict=0;
while (<WCFILE>){
    chomp;
    ($id, $flag, $count, $word) = parse_csv($_);
    
    # Using a reduced dictionary:
    #   - only "OK" words
    #   - count >= min_word_count
    if( $flag !~ "OK" ) { next; }
    if( $count < $min_word_count ) { next; }
    $Ndict++;
    $ID{"$word"} = $id;
    $flag{"$word"} = $flag;
    $counts{"$word"} = $count;
}
close(WCFILE);

if( $debug ) {
    print "# loaded dictionary contains $Ndict words\n";
}

$N_tested=0;
$N_tested_cumul=0;
$N_pass2_cumul=0;
while (<STDIN>) {

    $N_tested++;

    chomp;
    @words = split(/;/);
    $freq = shift(@words);
    $pred = pop(@words);

    $N_tested_cumul+=$freq;

    if( $freq < $min_ngram_freq ) { 
        if( $debug ) { print "# Hit minimum frequency threshold, quitting\n"; }
        last; 
    }
    
    $N_good = 0;
    $N_in_dict = 0;
    $i = -1;
    #@cts = ( 0, 0, 0, 0, 0);
    #@flags = ( "__", "__", "__", "__", "__");
    @cts = ( 0, 0, 0, 0);
    @flags = ( "__", "__", "__", "__");

    foreach $w ( @words ) {
        $i++;

        # word is 'good' if long enough
        if( length($w) >= 1 ) {

            # check if known in the dictionary
            if( defined $counts{"$w"} ) {
                $N_in_dict++;

                $id[$i] = $ID{"$w"};
                $cts[$i] = $counts{"$w"};
                $flags[$i] = $flag{"$w"};

                if( $flag{"$w"} =~ "OK" ) {
                    $N_good++;
                }
            }
        }
    }

    if( defined $ID{"$pred"} ) { 
        $summary_Could_Predict++;
        # $summary_Could_Predict_by_Ngood{"$N_good"}++;
        $summary_Could_Predict_by_Ndict{"$N_in_dict"}++;
        $N_pass2_cumul+=$freq;
    }

    # $summary_N_good{"$N_good"}++;
    $summary_N_in_dict{"$N_in_dict"}++;

}

print  "--------------------------------------------------------------------------------------\n";
printf " min word count    = %8d / N_words  = %8d\n", $min_word_count, $Ndict;
printf " min N-grams count = %8d / N_ngrams = %8d / 'pred' = %6d (%5.2f %%)\n", $min_ngram_freq, $N_tested, $summary_Could_Predict,100.0*$summary_Could_Predict/$N_tested;
printf " N-grams cumul     = %8d / pass^2   = %8d (%7.3f %%)\n", $N_tested_cumul, $N_pass2_cumul,  100.0*$N_pass2_cumul/$N_tested_cumul;
print  "\n";

# print "--------------------------------------------------------------------------------------\n";
# printf " N-grams tested  = %8d  /  'pred' in dict = %6d (%5.2f %%)\n", $N_tested, $summary_Could_Predict,100.0*$summary_Could_Predict/$N_tested;
# printf " Words included  = %8d\n", $Ndict;
# print "\n";

# printf " Predicted word is in dictionary = %6d (%5.2f %% of n-grams)\n",$summary_Could_Predict,100.0*$summary_Could_Predict/$N_tested;
# print "\n";
# print " Number of good words\n";
# foreach $k ( sort keys %summary_N_good ) {
#     printf "   %d ==> %8d  (%5.2f %%)", $k, $summary_N_good{"$k"}, 100.0*$summary_N_good{"$k"}/$N_tested;
#     printf "     could predict in :  %8d (%5.2f %%)", $summary_Could_Predict_by_Ngood{"$k"}, 100.0*$summary_Could_Predict_by_Ngood{"$k"}/$summary_N_good{"$k"};
#     printf "\n";
#     #print " $k ==> " . $summary_N_good{"$k"}. "\n";
# }
# print "\n";

$N_in_dict_cumul=0;
$N_predict_cumul=0;
print " Stats by number of words in dictionary\n";
foreach $k ( sort { $b <=> $a } keys %summary_N_in_dict ) {
    $N_in_dict_cumul+=$summary_N_in_dict{"$k"};
    $N_predict_cumul+=$summary_Could_Predict_by_Ndict{"$k"};
    printf "   %d ==> %8d  (%5.2f %% / %6.2f %%)", $k, $summary_N_in_dict{"$k"}, 100.0*$summary_N_in_dict{"$k"}/$N_tested, 100.0*$N_in_dict_cumul/$N_tested;
    printf "   'pred' : %8d (%5.2f %% / %6.2f %%)", $summary_Could_Predict_by_Ndict{"$k"}, 100.0*$summary_Could_Predict_by_Ndict{"$k"}/$N_tested, 100.0*$N_predict_cumul/$N_tested;
   #printf "   'pred' : %8d (%6.2f %%)", $summary_Could_Predict_by_Ndict{"$k"}, 100.0*$summary_Could_Predict_by_Ndict{"$k"}/$summary_N_in_dict{"$k"};
    printf "\n";
    # print " $k ==> " . $summary_N_in_dict{"$k"}. "\n";
}
print  "\n";
# print "--------------------------------------------------------------------------------------\n";

exit; 

#---------------------------------------------------------------------------------------------------
sub parse_csv {
   
   my $text = shift;
   my @new= ();
   push(@new,$+) while $text =~ m{"([^\"\\]*(?:\\.[^\"\\]*)*)",?|  ([^,]+),?| ,}gx;
   push(@new,undef) if substr($text,-1,1) eq ',';
   return @new;

}
#---------------------------------------------------------------------------------------------------
