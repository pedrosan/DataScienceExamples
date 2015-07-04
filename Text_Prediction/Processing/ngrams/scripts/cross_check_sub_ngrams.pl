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


printf "#-----------------------------------------------------------\n";
$Nmax2read = 100000;
$Nmax2read = 1000000000;

#-----------------------------------------------------------
open(NGRAMS3, "./N3GRAMS_2_5");
binmode NGRAMS3, ':encoding(UTF-8)';

$N3=0;
while (<NGRAMS3>){
    if(/^#/){next;}
    $N3++;
    if($N3 > $Nmax2read) { $N3--; last; }
    chomp;
    $fullrow = $_;
    ($count, @words) = split(";");
    $ngram = join(";", @words);
    $n3grams_full{"$ngram"} = $fullrow;

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
    $fullrow = $_;
    ($count, @words) = split(";");
    $ngram = join(";", @words);
    $n4grams_full{"$ngram"} = $fullrow;

    $g4_count{"$ngram"} = $count;
    $sub3 = tail_joined_ngram($ngram, 3);
    $g43_count{"$sub3"} += $count;
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
    $fullrow = $_;
    ($count, @words) = split(";");
    $ngram = join(";", @words);
    $n5grams_full{"$ngram"} = $fullrow;

    $g5_count{"$ngram"} = $count;
    $sub3 = tail_joined_ngram($ngram, 3);
    $g53_count{"$sub3"} += $count;
    $sub4 = tail_joined_ngram($ngram, 4);
    $g54_count{"$sub4"} += $count;
}
close(NGRAMS5);
printf "# Loaded 5-grams : %d\n", $N5;

#-----------------------------------------------------------
$outFileRoot3="XCHECK_N3GRAMS";
$out_3=$outFileRoot3   . "_in_3";
$out_34=$outFileRoot3  . "_in_34";
$out_35=$outFileRoot3  . "_in_35";
$out_345=$outFileRoot3 . "_in_345";

$outFileRoot4="XCHECK_N4GRAMS";
$out_4=$outFileRoot4  . "_in_4";
$out_45=$outFileRoot4 . "_in_45";
$out_43=$outFileRoot4 . "_in_43";

# $outFileRoot5="XCHECK_N5GRAMS";
# $out_5=$outFileRoot5   . "_in_5";
# $out_54=$outFileRoot5  . "_in_54";

open(OUT_3  ,"> $out_3"  ) || die "could not open file $out_3\n";
open(OUT_34 ,"> $out_34" ) || die "could not open file $out_34\n";
open(OUT_35 ,"> $out_35" ) || die "could not open file $out_35\n";
open(OUT_345,"> $out_345") || die "could not open file $out_345\n";
open(OUT_4  ,"> $out_4"  ) || die "could not open file $out_4\n";
open(OUT_45 ,"> $out_45" ) || die "could not open file $out_45\n";
open(OUT_43 ,"> $out_43" ) || die "could not open file $out_43\n";
# open(OUT_5  ,"> $out_5"  ) || die "could not open file $out_5\n";
# open(OUT_54 ,"> $out_54" ) || die "could not open file $out_54\n";

binmode OUT_3,  ':encoding(UTF-8)';
binmode OUT_34, ':encoding(UTF-8)';
binmode OUT_35, ':encoding(UTF-8)';
binmode OUT_345,':encoding(UTF-8)';
binmode OUT_4,  ':encoding(UTF-8)';
binmode OUT_45, ':encoding(UTF-8)';
binmode OUT_43, ':encoding(UTF-8)';
# binmode OUT_5,  ':encoding(UTF-8)';
# binmode OUT_54, ':encoding(UTF-8)';

#-----------------------------------------------------------
# my @keys_sorted = sort { $g3_sumN{$b} <=> $g3_sumN{$a} } keys(%g3_sumN);
# foreach $str ( @keys_sorted ) 
# foreach $str ( keys %g3_count ) {
#     $sumN = $g3_sumN{"$str"};
#     $count = $g3_count{"$str"};
# 
#     printf "%d;%d;%s\n", $sumN, $count, $str;
# }

$N_g34=0;
$N_g35=0;
$N_g345=0;
$Nclean_3=0;
$Nclean_34=0;
$Nclean_35=0;
$Nclean_345=0;
foreach $str ( keys %g3_count ) {
    $g3_exists_in_g4{"$str"}=0; 
    $g3_exists_in_g5{"$str"}=0; 
    $g3_count_in_g4{"$str"}=0; 
    $g3_count_in_g5{"$str"}=0; 
    $flag345=0;
    if( defined $g43_count{"$str"} ) { 
        $flag345+=1;
        $N_g34++; 
        $g3_exists_in_g4{"$str"}++; 
        $g3_count_in_g4{"$str"}+=$g43_count{"$str"}; 
    } 
    if( defined $g53_count{"$str"} ) { 
        $flag345+=2;
        $N_g35++; 
        $g3_exists_in_g5{"$str"}++; 
        $g3_count_in_g5{"$str"}+=$g53_count{"$str"}; 
    } 
    if( $flag345 == 3 ) { $N_g345++ }

    if( $flag345 == 0 ) { $Nclean_3++;   select(OUT_3); }
    if( $flag345 == 1 ) { $Nclean_34++;  select(OUT_34); }
    if( $flag345 == 2 ) { $Nclean_35++;  select(OUT_35); }
    if( $flag345 == 3 ) { $Nclean_345++; select(OUT_345); }

    if( $print2file ) {
        printf "%s\n", $n3grams_full{"$str"};
    } else {
        printf "  %4d  %4d :", $g3_exists_in_g4{"$str"}, $g3_exists_in_g5{"$str"};
        printf "  %7d  %7d :", $g3_count_in_g4{"$str"}, $g3_count_in_g5{"$str"};
        printf "  %7d  %-s\n", $g3_count{"$str"}, $str;
    }

    select(STDOUT);
}

$N_g45=0;
$Nclean_4=0;
$Nclean_45=0;
foreach $str ( keys %g4_count ) {
    $g4_exists_in_g5{"$str"}=0; 
    $g4_count_in_g5{"$str"}=0; 
    $flag45=0;
    if( defined $g54_count{"$str"} ) { 
        $flag45+=1;
        $N_g45++; 
        $g4_exists_in_g5{"$str"}++; 
        $g4_count_in_g5{"$str"}+=$g54_count{"$str"}; 
    } 
    if( $flag45 == 0 ) { $Nclean_4++;  select(OUT_4); }
    if( $flag45 == 1 ) { $Nclean_45++; select(OUT_45); }

    if( $print2file ) {
        printf "%s\n", $n4grams_full{"$str"};
    } else {
        printf "  %4d :  %7d :", $g4_exists_in_g5{"$str"}, $g4_count_in_g5{"$str"};
        printf "  %7d  %-s\n", $g4_count{"$str"}, $str;
    }

    select(STDOUT);
}

# $N_g43=0;
# $Nclean_4=0;
# $Nclean_43=0;
# select(OUT_43);
# foreach $str ( keys %g43_count ) {
#     $g4_exists_in_g3{"$str"}=0; 
#     $g4_count_in_g3{"$str"}=0; 
#     $flag43=0;
#     if( defined $g3_count{"$str"} ) { 
#         $flag43+=1;
#         $N_g43++; 
#         $g4_exists_in_g3{"$str"}++; 
#         $g4_count_in_g3{"$str"}+=$g43_count{"$str"}; 
#     } 
#     if( $flag43 == 1 ) { 
#         $Nclean_43++; 
#         printf "  %4d :  %7d :", $g4_exists_in_g3{"$str"}, $g4_count_in_g3{"$str"};
#         printf "  %7d  %-s\n", $g43_count{"$str"}, $str;
#     }
# 
# }
# select(STDOUT);

# $N_g54=0;
# $Nclean_5=0;
# $Nclean_54=0;
# foreach $str ( keys %g54_count ) {
#     $g5_exists_in_g4{"$str"}=0; 
#     $g5_count_in_g4{"$str"}=0; 
#     $flag54=0;
#     if( defined $g4_count{"$str"} ) { 
#         $flag54+=1;
#         $N_g54++; 
#         $g5_exists_in_g4{"$str"}++; 
#         $g5_count_in_g4{"$str"}+=$g54_count{"$str"}; 
#     } 
#     if( $flag54 == 0 ) { $Nclean_5++;  select(OUT_5); }
#     if( $flag54 == 1 ) { $Nclean_54++; select(OUT_54); }
# 
#     printf "  %4d :  %7d :", $g5_exists_in_g4{"$str"}, $g5_count_in_g4{"$str"};
#     printf "  %7d  %-s\n", $g54_count{"$str"}, $str;
# 
#     select(STDOUT);
# }

close(OUT_3);
close(OUT_34);
close(OUT_35);
close(OUT_345);

close(OUT_4);
close(OUT_45);
close(OUT_43);

# close(OUT_5);
# close(OUT_54);

printf "#-----------------------------------------------------------\n";
printf "# 3-GRAMS     : %7d\n", $N3;
printf "#    only  g3 : %7d  %7d\n", ($N3 - $Nclean_34 - $Nclean_35 - $Nclean_345), $Nclean_3;
printf "#    in    g4 : %7d\n", $Nclean_34;
printf "#    in    g5 : %7d\n", $Nclean_35;
printf "#    in g4&g5 : %7d\n", $Nclean_345;
printf "#\n";
printf "# 4-GRAMS     : %7d\n", $N4;
printf "#     only g4 : %7d\n", ($N4 - $Nclean_45);
printf "#     in   g5 : %7d\n", $Nclean_45;
printf "#     in   g3 : %7d\n", $Nclean_43;
printf "#\n";
printf "# 5-GRAMS     : %7d\n", $N5;
# printf "#  ~~ only g5 : %7d\n", ($N5 - $Nclean_54);
# printf "#     in   g4 : %7d\n", $Nclean_54;
printf "#-----------------------------------------------------------\n";
# printf "#   in g4   : %7d  (N3 = %7d / N4 = %7d )\n", $N_g34, $N3, $N4;
# printf "#   in g5   : %7d  (N3 = %7d / N5 = %7d )\n", $N_g35, $N3, $N5;

exit;
#===========================================================

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
