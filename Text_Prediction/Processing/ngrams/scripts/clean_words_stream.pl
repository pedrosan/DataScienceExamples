#!/usr/bin/perl -w 

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

while (<STDIN>){

    chomp;
    if( $debug ) {  
        print "I--|$_\n";
    } 

    if( $debug ) { 
        $save = $_; 
        $save =~ s/[\[\]\(\)*+]/ /g;
    }

    #-------------------------------------------------
    # special ad-hoc handlings
    #  + square brackets enclosing words
    # s/([^a-z])\[([a-z]+)\]/$1$2/g;
    s/\[([a-z]+)\]/$1/g;

    s/^[^a-zA-Z0-9_<]+//g;
    s/[^a-zA-Z0-9_>]+$//g;

    #-------------------------------------------------
    # non-alpha "isolated" characters
    #
      s/ +([^[:alnum:]]+) +/ /g;
      s/([[:alnum:]]+)(?<![A-Z])([^[:alnum:] ]+) +/$1 /g;
      s/([A-Z]+>)([^[:alnum:]]+) +/$1 /g;
      s/ +([^[:alnum:] ]+)(?![A-Z])([[:alnum:]]+)/ $2/g;
      s/ +([^[:alnum:]]+)(<[A-Z]+)/ $2/g;
      s/^([^[:alnum:]<]+)//;
      s/([^[:alnum:]>]+)$//;

      s/([a-z>])[-]+([<a-z])/$1\n$2/g;

    #===========================================================
    # always good to tidy up spaces
    # s| +| |g;
    # s| +$||;
    # s|^ +||;

    #===========================================================
    # s|[\x00-\x7F]| |g;
    # s| +||g;
    # s| +$||g;
    # s|^ +||g;
    # if(/[^\x00-\x7F]/) { s|(.)|$1\n|g; } 
    # if(/[^\x00-\x7F]/) { s|^|X: |; s|$|]|; } 
    #-----------------------------------------------------------

    #----
    $str="O";
    if( $debug ) { if( "X$_" !~ "X$save" ) { $str="X"; } }
    if( !$print2file ) {
        if( $debug ) { printf "%1s--|%-s\n", $str, $_; print "-----\n"; } else { print "$_\n"; }
    }

    # if( $debug ) { print "O--|$_\n"; print "-----\n"; } else { print "$_\n"; }

    # it does not catch cases like:
    #    text ,1234...
    
}

exit;
################################################################################
