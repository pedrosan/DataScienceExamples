#!/usr/bin/perl -w 

#-------------------------------------------------------------------------------
# CHARACTERS "HOMOGENEIZATION"
#   - Normalize odd characters
#   - Currency symbols
#   - HTML tags
#   - encoded apostrophe
#
# CHARACTER SEQUENCES
#   - Cleaning of BEGIN / END of LINE
#   - EOL ellipsis
#   - EOL non-sense
#   - word bracketed by *
#   - substitution on "|" that seem to be equivalent to end of sentences (i.e. a period)
#   - substitution of <==/<-- and ==>/--> with ";"
#   - sequences of !, ? 
#
# HASHTAGS
#   - 
#-------------------------------------------------------------------------------
    
use feature 'unicode_strings';  # CHECK THIS SETTING (http://perldoc.perl.org/perlunifaq.html)
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
        print "I: $_\n";
    } 

    #=========================================================================================
    # CHARACTERS "HOMOGENEIZATION"
    #=========================================================================================
    
    #---------------------------------------
    # Normalize odd characters
    s|…|...|g; 
    s|–|\-|g; 
    s|—|\-|g; 
   
    s|‘|\'|g;
    s|’|\'|g; 
    s|`|\'|g;
    s|′|\'|g;
    s|´|\'|g;
   
    s|«|"|g; 
    s|»|"|g; 
    s|”|"|g; 
    s|“|"|g;
    s|″|"|g;

    #---------------------------------------
    # Currency symbols
    s|€|EURO|g;
    s|¥|YEN|g;
    s|£|GBP|g;
    s|\$+([0-9])|\$$1|g;

    #---------------------------------------
    # HTML tags
    s|<\w+>| |gi;
    s|</\w+>| |gi;
    s|<\w+ />| |gi;

    #---------------------------------------
    # encoded apostrophe
    s|&#39;|\'|g;

    
    #=========================================================================================
    # CHARACTER SEQUENCES
    #=========================================================================================
    
    #---------------------------------------
    # Cleaning of BEGIN / END of LINE
    # EOL ellipsis
    s/([^[:space:]\.]{0,5})[[:space:]\.]+$/$1./g;
    # EOL non-sense
    s/(.{0,20}[")]?[.\!?][")]?)[^[:alnum:]]+$/$1/g;

    # s/([^[:space:]\.]{0,5})[[:space:]\.]+$/$1.<ENDofLINE>/g;
    # s/(.{0,20}[")]?[.\!?][")]?)[^[:alnum:]]+$/$1<ENDofLINE>/g;

    #print "$_\n";
    #next; 

    #---------------------------------------
    # word bracketed by *
    s|\*+([[:alnum:]]+)\*+| $1 |g;

    #---------------------------------------
    # substitution on "|" that seem to be equivalent to end of sentences (i.e. a period)
    s/(\w) +\| +/$1. /g; 
    #s|\||.|g;

    #---------------------------------------
    # substitution of <==/<-- and ==>/--> with ";"
    s/<+[=-]{2,}/; /gi;
    s/[=-]{2,}>+/; /gi;

    #---------------------------------------
    # sequences of !, ? 
    #-------------------
    # - at the end of a row
    s|\!+$|\!|g;
    s|\?+$|\?|g;

    # - anywhere else in a row (add one space just in case)
    s/ +(\!|\?)/$1/g;
    s/\!+/\!/g;
    s/\?+/\?/g;

    # - mixed sequences (?)
    s/(\!(\?\!)+\?*|\?(\!\?)+\!*)/\!\?/g;
    
    # underscores (moved to phase 2)
    # s/_+/_/g;
   
    #---------------------------------------
    # fixing other row start/end characters
    #  - * 
    #  [OBSOLETE?] [YES]
    # s|^[\*[:space:]]+||;
    # s|[\*[:space:]]+$||;
    #s|^[\*[:space:]]+|<ROW_BEGINS>|;
    #s|[\*[:space:]]+$|<ROW_ENDS>|;
    
    #=========================================================================================
    # HASHTAGS
    #=========================================================================================
    
    s/([[:space:]\(\!\".?\-\/])#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b/$1 <HASHTAG_$2_HASHTAG> /g;
    # s/([[:space:]\(\!\".?\-\/])(#(?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b/$1 <HASHTAG_$2_HASHTAG> /g;

    # ADDED 04.17 (but then included in pass5 to avoid re-processing from scratch)
    s/^#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b/<HASHTAG_$1_HASHTAG> /g;

    
    #=========================================================================================
    if( $debug ) {  
        print "O: $_\n";
        print "-----\n";
    } else {
        print "$_\n";
    }

    #---------------------------------------------------
    # "ALL_postreg_v2_r1.txt" run down to this point
    #---------------------------------------------------


    #---------------------------------------------------
    # AFTER THIS SCRIPT:
    #
    #  - emoticons
    #  - inline ellipsis
    #  - other repeated characters
    #  - contractions
    #  - squeeze extra white spaces 
    #    - inject white spaces where appropriate (?)
    #---------------------------------------------------
}

exit;

#-----------------------------------------------------------
