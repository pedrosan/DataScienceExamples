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
    # remove spaces at the end of a sentence (how there can still be some?... not sure)
    #----
    s/ +$//;

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

    #--------------------------------------------------
    # [b] remove beginning quotes not paired in the rest of the sentence.
    #----
    if(/^"[^"]+$/){s/^" *//;}
    if(/^'[^']+$/){s/^' *//;}

    #--------------------------------------------------
    # [c] bracketed TAGS - just remove them
    #----
    s/^ *\( *<[A-Z]+> *\) *//;

    #--------------------------------------------------
    # [d] non-alpha preceding a TAG (done separately to make life simpler)
    #----
    s/^[^[:alpha:]]+(<[A-Z]+>)/$1/; 

    #--------------------------------------------------
    # [e] catching up with more fixes for beginning
    #----
      if(/^" +[^"]+"/){s/^" */"/;}
      if(/^\( +[^(]+\)/){s/^\( */(/;}

      if(/^\([^()]+$/){s/^\( *//;}
      s/^(?=[^"(<]+?[(" ]*[[:alpha:]])[^[:alpha:]]+([(" ]*[[:alpha:]])/$1/g;

    # NOTE: AFTER THESE it is necessary to re-run the part about "bracketed" lines
    
    #--------------------------------------------------
    # REDO
    # [f] clean sentences "bracketed" by quotes or parenthesis (removing the "bracketing" character")
    #----
      s/^" *([^"]+) *"[^[:alpha:]"?!.]*$/$1/g;
      s/^" *([^"]+) *"([?!.])[^[:alpha:]"?!.]*$/$1$2/g;
      s/^" *([^"]+) *([?!.]) *"[^[:alpha:]"?!.]*$/$1$2/g;

      s/^\( *([^()]+) *\)[^[:alpha:])?!.]*$/$1/g;
      s/^\( *([^()]+) *\)([?!.])[^[:alpha:])?!.]*$/$1$2/g;
      s/^\( *([^()]+) *([?!.]) *\)[^[:alpha:])?!.]*$/$1$2/g;

      s/^'' *(.+) *''[^[:alpha:]'?!.]*?$/$1/g;
      s/^' *([^']+) *'[^[:alpha:]'?!.]*?$/$1/g;
      s/^' *([^']+) *'([?!.])[^[:alpha:]'?!.]*?$/$1$2/g;
      s/^' *([^']+) *([?!.]) *'[^[:alpha:]'?!.]*?$/$1$2/g;

    
    #==================================================
    # [6] CLEAN NON-ALPHA END OF SENTENCE
    #--------------------------------------------------
    # [a] clean extra spaces before "good" sentence endings
    #----
    s/ +\.$/./g;

    s/ +"$/"/g;
    s/ +"([?!.])$/"$1/g;
    s/ +([?!.]) *"$/$1"/g;

    s/ +\)$/)/g;
    s/ +\)([?!.])$/)$1/g;
    s/ +([?!.]) *\)$/$1)/g;
    
    s/ +''$/''/g;
    s/ +'$/'/g;
    s/ +'([?!.])$/'$1/g;
    s/ +([?!.]) *'$/$1'/g;

    #--------------------------------------------------
    # [b] cleaning orphan " ' ) ] at the end match earlier in the sentence
    #----
      s/^([^"'\(]+?)(["'\). ]+?\.|\.["'\). ]+)$/$1./;
      s/^([^\[]+?) *(\]+\.|\.\]+)$/$1./;
      s/^([^"'\(]+)(["'\)]+)$/$1/;

      # s/^([^"'\(]+)(["'\)]+\.|\.["'\)]+)$/$1./;
      # s/^([^\[]+)(\]+\.|\.\]+)$/$1./;
      # s/^([^"'\(]+)(["'\)]+)$/$1/;

    #--------------------------------------------------
    # [c] some dirty ENDS
    #----
      s/[ .,;:~({*_^+=&#$<\/\[-]+\.$/./;


    #--------------------------------------------------
    # <NUMBER> meaning dollar amount
    #----
    # s/<NUMBER> (hundred|thousand|million|billion|trillion)s?\b/<NEWNUMBER>/g;
    # s/<DOLLARAMOUNT> (hundred|thousand|million|billion|trillion)s?\b/<NEWDOLLARAMOUNT>/g; 

    # s/<NEWNUMBER>/<NUMBER>/g;
    # s/<DOLLARAMOUNT>/<NUMBER>/g;
    # s/<NEwDOLLARAMOUNT>/<NUMBER>/g;
    
    #--------------------------------------------------
    # remove sequences of non-alpha characters (somehow still present)
    #----
    

    #--------------------------------------------------
    # clear row BEGINNINGS with non-alpha characters
    #----
    

    #--------------------------------------------------
    # clear row ENDINGS with odd sequences 
    #----


    #================================================
    # MORE
    #--------------------------------------------------
    # check for EMPTY LINES
    #----


    #================================================
    if( $debug ) {  
        print "O: $_\n";
        print "-----\n";
    } else {
        print "$_\n";
    }

}

#-----------------------------------------------------------
