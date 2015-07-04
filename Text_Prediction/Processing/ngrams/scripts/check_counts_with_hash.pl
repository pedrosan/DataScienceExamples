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
GetOptions ('d|debug' => \$debug, 
            'd2|debug2' => \$debug2 );

keys(%dict) = 267992;

# open(WCFILE,"./wc_new.csv");
open(WCFILE,"./word_count_for_hash.csv");
binmode WCFILE, ':encoding(UTF-8)';
while (<WCFILE>){
    chomp;
    ($word, $count) = parse_csv($_);
    # print " word : $word ==> $count \n";
    # if( $word =~ "the" || $word =~ "and" || $word =~ "for" ) { $count = 100; }
    # if( $count >= 40000 ) { $count = 40000; }
    $dict{"$word"} = $count;
}
close(WCFILE);

# if( $debug ) {  
#     foreach $w ( sort keys %dict ) {
#         print " $w ==> " . $dict{"$w"}. "\n";
#     }
# }

while (<STDIN>) {

    chomp;
    if( $debug ) {  
        print "I:                                $_\n";
    } 

    $N = chop($_);
    s| +$||g;

    @words = split(/ +/);
    # $pred = $words[$#words];
    $pred = pop(@words);

    $sum = 0;
    $sumlg = 0;
    $prod = 1;
    $ngood = 0;
    $n_in_dict = 0;
    $i = -1;
    @cts = ( 0, 0, 0, 0, 0);
    foreach $w ( @words ) {
        $i++;

        # word is 'good' if long enough
        if( length($w) >= 3 ) {
            $ngood++;

            # check if known in the dictionary
            if( defined $dict{"$w"} ) {
                if( $debug2 ) { print "        $w = $dict{$w}\n"; }

                if( $w =~ "the" || $w =~ "and" || $w =~ "for" ) { $add = 100; } else { $add = $dict{"$w"}; }
                if( $dict{"$w"} >= 60000 ) { $add = 60000; };  # else { $add = $dict{"$w"}; }
                $cts[$i] = $dict{"$w"};
                $sum += $add;
                $sumlg += 0.4343*log($add);
                $prod *= $add; 
                $n_in_dict++;
            } else {
                if( $debug2 ) { print "        $w = NOT FOUND\n"; }
            }
        } else {
            if( $debug2 ) { print "        $w = TOO SHORT\n"; }
        }
    }

    if( $debug ) {  
        $denom = $ngood;
        if( $ngood == 0 ) { $denom = 1e8 }
        printf "O: %1d ; %1d ; %1d ;", ($#words+1), $n_in_dict, $ngood;
        printf " %7.1f ;", $sum/$denom;
        printf " %7.3f ;", $sumlg/$denom;
        printf " %-s ;", join(" ",@words);
        printf " %-s ;  %6d\n", $pred, $N; 
        print "-----\n";
    } else {
        $denom = $ngood;
        if( $ngood == 0 ) { $denom = 1e8 }
        printf " %1d ; %1d ; %1d ;", ($#words+1), $n_in_dict, $ngood;
        printf " %7.1f ;", $sum/$denom;
        printf " %7.3f ;(", $sumlg/$denom;
        for $c (@cts) { printf " %6d", $c; }
        printf " );";
        printf " %6d ;", $N; 
        printf " %-s ;", join(" ",@words);
        printf " %-s\n", $pred; 
        # printf " ); %-s ;", join(" ",@words);
        # printf " %-s ;  %6d\n", $pred, $N; 
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
