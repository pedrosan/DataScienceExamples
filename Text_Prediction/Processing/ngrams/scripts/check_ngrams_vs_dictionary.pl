#!/usr/bin/perl -w 

#---------------------------------------------------------------------------------------------------
# script to (re)score n-grams using information about word frequency from a dictionary
#  prepared from the sentences database (instead of n-grams themselves to avoid the 
#  problem of overcounting their occurrences, artificially inflated by the replication over
#  many partially overlapping n-grams).
#
# It prints only n-grams whose 'pred' is included in the reduced dictionary.
#---------------------------------------------------------------------------------------------------

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
$flag_save_to_file=0;
$flag_save_filtered_ngrams=0;
$ngram_normalization=1;
$skip_this=0;
$flag_by_ID=0;

GetOptions ('d|debug' => \$debug, 
            'min_ngram_freq=i'  => \$min_ngram_freq,
            'min_word_count=i'  => \$min_word_count,
            'normalization=i'   => \$ngram_normalization,
            'save_to_file'      => \$flag_save_to_file,
            'save_filtered'     => \$flag_save_filtered_ngrams,
            'byID'              => \$flag_by_ID,
            'd2|debug2' => \$debug2 );

if( $flag_save_to_file ) { $skip_this = 1; }
if( $flag_save_filtered_ngrams ) { $skip_this = 1; }

# keys(%dict) = 267992;
# keys(%ID) = 537968;
# keys(%flag) = 537968;
# keys(%counts) = 537968;

if( $debug ) {
    print "# min ngram freq = $min_ngram_freq\n";
    print "# min word  cnt  = $min_word_count\n";
}

# Number of words in sentences
# $N_words_in_corpus=93817226;
# This can actually be computed when reading the dictionary... see BELOW

#-------------------------------------------------
open(WCFILE,"./dictionary_for_hash.csv");
binmode WCFILE, ':encoding(UTF-8)';

$outDictFile="reduced_Dictionary_Nw" . $min_word_count . "_flag_OK.csv";
open(REDUCED_DICT,"> $outDictFile" ) || die "could not open file $outDictFile\n";
binmode REDUCED_DICT, ':encoding(UTF-8)';

$Ndict=0;
$Ndict_cumul=0;
while (<WCFILE>){
    chomp;
    ($id, $flag, $count, $word) = parse_csv($_);
    # print " word : $word ==> $count \n";
    if( $flag !~ "OK" ) { next; }
    if( $count < $min_word_count ) { next; }
    $Ndict++;
    $Ndict_cumul+=$count;
    $ID{"$word"} = $id;
    $flag{"$word"} = $flag;
    $counts{"$word"} = $count;
    print REDUCED_DICT "$_\n";
}
close(WCFILE);
close(REDUCED_DICT);
#-------------------------------------------------
# exit;

$N_words_in_corpus=$Ndict_cumul;

if( $debug ) {
    print "# loaded dictionary contains $Ndict unique words\n";
    print "# loaded dictionary contains $Ndict_cumul words\n";
}

# exit;

# if( $debug ) {  
#     foreach $w ( sort keys %counts ) {
#         print " $w ==> " . $counts{"$w"}. "\n";
#     }
# }

# print "w1;w2;w3;w4;pred;logFreq;logP\n";
if( $flag_save_to_file ) { print "HEADER\n"; }

while (<STDIN>) {

    chomp;
    if( $debug ) {  
        print "I:                                $_\n";
    } 

    #$N = chop($_);
    #s| +$||g;

    @words = split(/;/);
    $freq = shift(@words);
    $pred = pop(@words);

    if( $debug ) {
    if( ! defined $ID{"$pred"} ) {
        print "# predicted word does not have an entry in the dictionary\n";
    } else {
        if( $flag{"$pred"} !~ "OK" ) {
            print "# predicted word is bad quality\n";
        }
    }
    }

    if( $debug ) { print "$freq $pred\n"; }

    if( $freq < $min_ngram_freq ) { 
        if( $debug ) { print "# Hit minimum frequency threshold, quitting\n"; }
        last; 
    }
    
    $lg_freq = -0.4343*log($freq/$ngram_normalization);

    $lgPdict = 0;
    # $prod = 1;
    $N_good = 0;
    $N_in_dict = 0;
    $i = -1;
    #@cts = ( 0, 0, 0, 0, 0);
    #@flags = ( "__", "__", "__", "__", "__");
    #@id = ( 0, 0, 0, 0);
    @cts = ( 0, 0, 0, 0);
    @flags = ( "__", "__", "__", "__");

    foreach $w ( @words ) {
        $i++;

        # word is 'good' if long enough
        if( length($w) >= 1 ) {
            # $N_good++;

            # check if known in the dictionary
            if( defined $counts{"$w"} ) {
                if( $debug2 ) { print "        $w = $counts{$w}\n"; }

                $id[$i] = $ID{"$w"};
                $cts[$i] = $counts{"$w"};
                $flags[$i] = $flag{"$w"};

                if( $flag{"$w"} =~ "OK" ) {
                    $N_good++;
                }

                # if( $w =~ "the" || $w =~ "and" || $w =~ "for" ) { $add = 100; } else { $add = $counts{"$w"}; }
                # if( $counts{"$w"} >= 700000 ) { $add = 700000; };  # else { $add = $counts{"$w"}; }
                $rel_freq = $counts{"$w"}/$N_words_in_corpus;
                # $prod *= $rel_freq; 
                $lgPdict += -0.4343*log($rel_freq);
                $N_in_dict++;
            } else {
                if( $debug2 ) { print "        $w = NOT FOUND\n"; }
            }
        } else {
            if( $debug2 ) { print "        $w = TOO SHORT\n"; }
        }
    }


    if( $skip_this == 0 ) {   # if writing to file skips this block
    if( $debug ) {
        $denom = $N_good;
        if( $N_good == 0 ) { $denom = 1e8 }
        printf "O: %1d ; %1d ; %1d ;", ($#words+1), $N_in_dict, $N_good;
        # printf " %8.2e ;", $prod;
        printf " %7.3f ;", $lgPdict;
        printf " %-s ;", join(" ",@words);
        printf " %-s ;  %6d\n", $pred, $freq; 
        print "-----\n";
    } else {
        $denom = $N_good;
        if( $N_good == 0 ) { $denom = 1e8 }
        printf " %1d ; %1d ; %1d ;", ($#words+1), $N_in_dict, $N_good;
        printf " %7.3f ;", $lgPdict;
        printf "(";
        for $c (@flags) { printf " %2s", $c; }
        printf " %2s", $flag{"$pred"};
        printf " );";
        printf "(N=";
        for $c (@cts) { printf " %7d", $c; }
        printf " );";
        printf "(ID=";
        for $c (@id) { printf " %6d", $c; }
        if( defined $ID{"$pred"} ) { $id2print=$ID{"$pred"}; } else { $id2print=-1; }
        printf " %6d", $id2print;
        printf " );";
        printf " %6d ;", $freq; 
        printf " %-s ;", join(" ",@words);
        printf " %-s\n", $pred; 
        # printf " ); %-s ;", join(" ",@words);
        # printf " %-s ;  %6d\n", $pred, $freq; 
    }
    }


    if( $flag_save_to_file ) {
        # It prints only n-grams whose 'pred' is included in the reduced dictionary.
        if( defined $ID{"$pred"} && $flag{"$pred"} =~ "OK" ) { 
            
            if( $flag_by_ID ) { 
                printf "%s;", join(";",@id);
                printf "%s;", $ID{"$pred"}; 
            } else {
                printf "%-s;", join(";",@words);
                printf "%-s;", $pred; 
            }

            #printf "%.3f;", $lg_freq; 
            printf "%d;", $freq; 
            printf "%.3f", $lgPdict;

            printf "\n";
        }
    }

    if( $flag_save_filtered_ngrams ) {
        # It prints only n-grams whose 'pred' is included in the reduced dictionary.
        if( defined $ID{"$pred"} && $flag{"$pred"} =~ "OK" ) { 
            
            printf "%d;", $freq;
            printf "%-s;", join(";",@words);
            printf "%-s", $pred; 
            printf "\n";
        }
    }

}

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
