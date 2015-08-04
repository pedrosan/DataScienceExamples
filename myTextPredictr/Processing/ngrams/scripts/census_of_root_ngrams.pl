#!/usr/bin/perl -w 

#---------------------------------------------------------------------------------------------------
# script to 
#---------------------------------------------------------------------------------------------------

use feature 'unicode_strings';  # CHECK THIS SETTING (http://perldoc.perl.org/perlunifaq.html)
use utf8;

# use Text::Unidecode;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

use Getopt::Long;
Getopt::Long::Configure('no_ignore_case');

$debug=0;
# $min_ngram_freq=2;
# $min_word_count=2;
$print2file=0;
# $skip_this=0;

GetOptions ('d|debug' => \$debug, 
            #'min_ngram_freq=i'  => \$min_ngram_freq,
            #'min_word_count=i'  => \$min_word_count,
            'p|print' => \$print2file );

# keys(%dict) = 267992;
# keys(%ID) = 537968;
# keys(%flag) = 537968;
# keys(%counts) = 537968;

# if( $debug ) {
#     print "# min ngram freq = $min_ngram_freq\n";
#     print "# min word  cnt  = $min_word_count\n";
# }

# open(WCFILE,"./wc_new.csv");
# open(WCFILE,"./dictionary_for_hash.csv");
# binmode WCFILE, ':encoding(UTF-8)';
# 
# Number of words in sentences
# $N_words_in_corpus=93817226;
# 
# $Ndict=0;
# while (<WCFILE>){
#     chomp;
#     ($id, $flag, $count, $word) = parse_csv($_);
#     # print " word : $word ==> $count \n";
#     if( $count < $min_word_count ) { next; }
#     $Ndict++;
#     $ID{"$word"} = $id;
#     $flag{"$word"} = $flag;
#     $counts{"$word"} = $count;
# }
# close(WCFILE);

$N_processed=0;
$N_cumulative=0;
while (<STDIN>) {

    $N_processed++;

    chomp;
    @words = split(/;/);
    $freq = shift(@words);
    $ngram = join(";", @words);
    $pred = pop(@words);
    $root = join(";", @words);

    $ngram_root{"$ngram"} = $root;
    $ngram_freq{"$ngram"} = $freq;
    $ngram_full{"$ngram"} = $ngram;

    $CensusN{"$root"}++;
    $CensusSum{"$root"}+=$freq;
    $N_cumulative+=$freq;
    
}

$prefix="tmp2";
$prefix="tmp1";

$order=$#words+2;
$outfile=$prefix . "_census_n" . $order . "grams.csv";

print "# Number of ngrams processed  = $N_processed\n";
print "# Cumulative number of counts = $N_cumulative\n";

if( $print2file ) {

    open(CENSUS,"> $outfile" ) || die "could not open file $outfile\n";
    binmode CENSUS, ':encoding(UTF-8)';
    select(CENSUS);

    my @keys_sorted_by_freq = sort { $ngram_freq{$b} <=> $ngram_freq{$a} } keys(%ngram_full);
    # foreach $full ( keys %ngram_full ) {
    foreach $full ( @keys_sorted_by_freq ) {
        $freq = $ngram_freq{"$full"};
        $root = $ngram_root{"$full"};

        $N = $CensusN{"$root"};
        $Sum = $CensusSum{"$root"};

        #$logLH = -0.4343*log($Sum/$N_cumulative);   # redundant, it can be computed from the $Sum a posteriori
    
        printf "%d;%d;%d;%s\n", $Sum, $N, $freq, $full;
        #printf "%.4f;%d;%d;%d;%s\n", $logLH, $Sum, $N, $freq, $full;
        #printf "%d;%s\n", $freq, $full;
    }

    select(STDOUT);
    close(CENSUS);

} else {

    my @keys_sorted_by_value = sort { $CensusSum{$b} <=> $CensusSum{$a} } keys(%CensusSum);
    # foreach $str ( sort keys %CensusN )
    foreach $str ( @keys_sorted_by_value ) {
        $N = $CensusN{"$str"};
        $Sum = $CensusSum{"$str"};
        $logLH = -0.4343*log($Sum/$N_cumulative);   # redundant, it can be computed from the $Sum a posteriori
    
        printf "%.4f;%d;%d;%s\n", $logLH,$Sum,$N,$str;
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
