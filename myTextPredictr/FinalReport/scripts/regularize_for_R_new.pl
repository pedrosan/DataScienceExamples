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
    # CHARACTER SEQUENCES and other small things
    #=========================================================================================
    
    #---------------------------------------
    # Cleaning of BEGIN / END of LINE
    # EOL ellipsis
    s/([^[:space:]\.]{0,5})[[:space:]\.]+$/$1./g;
    # EOL non-sense
    s/(.{0,20}[")]?[.\!?][")]?)[^[:alnum:]]+$/$1/g;

    #---------------------------------------
    # word bracketed by *
    s|\*+([[:alnum:]]+)\*+| $1 |g;

    #---------------------------------------
    # substitution on "|" that seem to be equivalent to end of sentences (i.e. a period)
    s/(\w) +\| +/$1. /g; 

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
    
    #=========================================================================================
    # HASHTAGS
    #=========================================================================================
    
    s/([[:space:]\(\!\".?\-\/])#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b/$1 <HASHTAG> /g;

    # ADDED 04.17 (but then included in pass5 to avoid re-processing from scratch)
    s/^#((?!(?:[a-z_]*[0-9]){5})[_[:alnum:]]*[[:alpha:]][_[:alnum:]]*)\b/<HASHTAG> /g;
    
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
    
    #=========================================================================================
    # REPEATED CHARACTERS
    #=========================================================================================
    
    #------------------------------------------------
    # DOLLAR
    #---------
    s/[a@]\$\$/<ASS>/gi;
    s/<ASS>hole[[:alpha:]]*\b/<PROFANITY>/gi;

    s/([a-z]) \${2,} /$1 <MONEY> /gi;
    s/ \${2,} ([a-z.])/ <MONEY> $1/gi;
    s/ \${2,}([,\!])/ <MONEY>$1/gi;
    s/([a-z]) \${2,}([.?])/$1 <MONEY>$2/gi;
    s/ \${2,}$/ <MONEY>/gi;

    #------------------------------------------------
    # +
    #---------
    s/\+{3,}/ /g;
    s/[^AC]\+\+/ /g;

    #------------------------------------------------
    # -
    # "a -- b" ==> replace with ","
    # "a--b"   ==> replace with ","
    # "! -- A" ==> REMOVE
    # "A--A[a ']" ==> replace with ";"
    # "a-- A" ==> replace with ";"
    # "a-- a" ==> replace with ","
    # "! --A" ==> REMOVE
    #---------
    s/([a-z]) +-{2,} +([a-z])/$1, $2/g;
    s/([a-z])-{2,}([a-z])/$1, $2/g;
    s/([^[:alnum:]]) +-{2,} +([A-Z])/$1 $2/g;
    s/([[:alpha:]])\-{2,}([[:alpha:]][[:alpha:] \'])/$1\; $2/g;
    s/([a-z])-{2,} +([A-Z])/$1; $2/g;
    s/([a-z])-{2,} +([a-z])/$1, $2/g;
    s/([^[:alnum:]]) -{2,}([A-Z])/$1 $2/g;
    s/([0-9]) +-{2,} +([a-z])/$1, $2/g;
    s/([0-9])-{2,}([a-z])/$1, $2/g;

    #------------------------------------------------
    # LEAVE ONE (followed by space) : ,
    #---------
    # s/([,])\1+/\1 /g;
    s/([,])\1+/$1 /g;

    #------------------------------------------------
    # LEAVE ONE : _  (the % is handled separately when dealing with percentages)
    #---------
    # s/([_])\1+/\1/g;
    s/([_])\1+/$1/g;
    # s/([%_])\1+/\1/g;

    #------------------------------------------------
    # REMOVE ENTIRELY if 2+ : < > = #
    #---------
    s/([<>=#])\1+/ /g;

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
    # MORE TAGS AND ABBREVIATIONS
    #=========================================================================================
    
    #--------------------------------------------------
    # N-word  change something like <NUMBER>-word
    #----
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

    #--------------------------------------------------
    # clean consecutive TAGS
    #----
    s/(<[A-Z]+>)([^[:alnum:]]+\1)+/$1/g;

    #--------------------------------------------------
    # remove <PERIOD>
    #----
    s/\.<PERIOD>/./g;
    s/([[:alpha:]])<PERIOD> /$1 /g;


    #--------------------------------------------------
    # remove <SPACE>
    #----
    s/ +<SPACE> +/ /g;
    s/^<SPACE> +//g;
    s/ +<SPACE>([^[:alnum:]]+)$/$1/g;

    #--------------------------------------------------
    # remove <WEIRDO>
    #----
    #s/<WEIRDO>//g;
    
    #--------------------------------------------------
    # remove quotes from single quoted words
    #----
    s/([^[:alpha:]])["']([[:alpha:]\-_]+)["']([^[:alpha:]])/$1$2$3/g;
    

    #--------------------------------------------------
    # clear row BEGINNINGS with non-alpha characters
    #----
    s|^(?![^[:alpha:]]*<[A-Z])([^[:alpha:]\n]+)||;    

    
    #=========================================================================================
    # 
    #=========================================================================================
    #
    #--------------------------------------------------
    # [2] ASS and PROFANITY
    #----
    s/<ASS>/<PROFANITY>/g;
    s/<PROFANITY>hole[[:alpha:]]*\b/<PROFANITY>/g;

    #==================================================
    # [3] TAGS
    #--------------------------------------------------
    # [a] CONSECUTIVE IDENTICAL TAGS
    #----
    s/(<[A-Z]+>)([[:space:]]*?\1)+/$1/g;

    #--------------------------------------------------
    # [b] remove TAGS enclosed in parenthesis
    #----
      s/ +\( *<[A-Z]+> *\) +/ /g;
      s/ +\( *<[A-Z]+> *\)([^[:alpha:]])/$1/g;
      s/ +\( *<[A-Z]+> *\)/ /g;
      s/\( *<[A-Z]+> *\) +/ /g;
    
    #--------------------------------------------------
    # [c] remove USELESS tags
    #----
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/ /g;
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]])/$2/g;
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>/ /g;
      s/^<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +//g;
      s/<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/ /g;
      s/([^[:alpha:] ]+)<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:] ]*)$/$1/g;
      s/([^[:alpha:] ]+)<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:] ])+/$1/g;
      s/<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]]*)$//g;

    #==================================================
    # [5] REMOVE EXCESS SPACE
    #--------------------------------------------------
    # removed excess space at the beginning
    s|^ +||;
    # removed excess space at the end
    s| +$||;
    # removed excess space in the middle
    s| +| |;

    #==================================================
    # [5] CLEAN NON-ALPHA BEGINNING OF SENTENCE
    #--------------------------------------------------
    # [a] clean sentences "bracketed" by quotes or parenthesis (removing the "bracketing" character")
    #----
    s/^" *([^"]+) *"$/$1/g;
    s/^" *([^"]+) *"([?!.])$/$1$2/g;
    s/^" *([^"]+) *([?!.]) *"$/$1$2/g;

    s/^\( *([^()]+) *\)$/$1/g;
    s/^\( *([^()]+) *\)([?!.])$/$1$2/g;
    s/^\( *([^()]+) *([?!.]) *\)$/$1$2/g;
    
    s/^'' *(.+) *''$/$1/g;
    s/^' *([^']+) *'$/$1/g;
    s/^' *([^']+) *'([?!.])$/$1$2/g;
    s/^' *([^']+) *([?!.]) *'$/$1$2/g;

    
    #=========================================================================================
    # STOP WORDS
    #=========================================================================================
    s/\b(a|an|as|at|no|of|on|or|by|so|up|or|no|in|to|rt)\b//gi;

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
