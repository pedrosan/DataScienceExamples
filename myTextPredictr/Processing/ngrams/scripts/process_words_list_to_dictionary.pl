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
$flag_print=0;
GetOptions ('d|debug' => \$debug, 
            'p|print' => \$flag_print,
            'd2|debug2' => \$debug2 );

# keys(%dict) = 267992;

# $dict{"$word"} = $count;

# $ofile="dictionary_from_sentences.txt";
# open(DICT,"> $ofile" ) || die "could not open file $ofile\n";

while (<STDIN>) {

    chomp;
    s|^ +||;
    s| +| |g;
    s| +$||;

    @row = split(" +", $_);
    $id = $row[0];
    $word = $row[2];
    $count = $row[4];

    # default flag
    $flag="__";

    # general BAD word
    if( $word =~ /[^A-Za-z_']/ ) { $flag="XX" }

    # GOOD or potentially good words
    #   - letters and underscore
    #   - letters and underscore, with max one ' or - (and not both) 
    #   - TAGS
    #
    # if( $word =~ /^[A-Za-z_'-]+$/ ) { $flag="O_" }
    # if( $word =~ /^[A-Za-z_']+$/ ) { $flag="OK" }
    # if( $word =~ /^[A-Za-z_]'?[A-Za-z]+$/ ) { $flag="OK" }
    if( $word =~ /^[A-Za-z_]+$/ ) { $flag="OK" }
    if( $word =~ /^[A-Za-z_]+['-]?[A-Za-z_]+$/ ) { $flag="OK" }
    if( $word =~ /^<[A-Z]+>$/ ) { $flag="OK" }

    #
    # subtracting back
    #
    if( $word =~ /^[a-z]_(?!(am))[a-z]{1,2}$/ ) { $flag="_K" }
    if( $word =~ /^[a-z]-[a-z]$/ ) { $flag="_K" }
    if( $word =~ /^[a-z]-[a-z]{1,2}$/ ) { $flag="_K" }
    
    if( $word =~ /^[a-z]+['_]+[a-z]+['_]+[a-z]+$/ ) { $flag="_K" }

    if( $word =~ /^(a|an|as|at|no|of|on|or|by|so|up|or|no|in|to|rt)$/ ) { $flag="sw" } 
    if( $word =~ /^<(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>$/ ) { $flag="_K" } 
    
    # 3+ consecutive identical letters 
    if( $word =~ /([a-z])\1{2,}/ && $flag !~ "XX" ) { $flag="UU" }

    # certainly BAD, just to not take any chance... 
    #   - single letter, only 'i' allowed
    if( $word =~ /^[a-hl-z]$/ ) { $flag="YY" }

    # various non-alpha characters
    if( $word =~ /[;,"!?(){}#*~%\$\|\\]/ ) { $flag="YY" }
    if( $word =~ /^[^a-z<]/ ) { $flag="YY" }
    if( $word =~ /^<[^A-Z]/ ) { $flag="YY" }
    if( $word =~ /^.+[<>].*$/ ) { $flag="YY" }

    if( $flag_print == 1 ) {
        if( $flag !~ "YY" ) {
            printf "%s;%2s;%d;%s\n", $id, $flag, $count, $word;
        }
    } else {
        printf " %7d %1s [%-s]\n", $count, $flag, $word;
    }

    if( $debug ) {  
        print "I:                                $_\n";
    } 

    #$word = $_;
    #$dict{"$word"}++;

}

# $n=0;
# foreach $w ( sort keys %dict ) {
#     $n++;
#     # print " $w ==> " . $dict{"$w"}. "\n";
#     printf DICT " %5d - %-24s ==> %6d\n", $n, $w, $dict{"$w"};
# }

# close(DICT);

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
