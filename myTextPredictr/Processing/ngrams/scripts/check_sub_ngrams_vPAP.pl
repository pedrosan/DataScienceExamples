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
$min_ngram_freq=2;
$min_word_count=2;
$print2file=0;
# $skip_this=0;

GetOptions ('d|debug' => \$debug, 
            'min_ngram_freq=i'  => \$min_ngram_freq,
            'min_word_count=i'  => \$min_word_count,
            'p|print' => \$print2file );

# keys(%dict) = 267992;
# keys(%ID) = 537968;
# keys(%flag) = 537968;
# keys(%counts) = 537968;

# if( $debug ) {
#     print "# min ngram freq = $min_ngram_freq\n";
#     print "# min word  cnt  = $min_word_count\n";
# }

$Nmax2read = 10000;

$len_tail=2;
#-----------------------------------------------------------
open(NGRAMS3, "./N3GRAMS_2_5");
binmode NGRAMS3, ':encoding(UTF-8)';

$N3=0;
while (<NGRAMS3>){
    if(/^#/){next;}
    $N3++;
    if($N3 > $Nmax2read) { $N3--; last; }
    chomp;
    ($dummy, $sumN, $count, @words) = split(";");
    $ngram = join(";", @words);
    $g3_sumN{"$ngram"} = $sumN;
    $g3_count{"$ngram"} = $count;
}
close(NGRAMS3);
printf "# Loaded 3-grams : %d\n", $N3;

#-----------------------------------------------------------
open(NGRAMS4, "./N4GRAMS_2_5");
binmode NGRAMS4, ':encoding(UTF-8)';

$N4=0;
while (<NGRAMS4>){
    if(/^#/){next;}
    $N4++;
    if($N4 > $Nmax2read) { $N4--; last; }
    chomp;
    ($dummy, $sumN, $count, @words) = split(";");
    $ngram = join(";", @words);
    $sub = tail_joined_ngram($ngram, $len_tail);
    # printf " CHECK4 :  %s  =  %s\n", $ngram, $sub;
    # printf " %d %d %s\n", $sumN, $count, $ngram;
    $g4_sumN{"$sub"} += $sumN;
    $g4_count{"$sub"} += $count;
}
close(NGRAMS4);
printf "# Loaded 4-grams : %d\n", $N4;

#-----------------------------------------------------------
open(NGRAMS5, "./N5GRAMS_2_5");
binmode NGRAMS5, ':encoding(UTF-8)';

$N5=0;
while (<NGRAMS5>){
    if(/^#/){next;}
    $N5++;
    if($N5 > $Nmax2read) { $N5--; last; }
    chomp;
    ($dummy, $sumN, $count, @words) = split(";");
    $ngram = join(";", @words);
    $sub = tail_joined_ngram($ngram, $len_tail);
    # printf " %d %d %s\n", $sumN, $count, $ngram;
    $g5_sumN{"$sub"} += $sumN;
    $g5_count{"$sub"} += $count;
}
close(NGRAMS5);
printf "# Loaded 5-grams : %d\n", $N5;

#-----------------------------------------------------------
# my @keys_sorted = sort { $g3_sumN{$b} <=> $g3_sumN{$a} } keys(%g3_sumN);
# foreach $str ( @keys_sorted ) 
# foreach $str ( keys %g3_count ) {
#     $sumN = $g3_sumN{"$str"};
#     $count = $g3_count{"$str"};
# 
#     printf "%d;%d;%s\n", $sumN, $count, $str;
# }

$N_g3_in_g4=0;
$N_g3_in_g5=0;
foreach $str ( keys %g3_count ) {
    #$sumN = $g3_sumN{"$str"};
    #$count = $g3_count{"$str"};
    $g3_exists_in_g4{"$str"}=0; 
    $g3_exists_in_g5{"$str"}=0; 
    if( ! defined $g4_count{"$str"} ) { $g3_exists_in_g4{"$str"}++; $N_g3_in_g4++; } 
    if( ! defined $g5_count{"$str"} ) { $g3_exists_in_g5{"$str"}++; $N_g3_in_g5++; } 

    printf "  %4d  %4d : %-s\n", $g3_exists_in_g4{"$str"}, $g3_exists_in_g5{"$str"}, $str;
    # printf "%-30s %-30s %-30s\n", $str, $sub2gram, $subAlt;
}
printf "#-----------------------------------------------------------\n";
printf "#   g3 in g4 : %7d  (N3 = %7d / N4 = %7d )\n", $N_g3_in_g4, $N3, $N4;
printf "#   g3 in g5 : %7d  (N3 = %7d / N4 = %7d )\n", $N_g3_in_g5, $N3, $N5;
printf "#-----------------------------------------------------------\n";

exit;
#===========================================================

$N_processed=0;
$N_cumulative=0;
while (<STDIN>) {

    $N_processed++;

    chomp;
    @words = split(/;/);
    $freq = shift(@words);
    $pred = pop(@words);
    $ngram = join(";", @words);

    $CensusN{"$ngram"}++;
    $CensusSum{"$ngram"}+=$freq;
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
}

my @keys_sorted_by_value = sort { $CensusSum{$b} <=> $CensusSum{$a} } keys(%CensusSum);

foreach $str ( @keys_sorted_by_value ) {
    $N = $CensusN{"$str"};
    $Sum = $CensusSum{"$str"};
    $logLH = -0.4343*log($Sum/$N_cumulative);

    printf "%.4f;%d;%d;%s\n", $logLH,$Sum,$N,$str;
}
select(STDOUT);
close(CENSUS);

exit; 

#---------------------------------------------------------------------------------------------------
sub tail_joined_ngram {
   
   my @input = split(";", shift);
   my $len = shift;
   $len = -1*$len;

   $tail = join(";", splice( @input, $len ) );
   return $tail;

}
#---------------------------------------------------------------------------------------------------
sub tail_split_ngram {
   
   my @input = shift;
   my $len = shift;
   $len = -1*$len;

   $tail = join(";", splice( @input, $len ) );
   return $tail;

}
#---------------------------------------------------------------------------------------------------
sub parse_csv {
   
   my $text = shift;
   my @new= ();
   push(@new,$+) while $text =~ m{"([^\"\\]*(?:\\.[^\"\\]*)*)",?|  ([^,]+),?| ,}gx;
   push(@new,undef) if substr($text,-1,1) eq ',';
   return @new;

}
#---------------------------------------------------------------------------------------------------
