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
    # FIX missed HASHTAGS at line beginning
    #  + ADDED 04.17 to pass1 but then used here to avoid re-processing from scratch
    #----
    s/^#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b/<HASHTAG_$1_HASHTAG> /g;

    #--------------------------------------------------
    # FIX additional number capture
    #  + ADDED 04.17 just here to avoid re-processing from scratch, but it should really go in pass2
    #----
    s/\b(1[-.]|[1-9][0-9][-.])?([0-9]{3})[-. ]([0-9]{3})[-.]([0-9]{4})\b/<TELEPHONENUMBER>/gi;

    s/\b(?=[0-9][0-9.,:]*)([0-9]+:[0-9]{1,2}:[0-9]{1,2})\b/<TIMEINTERVAL>/gi;

    s/\b(?=[0-9][0-9.,:]*)([0-9.,:]+)\b/<NUMERIC_$1_NUMERIC>/gi;

    #--------------------------------------------------

    s|<DATE_[^<]+_DATE>|<DATE>|g;
    
    s|<DOLLARAMOUNT_[^<]+_DOLLARAMOUNT>|<DOLLARAMOUNT>|g;
    s|<HOUR_[^<]+m_HOUR>|<HOUR>|g;
    s|<PERCENTAGE_[^<]+%_PERCENTAGE>|<PERCENTAGE>|g;
    s|<PERCENTAGE_%_PERCENTAGE>|<PERCENTAGE>|g;

    s|<NUMERIC_[^<]+_NUMERIC>|<NUMBER>|g;
    
    s|<EMOJ_(<?)[^<]+_EMOJ>|<EMOTICON>|g;
    s|<EMOJ_HEART_EMOJ>|<EMOTICON>|g;
    
    s|<HASHTAG_[^<]+_HASHTAG>|<HASHTAG>|g;
    
    s|<PROFANITY_[^<]+_PROFANITY>|<PROFANITY>|g;
    # s|<PROFANITY_disguised_PROFANITY>
    
    s|<SPACE_MARK>|<SPACE>|g;
    s|<SPACE_NEW>|<SPACE>|g; 
    s|<SPACE_PREMOJ>|<SPACE>|g;


    s|<NUMBER>'s\b|<NUMBER>|g;
    s|#<NUMBER>|<NUMBER>|g;

    #================================================
    if( $debug ) {  
        print "O: $_\n";
        print "-----\n";
    } else {
        print "$_\n";
    }

}

#-----------------------------------------------------------
