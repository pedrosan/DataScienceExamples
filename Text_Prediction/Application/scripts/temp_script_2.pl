#!/usr/bin/perl -w 

use utf8;
# use Text::Unidecode;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

use Getopt::Long;
Getopt::Long::Configure('no_ignore_case');

$debug=0;
GetOptions ('d|debug' => \$debug );

while (<STDIN>){
    
    chomp;
    if( $debug ) {  
        print "I--|$_\n";
    } 

    #--------------------------------------------------
    # more lines BEGINNING with TAGS and non-alpha
    #----
      s/^(<[A-Z]+>[^[:alpha:] <]+ *)//g;
      s/^(<[A-Z]+>[^[:alpha:] <]+ *)//g;
      s/^(<[A-Z]+>[^[:alpha:] <]+ *)//g;

    #----
    if( $debug ) { print "O--|$_\n"; print "-----\n"; } else { print "$_\n"; }

    # it does not catch cases like:
    #    text ,1234...
    
}
    
exit;
################################################################################
while(/[^#_[:alnum:]]#[#_[:alnum:]]+\b/gi){print "$&\n";}
while(/[^#_\w\d]#[#_\w\d]+\b/gi){print "$&\n";}
