#!/usr/bin/perl -w 

#-------------------------------------------------------------------------------
# CONTRACTIONS
#   - 'll ==> _will / " will" ==> _will
#   - n't ==> _not
#   - 're ==> _are
#   - 've ==> _have
#   - some additional ad hoc
#   - 's ==> _s
#   - additional possibly useful/meaningful replacements (e.g. y'all)
#
# WHITE SPACES
#   - squeezing extra white spaces
#   - fixing some punctuation and white space
#
# PROFANITIES
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

while (<STDIN>) {

    chomp;
    if( $debug ) {  
        print "I: $_\n";
    } 

    #=========================================================================================
    # CONTRACTIONS
    #=========================================================================================
    
    #---------------------------------------
    # 'll ==> _will / " will" ==> _will
    #----------------
    s/\b(I|you|he|it|she|we|they|who|there)'+ll\b/$1_will/gi;
    s/\b(I|you|he|it|she|we|they|who|there) +will\b/$1_will/gi;
    s/\b(this|that|which|what)'+ll\b/$1 will/gi;    # NEW 04.20
    s/\bu'+ll\b/you_will/gi;                        # NEW 04.20

    #---------------------------------------
    # n't ==> _not
    #----------------
    s/\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need)n'+t\b/$1_not/gi;
    s/\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need) +not\b/$1_not/gi;

    #---------------------------------------
    # 're ==> _are
    #----------------
    s/\b(they|you|we)'+re\b/$1_are/gi;
    s/\b(they|you|we) +are\b/$1_are/gi;

    #---------------------------------------
    # 've ==> _have
    #----------------
    s/\b(I|you|we|they|would|should|could|must|might)'+ve\b/$1_have/gi;
    s/\b(I|you|we|they|would|should|could|must|might) +have\b/$1_have/gi;

    #---------------------------------------
    # ad hoc
    #----------------
    s/\b(can)'+t\b/can_not/gi;
    s/\b(can) +not\b/can_not/gi;

    s/\b(won)'+t\b/will_not/gi;
    s/\b(will) +not\b/will_not/gi;

    s/\b(ain)'+t\b/is_not/gi;

    s/\b(shan)'+t\b/shall_not/gi;
    s/\b(shall) +not\b/shall_not/gi;

    s/\b(I)'+m\b/I_am/gi;
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
    s/\b(it)'+s/$1_s/gi;
    s/\b(he)'+s/$1_s/gi;
    s/\b(she)'+s/$1_s/gi;
    s/\b(that)'+s/$1_s/gi;
    s/\b(there)'+s/$1_s/gi;
    s/\b(what)'+s/$1_s/gi;
    s/\b(let)'+s/$1_s/gi;
    s/\b(here)'+s/$1_s/gi;
    s/\b(who)'+s/$1_s/gi;
    s/\b(how)'+s/$1_s/gi;
    s/\b(where)'+s/$1_s/gi;

    s/\b(it) +is/$1_is/gi;
    s/\b(he) +is/$1_is/gi;
    s/\b(she) +is/$1_is/gi;
    s/\b(that) +is/$1_is/gi;
    s/\b(there) +is/$1_is/gi;


    #---------------------------------------
    # additional possibly useful/meaningful replacements
    #---------------------------------------
    s/\by'+all\b/you/gi;
    s/\bma'+am\b/madam/gi;
    s/\bo'+clock\b/o_clock/gi;
    s/\bya'+ll\b/you/gi;     # NEW 04.20
    s/\by'+ll\b/you/gi;      # NEW 04.20

    #---------------------------------------
    # additional, ad hoc replacements
    #---------------------------------------
    # s/\bc'mon\b/come on/gi;

    #=========================================================================================
    
    if( $debug ) {  
        print "O: $_\n";
        print "-----\n";
    } else {
        print "$_\n";
    }

}

#-----------------------------------------------------------
