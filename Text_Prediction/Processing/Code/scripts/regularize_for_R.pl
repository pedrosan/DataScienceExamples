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
GetOptions ('d|debug' => \$debug );

while (<STDIN>) {

    chomp;
    if( $debug ) {  
        print "I: $_\n";
    } 

    #=========================================================================================
    # NUMBER RELATED
    #=========================================================================================
    
    #---------------------------------------
    # dates
    #-------
    if(/(?<![[:alnum:]\/])[0-9]{1,2}[\-\/][0-9]{1,2}[\-\/][0-9]{2,4}(?!([[:alnum:]\/]|:[0-9]))|(?<![[:alnum:]\/])[0-9]{2,4}[\-\/][0-9]{1,2}[\-\/][0-9]{1,2}(?!([[:alnum:]\/]|:[0-9]))/gi) { 
         s/(?<![[:alnum:]\/])([0-9]{1,2}[\-\/][0-9]{1,2}[\-\/][0-9]{2,4})(?![[:alnum:]\/])|(?<![[:alnum:]\/])([0-9]{2,4}[\-\/][0-9]{1,2}[\-\/][0-9]{1,2})(?![[:alnum:]\/])/<DATE>/gi;
    } 

    #---------------------------------------
    # hours am/pm
    #-------------
    s/\b([0-9]+(?:[:.][0-9]{1,2})?) *(a|p)m([^[:alpha:]]|$)/<HOUR>$3/gi;

    #---------------------------------------
    # hours a.m./p.m.
    #-------------
    s/\b([0-9]+(?:[:.][0-9]{1,2})?) *(a|p)\.m\.([^[:alpha:]]|$)/<HOUR>$3/gi; 
    # s/\b([0-9]+(?:[:.][0-9]{1,2})?) +(a|p)\.m\.([^[:alpha:]]|$)/<HOUR_$1$2m_HOUR>$3/gi; 
    # s/\b([0-9]+(?:[:.][0-9]{1,2})?) \b(a|p)\.m\.([^[:alpha:]]|$)/<HOUR_$1$2m_HOUR>$3/gi; 

    #---------------------------------------
    # dollar amounts
    #----------------
    s/([^[:alnum:]_]*)(\$[[:digit:],.-]*[[:digit:]][-]*[[:alpha:]]*)\b/$1 <DOLLARAMOUNT> /gi;

    #---------------------------------------
    # percentages
    #-------------
    s/%+/%/g;
    s/ %([0-9]+) / $1% /gi;     
    s/([0-9])\.{2,}([0-9]+%)/$1$2/gi;
    s/([[:alpha:]])\.{2,}([0-9]+%)/$1 $2/gi;
    s/\b([0-9.-]*[0-9][0-9.-]*) ?%(?![[:alpha:]])/<PERCENTAGE> /gi; 


    #=========================================================================================
    # ACRONYMS
    #=========================================================================================
    
    #---------------------------------------
    # acronyms: US
    #--------------
    
    s/(^|[ ("-])\bu\.s\.a([^[:alpha:]]|$)/$1<USA>$2/gi; 
    s/(^|[ ("-])\bu\.s\./$1<USA>/gi; 
    
    #------------------------------------------------
    # DOLLAR
    #---------
    s/[a@]\$\$/<ASS>/gi;

    s/([a-z]) \${2,} /$1 <MONEY> /gi;
    s/ \${2,} ([a-z.])/ <MONEY> $1/gi;
    s/ \${2,}([,\!])/ <MONEY>$1/gi;
    s/([a-z]) \${2,}([.?])/$1 <MONEY>$2/gi;
    s/ \${2,}$/ <MONEY>/gi;


    #=========================================================================================
    # CONTRACTIONS
    #=========================================================================================
    
    #s/\b(I|he|it|she|they|we|who|you)'ll\b/$1_ll/gi;

    #---------------------------------------
    # 'll ==> _will / " will" ==> _will
    #----------------
    s/\b(I|you|he|it|she|we|they|who|there)'ll\b/$1_will/gi;
    s/\b(I|you|he|it|she|we|they|who|there) +will\b/$1_will/gi;

    #---------------------------------------
    # n't ==> _not
    #----------------
    s/\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need)n't\b/$1_not/gi;
    s/\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need) +not\b/$1_not/gi;

    #---------------------------------------
    # 're ==> _are
    #----------------
    s/\b(they|you|we)'re\b/$1_are/gi;
    s/\b(they|you|we) +are\b/$1_are/gi;

    #---------------------------------------
    # 've ==> _have
    #----------------
    s/\b(I|you|we|they|would|should|could|must|might)'ve\b/$1_have/gi;
    s/\b(I|you|we|they|would|should|could|must|might) +have\b/$1_have/gi;

    #---------------------------------------
    # ad hoc
    #----------------
    s/\b(can)'t\b/can_not/gi;
    s/\b(can) +not\b/can_not/gi;

    s/\b(won)'t\b/will_not/gi;
    s/\b(will) +not\b/will_not/gi;

    s/\b(ain)'t\b/is_not/gi;

    s/\b(shan)'t\b/shall_not/gi;
    s/\b(shall) +not\b/shall_not/gi;

    s/\b(I)'m\b/I_am/gi;
    s/\b(I) am\b/I_am/gi;
    s/\bam I\b/am_I/gi;

    #---------------------------------------
    # 'd ==> _d 
    # VERY UNSURE ABOUT THIS ONE..
    #----------------
    # s/\b(I|you|he|she|it|we|they)'d\b/$1_d/gi;

    #---------------------------------------
    # 's ==> _s
    #----------------
    s/\b(it)'s/$1_s/gi;
    s/\b(he)'s/$1_s/gi;
    s/\b(she)'s/$1_s/gi;
    s/\b(that)'s/$1_s/gi;
    s/\b(there)'s/$1_s/gi;
    s/\b(what)'s/$1_s/gi;
    s/\b(let)'s/$1_s/gi;
    s/\b(here)'s/$1_s/gi;
    s/\b(who)'s/$1_s/gi;
    s/\b(how)'s/$1_s/gi;
    s/\b(where)'s/$1_s/gi;

    s/\b(it) +is/$1_is/gi;
    s/\b(he) +is/$1_is/gi;
    s/\b(she) +is/$1_is/gi;
    s/\b(that) +is/$1_is/gi;
    s/\b(there) +is/$1_is/gi;


    #---------------------------------------
    # additional possibly useful/meaningful replacements
    #---------------------------------------
    s/\by'all\b/you/gi;
    s/\bya'll\b/you/gi;
    s/\bma'am\b/madam/gi;
    s/\bo'clock\b/o_clock/gi;

    #---------------------------------------
    # additional, ad hoc replacements
    #---------------------------------------
    s/\bc'mon\b/come on/gi;

    #=========================================================================================
    # WHITE SPACES
    #=========================================================================================
    
    #---------------------------------------
    # fixing some punctuation and white space
    #---------------------------------------
    s/([[:alpha:]]),([[:alpha:]])/$1, $2/g;
    s/([[:alpha:]]) ,([[:alpha:]])/$1, $2/g;
    s/([[:alpha:]]) , ([[:alpha:]])/$1, $2/g;

    #=========================================================================================
    # PROFANITIES
    #=========================================================================================
    
    s/\b((shit|piss|fuck|cunt|cocksuck|motherfuck|tits)[[:alpha:]]{0,12})\b/<PROFANITY>/gi;
    #s/\b((shit|piss|fuck|cunt|cocksuck|motherfuck|tits)[[:alpha:]]{0,12})\b/<PROFANITY_$1_PROFANITY>/gi;
    
    #=========================================================================================
    #
    s/\b(a|an|as|at|no|of|on|or|by|so|up|or|no|in|to)\b//gi;

    #---------------------------------------
    # squeezing extra white spaces
    #------------------------------
    s/ +/ /g;
    s/^ +//g;
    s/ +$//g;

    
    if( $debug ) {  
        print "O: $_\n";
        print "-----\n";
    } else {
        print "$_\n";
    }

}

#-----------------------------------------------------------
