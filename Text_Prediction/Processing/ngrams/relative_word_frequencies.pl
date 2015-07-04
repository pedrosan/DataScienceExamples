#!/usr/bin/perl -w 

#---------------------------------------------------------------------------------------------------
# script to ...
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
$ngram_normalization=1;
$skip_this=0;
$flag_by_ID=0;

GetOptions ('d|debug' => \$debug, 
            'min_ngram_freq=i'  => \$min_ngram_freq,
            'min_word_count=i'  => \$min_word_count,
            'normalization=i'   => \$ngram_normalization,
            'save_to_file'      => \$flag_save_to_file,
            'byID'              => \$flag_by_ID,
            'd2|debug2' => \$debug2 );

if( $flag_save_to_file ) { $skip_this = 1; }

# keys(%dict) = 267992;
# keys(%ID) = 537968;
# keys(%flag) = 537968;
# keys(%counts) = 537968;

#-------------------------------------------------
# open(WCFILE,"./dictionary_for_hash.csv");
# binmode WCFILE, ':encoding(UTF-8)';
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
#-------------------------------------------------

#-------------------------------------------------
open(DICTFILE,"./dictionary_official.csv");
binmode DICTFILE, ':encoding(UTF-8)';
$Ndict=0;
while (<DICTFILE>){
    if(/^ID/){next;}
    chomp;
    ($id, $word, $count) = split(";");
    # print " word : $word ==> $count \n";
    if( $count < $min_word_count ) { next; }
    $Ndict++;
    $ID{"$word"} = $id;
    $flag{"$word"} = $flag;
    $counts{"$word"} = $count;
}
close(DICTFILE);
#-------------------------------------------------

# exit;

if( $debug ) {
    print "# loaded dictionary contains $Ndict words\n";
}

$N_Ngrams=0;
$N_Ngrams_cumul=0;
$N_Dict=0;
$N_Dict_cumul=0;

while (<STDIN>) {

    chomp;
    @words = split(/;/);
    $freq = shift(@words);
    $pred = pop(@words);

    if( $debug ) {
    if( ! defined $ID{"$pred"} ) {
        print "# predicted word [$pred] does not have an entry in the dictionary\n";
        next;
    }
    }

    $N_Ngrams++;
    $N_Ngrams_cumul+=$freq;
    $N_Dict++;
    $N_Dict_cumul+=$counts{"$pred"};

    $Cnt_in_Ngrams{"$pred"}+=$freq;
    $Cnt_in_Dict{"$pred"}=$counts{"$pred"};

}

foreach $str ( sort keys %Cnt_in_Ngrams ) {
    $N_ng = $Cnt_in_Ngrams{"$str"};
    $N_dict = $Cnt_in_Dict{"$str"};
    $frac_N_ng = 100.0*$N_ng/$N_Ngrams_cumul;
    $frac_N_dict = 100.0*$N_dict/$N_Dict_cumul;

    $score = $frac_N_ng / $frac_N_dict;

    printf "  %6d %9d", $N_ng, $N_dict;
    printf "  %8.4f %8.4f", $frac_N_ng, $frac_N_dict;
    printf "  %9.4f ", $score;
    printf "  %s\n", $str;
}

printf "#-----------------------------------------------------------\n";
printf "# N_Ngrams       = %9d\n", $N_Ngrams;
printf "# N_Ngrams_cumul = %9d\n", $N_Ngrams_cumul;
printf "#\n";
printf "# N_Dict         = %9d\n", $N_Dict;
printf "# N_Dict_cumul   = %9d\n", $N_Dict_cumul;
printf "#-----------------------------------------------------------\n";

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
