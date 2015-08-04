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

    #=========================================================================================
    # CONTRACTIONS
    #=========================================================================================
    
    #---------------------------------------
    # 'll ==> _will / " will" ==> _will
    #----------------
    s/\b(I|you|he|it|she|we|they|who|there)_will\b/$1 will/gi;

    #---------------------------------------
    # n't ==> _not
    #----------------
    s/\b(do|does|did|has|have|had|is|are|was|were|could|would|should|must|need)_not\b/$1 not/gi;
    s/\bdon_t\b/don't/gi;

    #---------------------------------------
    # 're ==> _are
    #----------------
    s/\b(they|you|we)_are\b/$1 are/gi;

    #---------------------------------------
    # 've ==> _have
    #----------------
    s/\b(I|you|we|they|would|should|could|must|might)_have\b/$1 have/gi;

    #---------------------------------------
    # ad hoc
    #----------------
    s/\b(can|will|is|shall)_not\b/$1 not/gi;
    s/\bI_am\b/I am/gi;
    s/\bam_I\b/am I/gi;

    #---------------------------------------
    # 's ==> _s
    #----------------
    s/\b(it|he|she|that|there|what|let|here|who|how|where)_s/$1's/gi;

    # s/\b(it)'s/$1_s/gi;
    # s/\b(he)'s/$1_s/gi;
    # s/\b(she)'s/$1_s/gi;
    # s/\b(that)'s/$1_s/gi;
    # s/\b(there)'s/$1_s/gi;
    # s/\b(what)'s/$1_s/gi;
    # s/\b(let)'s/$1_s/gi;
    # s/\b(here)'s/$1_s/gi;
    # s/\b(who)'s/$1_s/gi;
    # s/\b(how)'s/$1_s/gi;
    # s/\b(where)'s/$1_s/gi;

    s/\b(it|he|she|that|there)_is/$1 is/gi;

    # s/\b(it) +is/$1_is/gi;
    # s/\b(he) +is/$1_is/gi;
    # s/\b(she) +is/$1_is/gi;
    # s/\b(that) +is/$1_is/gi;
    # s/\b(there) +is/$1_is/gi;


    #---------------------------------------
    # additional possibly useful/meaningful replacements
    #---------------------------------------
    s/\bo_clock\b/o clock/gi;

    #---------------------------------------

    print "$_\n";

}

#-----------------------------------------------------------
