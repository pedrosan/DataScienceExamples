#!/usr/bin/perl -w 

# used as 
#    gzip -dc n5grams.filtered_for_nonASCII.gz | ./reclean_ngrams.pl -p -g 

use utf8;
# use Text::Unidecode;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

use Getopt::Long;
Getopt::Long::Configure('no_ignore_case');

$debug=0;
$print2file=0;
$flag_go=0;
GetOptions ('d|debug' => \$debug ,
            'go'      => \$flag_go ,
            'p|print' => \$print2file );

# $origin="n5g";
# $origin="n4g";
# $origin="n3g";
$origin="n2g";

$ofile1="tmp_n1g_from_" . $origin . "_recleaned.csv";
$ofile2="tmp_n2g_from_" . $origin . "_recleaned.csv";
$ofile3="tmp_n3g_from_" . $origin . "_recleaned.csv";
$ofile4="tmp_n4g_from_" . $origin . "_recleaned.csv";
$ofile5="tmp_n5g_from_" . $origin . "_recleaned.csv";
$ofileN="tmp_nNg_from_" . $origin . "_recleaned.csv";
$ofileTrash="tmp_Trash_from_" . $origin . "_recleaned.txt";

if( $print2file ) {
    open(N1GRAMS,"> $ofile1" ) || die "could not open file $ofile1\n";
    open(N2GRAMS,"> $ofile2" ) || die "could not open file $ofile2\n";
    open(N3GRAMS,"> $ofile3" ) || die "could not open file $ofile3\n";
    open(N4GRAMS,"> $ofile4" ) || die "could not open file $ofile4\n";
    open(N5GRAMS,"> $ofile5" ) || die "could not open file $ofile5\n";
    open(NNGRAMS,"> $ofileN" ) || die "could not open file $ofileN\n";
    open(TRASH,"> $ofileTrash" ) || die "could not open file $ofileTrash\n";
}

while (<STDIN>){

    chomp;
    if( $debug ) {  
        print "I--|$_\n";
    } 

    # s/[\[\]*+]/ /g;
    s/[*+]/ /g;
    s| +| |g;
    s| +$||;
    s|^ +||;

    if( $debug ) { 
        $save = $_; 
        $save =~ s/[\[\]*+]/ /g;
    }

    #-------------------------------------------------
    # special ad-hoc handlings
    #  + square brackets enclosing words
    # s/([^a-z])\[([a-z]+)\]/$1$2/g;
    s/\[([a-z]+)\]/$1/g;
    
    #  + not-TAG >, <
    if( /[^A-Z]>/ || /<[^A-Z]/ ) { 
        if( $flag_go ) { 
            print TRASH "$_\n";
            next; 
        }
        if( $debug ) {  print "CAUGHT THIS GELE : $_\n"; } 
    } 

    if( /[\/\\]/ ) { 
        if( $flag_go ) {
            print TRASH "$_\n";
            next; 
        }
        if( $debug ) { print "CAUGHT THIS SLASH : $_\n"; }
    } 

    #-------------------------------------------------
    # non-alpha "isolated" characters
    #
    s/ +([^[:alnum:]]+) +/ /g;
    # s/([[:alnum:]]+)([^[:alnum:] ]+) +/$1 /g;
    s/([[:alnum:]]+)(?<![A-Z])([^[:alnum:] ]+) +/$1 /g;
    s/([A-Z]+>)([^[:alnum:]]+) +/$1 /g;
    # s/ +([^[:alnum:] <]+)([[:alnum:]]+)/ $2/g;
    s/ +([^[:alnum:] ]+)(?![A-Z])([[:alnum:]]+)/ $2/g;
    s/ +([^[:alnum:]]+)(<[A-Z]+)/ $2/g;
    s/^([^[:alnum:]<]+)//;
    s/([^[:alnum:]>]+)$//;

    s/([a-z>])[-]+([<a-z])/$1 $2/g;

    #-------------------------------------------------
    # TAGS handling (mostly removal in some form)
    # <(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>
    #

    s/^<(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>[^[:alpha:]<]+/HERE11/;
    s/^(HERE11)?<(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>[^[:alpha:]<]+/HERE12/;
    s/[^[:alpha:]>]+<(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>$/HERE21/;
    s/[^[:alpha:]>]+<(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>(HERE21)?$/HERE22/;

    s/HERE[12][12]//g;

    if( /<(DATE|DECADE|DOLLARAMOUNT|HOUR|MONEY|NUMBER|ORDINAL|TIMEINTERVAL|USA)>/ ) { 
        if( $flag_go ) {
            print TRASH "$_\n";
            next; 
        }
        if( $debug ) {  $_ = "CAUGHT THIS TAG IN THE MIDDLE"; } 
        # if( $debug ) {  print "CAUGHT THIS TAGINTHEMIDDLE : $_\n"; } 
    } 

   
    #===========================================================
    # stopwords (there shouldn't be any left...)
    # s/\;\b(a|an|as|at|no|of|on|or|by|so|up|or|no|in|to|rt)(?=;)/\;-/gi; 

    # single characters, except 'i'
    # s|;[a-hl-z];|;-;|gi;
    s|^[a-hl-z](?= )||gi;
    s|(?<= )[a-hl-z]$||gi;
    s| [a-hl-z](?= )| |gi;

    # some particularly useless TAGS  <==== TAGS HAVE BEEN HANDLED
    # s/(<ASS>|<HOUR>|<DATE>)//g; 

    # ampersand                       <==== SHOULD HAVE BEEN TAKEN CARE OF BY THE ABOVE SECTION ON [^[:alpha:]]
    # s|\;&[a-z]*(?=;)|;-|gi;
    
    # apostrophe not followed by s    <==== SHOULD HAVE BEEN TAKEN CARE OF BY THE ABOVE SECTION ON [^[:alpha:]]
    # s/\'(?\!s)//g;

    # pound sign                      <==== SHOULD HAVE BEEN TAKEN CARE OF BY THE ABOVE SECTION ON [^[:alpha:]]
    # s|;#[[:alnum:]]+\b|;-|gi; 

    # beginning with ";" (?)          <==== IT DOES NOT APPLY FOR PROCESSING DONE BEFORE SPLITTING
    # s|^;||; 

    # ending with ";" (?)             <==== IT DOES NOT APPLY FOR PROCESSING DONE BEFORE SPLITTING
    # s|;$||;

    #===========================================================
    # always good to tidy up spaces
    s| +| |g;
    s| +$||;
    s|^ +||;

    #===========================================================
    # $_ = join(";", split(" +", $_));
    # $row = join(";", split(" +", $_));
    if( $print2file ) {

        @row = split(" +", $_);
        $nw = $#row + 1;

        if( $debug ) {  
            print " $nw --[@row]\n";
        }
        
        if($nw == 1) { print N1GRAMS join(';', ($nw, @row)) . "\n"; }
        if($nw == 2) { print N2GRAMS join(';', ($nw, @row)) . "\n"; }
        if($nw == 3) { print N3GRAMS join(';', ($nw, @row)) . "\n"; }
        if($nw == 4) { print N4GRAMS join(';', ($nw, @row)) . "\n"; }
        if($nw == 5) { print N5GRAMS join(';', ($nw, @row)) . "\n"; }
        if($nw >  5) { print NNGRAMS join(';', ($nw, @row)) . "\n"; }
    }
    #===========================================================

    #-----------------------------------------------------------
    # s|[\x00-\x7F]| |g;
    # s| +||g;
    # s| +$||g;
    # s|^ +||g;
    # if(/[^\x00-\x7F]/) { s|(.)|$1\n|g; } 
    # if(/[^\x00-\x7F]/) { s|^|X: |; s|$|]|; } 
    #-----------------------------------------------------------

    #----
    $str="O";
    if( $debug ) { if($_ !~ $save) { $str="X"; } }
    if( !$print2file ) {
        if( $debug ) { printf "%1s--|%-s\n", $str, $_; print "-----\n"; } else { print "$_\n"; }
    }

    # if( $debug ) { print "O--|$_\n"; print "-----\n"; } else { print "$_\n"; }

    # it does not catch cases like:
    #    text ,1234...
    
}

if( $print2file ) {
    close(N1GRAMS);
    close(N2GRAMS);
    close(N3GRAMS);
    close(N4GRAMS);
    close(N5GRAMS);
    close(NNGRAMS);
    close(TRASH);
}

    
exit;
################################################################################
