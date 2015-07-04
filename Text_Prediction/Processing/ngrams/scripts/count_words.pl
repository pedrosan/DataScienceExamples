#!/usr/bin/perl -w 
#
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
GetOptions ('d|debug' => \$debug, 
            'd2|debug2' => \$debug2 );

# keys(%dict) = 267992;

# $dict{"$word"} = $count;

$ofile="dictionary_from_sentences.txt";
open(DICT,"> $ofile" ) || die "could not open file $ofile\n";

while (<STDIN>) {

    chomp;
    if( $debug ) {  
        print "I:                                $_\n";
    } 

    $word = $_;
    $dict{"$word"}++;

}

$n=0;
foreach $w ( sort keys %dict ) {
    $n++;
    # print " $w ==> " . $dict{"$w"}. "\n";
    printf DICT " %5d - %-24s ==> %6d\n", $n, $w, $dict{"$w"};
}

close(DICT);

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
