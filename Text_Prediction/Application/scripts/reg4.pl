#!/usr/bin/perl -w 

#---------------------------------------------------------------------------------------------------

use feature 'unicode_strings';  # CHECK THIS SETTING (http://perldoc.perl.org/perlunifaq.html)
use utf8;

# use Text::Unidecode;
binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

use Getopt::Long;
Getopt::Long::Configure('no_ignore_case');

$debug=0;
GetOptions ('d|debug' => \$debug );

while (<STDIN>) {

    chomp;
    if( $debug ) {  
        print "I: $_\n";
    } 

    #--------------------------------------------------
    # N-word  change something like <NUMBER>-word
    #----
    # s/([[:space:]])([1-9]*[0-9]+)([-]*(th|st|rd|nd)(?<!-))/$1<ORDINAL>/gi;
    # s/([[:space:]])([1-9]*[0-9]+)([-]*(th|st|rd|nd))(?![[:alpha:]])/$1<ORDINAL>/gi;
    s/([[:space:]])([1-9]*[0-9]+)([-]*(th|st|rd|nd)s?)(?![[:alpha:]])/$1<ORDINAL>/gi;

    s/ ([']*[1-9]*[0-9]+)([-]*s(?![[:alpha:]]))/ <DECADE>/gi; 

    s/([[:space:]])([0-9]+[0-9,]*)([-]*[[:alpha:]-]+(?<!-))/$1<NUMBER>$3/gi;

    
    #--------------------------------------------------
    # standard/common abbreviations
    #----
    s/\b(Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)\./<MONTH_$1_MONTH>/gi; 
      
    s/\b(Mr|Mrs|Ms|Miss|Drs?|Profs?|Sens?|Reps?|Attys?|Lt|Col|Gen|Messrs|Govs?|Adm|Rev|Maj|Sgt|Cpl|Pvt|Mt|Capt|Ste?|Ave|Pres|Lieut|Hon|Brig|Co?mdr|Pfc|Spc|Supts?|Det)\./<ABBREV_$1_ABBREV>/gi;

    s/\b(Jr|Sr|Bros|Ph\.D|Blvd|Rd|Esq)\./<ABBREV_$1_ABBREV>/gi; 
    s/<ABBREV_Ph\.D_ABBREV>/<ABBREV_PhD_ABBREV>/gi;

    s/\b(Nos?|Prop|Ph|tel|est|ext|sq|ft)\./<ABBREV_$1_ABBREV>/gi; 

    # Most of these abbreviations should probably be left in, just with the removed "."
    s/<MONTH_([^<]+)_MONTH>/$1/gi;
    s/<ABBREV_([^<]+)_ABBREV>/$1/gi;

    #--------------------------------------------------
    # remove genitives
    #----
    # s|\b([[:alpha:]]+)'s\b|$1|gi;
    s|\b([[:alnum:]]+)'s\b|$1|gi;
    # NOTE: changed to :alnum: on 04/17, but just re-run at the command line
    
    #--------------------------------------------------
    # line endings preceded by spurious spaces
    #----
    s| +(.)$|$1|;

    #================================================
    # MORE
    #--------------------------------------------------
    # '' ==> "
    #----
    s/([^[:alpha:]]?)(''|")([[:alnum:]_, ]+)(''|")([^[:alpha:]])/$1"$3"$5/gi; 
    s/^''//g;
    s/,'' /," /g;
    s/\.'' /." /g;
    s/\. ''([A-Z])/. "$1/g;
    s/: ''([[:alpha:]])/: "$1/g;

    #================================================
    if( $debug ) {  
        print "O: $_\n";
        print "-----\n";
    } else {
        print "$_\n";
    }

}

#-----------------------------------------------------------
