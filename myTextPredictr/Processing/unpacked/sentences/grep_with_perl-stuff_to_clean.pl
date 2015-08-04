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

    #==================================================
    # [3] TAGS
    #--------------------------------------------------
    # [a] CONSECUTIVE IDENTICAL TAGS
    #----
    # s/(<[A-Z]+>)([[:space:]]*?\1)+/$1/g;
    
    ## s/(<[A-Z]+>)( +\1)+/$1_FIXEDTAG/g;
    ## s/(<[A-Z]+>)( +\1)+/$1/g;
    ## s/(<[A-Z]+>)([^[:alnum:]]+\1)+/$1_FIXEDTAG/g;
    ## s/(<[A-Z]+>)([[:space:]]*?\1)+/$1_FIXEDTAG/g;

    $cleanTAGS=1;
    if( $cleanTAGS ) {
    #--------------------------------------------------
    # [b] remove TAGS enclosed in parenthesis
    #----
      s/ +\( *<[A-Z]+> *\) +/ <REMOVED1>/g;
      s/ +\( *<[A-Z]+> *\)([^[:alpha:]])/<REMOVED2>$1/g;
      s/ +\( *<[A-Z]+> *\)/ <REMOVED3>/g;
      s/\( *<[A-Z]+> *\) +/<REMOVED4> /g;
    
    #--------------------------------------------------
    # [c] remove USELESS tags
    #----
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/ <TAGREMOVED1>/g;
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]])/<TAGREMOVED2>$2/g;
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>/ <TAGREMOVED3>/g;
      s/^<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/<TAGREMOVED4>/g;
      s/<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/<TAGREMOVED5> /g;
      s/([^[:alpha:] ]+)<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:] ]*)$/$1<TAGREMOVED6>/g;
      s/([^[:alpha:] ]+)<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:] ])+/$1<TAGREMOVED7>$3/g;
      s/<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]]*)$/$1<TAGREMOVED8>/g;
    
    #==================================================
    # [4] REMOVE EXCESS SPACE
    #--------------------------------------------------
    # removed excess space at the beginning
      s|^ +||;
    # removed excess space at the end
      s| +$||;
    # removed excess space in the middle
      s| +| |;

    }

    #==================================================
    # [5] CLEAN NON-ALPHA BEGINNING OF SENTENCE
    #--------------------------------------------------
    # [a] clean sentences "bracketed" by quotes or parenthesis (removing the "bracketing" character")
    #----
    # s/^" *([^"]+) *"$/<BRACKETED>$1/g;
    # s/^" *([^"]+) *"([?!.])$/<BRACKETED>$1$2/g;
    # s/^" *([^"]+) *([?!.]) *"$/<BRACKETED>$1$2/g;

    # s/^\( *([^()]+) *\)$/<BRACKETED>$1/g;
    # s/^\( *([^()]+) *\)([?!.])$/<BRACKETED>$1$2/g;
    # s/^\( *([^()]+) *([?!.]) *\)$/<BRACKETED>$1$2/g;

    # s/^'' *(.+) *''$/<BRACKETED>$1/g;
    # s/^' *([^']+) *'$/<BRACKETED>$1/g;
    # s/^' *([^']+) *'([?!.])$/<BRACKETED>$1$2/g;
    # s/^' *([^']+) *([?!.]) *'$/<BRACKETED>$1$2/g;

    #--------------------------------------------------
    # [b] remove beginning quotes not paired in the rest of the sentence.
    #----
    # if(/^"[^"]+$/){s/^" */<CLEANED1>/;}
    # if(/^'[^']+$/){s/^' */<CLEANED2>/;}

    #--------------------------------------------------
    # [c] bracketed TAGS - just remove them
    #----
    # s/^ *\( *<[A-Z]+> *\) */<CLEANED>/;

    #--------------------------------------------------
    # [d] non-alpha preceding a TAG (done separately to make life simpler)
    #----
    # s/^[^[:alpha:]]+(<[A-Z]+>)/$1/; 

    #--------------------------------------------------
    # [e] catching up with more fixes for beginning
    #----
    # if(/^" +[^"]+"/){s/^" */"/;}
    # if(/^\( +[^(]+\)/){s/^\( */(/;}
    #
    # if(/^\([^()]+$/){s/^\( *//;}
    # s/^(?=[^"(<]+?[(" ]*[[:alpha:]])[^[:alpha:]]+([(" ]*[[:alpha:]])/$1/g;
    
    # s/^(?=[^"(<]+[[:alpha:]])[^[:alpha:]]+([[:alpha:]])/<CLEANED5>$1/g;
    # s/^(?=(?:[^"(]+[[:alpha:]]))[^[:alpha:]]+([[:alpha:]])/<CLEANED4>$1/g;
    # s/^[-~:&,;/.|#=] ([[:alpha:]])/<CLEANED2>$1/g;'

    # NOTE: AFTER THESE it is necessary to re-run the part about "bracketed" lines
    
    #--------------------------------------------------
    # REDO
    #--------------------------------------------------
    # [f] clean sentences "bracketed" by quotes or parenthesis (removing the "bracketing" character")
    #----
    # s/^" *([^"]+) *"[^[:alpha:]"?!.]*$/<BRACKETED1>$1/g;
    # s/^" *([^"]+) *"([?!.])[^[:alpha:]"?!.]*$/<BRACKETED1>$1$2/g;
    # s/^" *([^"]+) *([?!.]) *"[^[:alpha:]"?!.]*$/<BRACKETED1>$1$2/g;

    # s/^\( *([^()]+) *\)[^[:alpha:])?!.]*$/<BRACKETED2>$1/g;
    # s/^\( *([^()]+) *\)([?!.])[^[:alpha:])?!.]*$/<BRACKETED2>$1$2/g;
    # s/^\( *([^()]+) *([?!.]) *\)[^[:alpha:])?!.]*$/<BRACKETED2>$1$2/g;

    # s/^'' *(.+) *''[^[:alpha:]'?!.]*?$/<BRACKETED3>$1/g;
    # s/^' *([^']+) *'[^[:alpha:]'?!.]*?$/<BRACKETED3>$1/g;
    # s/^' *([^']+) *'([?!.])[^[:alpha:]'?!.]*?$/<BRACKETED3>$1$2/g;
    # s/^' *([^']+) *([?!.]) *'[^[:alpha:]'?!.]*?$/<BRACKETED3>$1$2/g;


    #==================================================
    # [6] CLEAN NON-ALPHA END OF SENTENCE
    #--------------------------------------------------
    # [a] clean extra spaces before "good" sentence endings
    #----
    # s/ +\.$/.<CAUGHT>/g;

    # s/ +"$/"<CAUGHT>/g;
    # s/ +"([?!.])$/"$1<CAUGHT>/g;
    # s/ +([?!.]) *"$/$1"<CAUGHT>/g;

    # s/ +\)$/)<CAUGHT>/g;
    # s/ +\)([?!.])$/)$1<CAUGHT>/g;
    # s/ +([?!.]) *\)$/$1)<CAUGHT>/g;
    
    # s/ +''$/''<CAUGHT>/g;
    # s/ +'$/'<CAUGHT>/g;
    # s/ +'([?!.])$/'$1<CAUGHT>/g;
    # s/ +([?!.]) *'$/$1'<CAUGHT>/g;

    #--------------------------------------------------
    # [b] cleaning orphan " ' ) ] at the end match earlier in the sentence
    #----
    $dothis=1;
    if( $dothis ) {
      s/^([^"'\(]+?)(["'\). ]+?\.|\.["'\). ]+)$/$1.<CAUGHT1>/;
      s/^([^\[]+?) *(\]+\.|\.\]+)$/$1.<CAUGHT2>/;
      s/^([^"'\(]+)(["'\)]+)$/$1<CAUGHT3>/;

      # s/^([^"'\(]+)(["'\)]+\.|\.["'\)]+)$/$1.<CAUGHT1>/;
      # s/^([^\[]+)(\]+\.|\.\]+)$/$1.<CAUGHT2>/;
      # s/^([^"'\(]+)(["'\)]+)$/$1<CAUGHT3>/;
    }

    #--------------------------------------------------
    # [c] some dirty ENDS
    #----
      s/[ .,;:~({*_^+=&#$<\/\[-]+\.$/.<CLEANEDEND>/;

    # s/[:;,* ]\.$/./;

    #  ----  27958 :.   ==> .
    #  ----   2709 ;.   ==> .
    #  ----  14869 ,.   ==> .
    #  ----   9560  .   ==> .
    #  ----   2115 *.   ==> .

    #  ----   3182  (:.

    #   OK  195586 ."
    #   OK   27620 ".
    #   OK   13395 ?"
    #   ~     1951 "?
    #   OK    9719 !"
    #   OK     885 "!
    #   OK    5734 '.
    #   ~      761 .'

    #   OK   13988 .)
    #   OK   63643 ).
    #   ~     4499 !)
    #   ~     1153 )!
    #   ~     1793 ?)
    #   OK     856 )?

    #   OK     985 !).
    #   OK     807 ").
    #  ----   1402  ).
    #  ----   2566  -.
 
    #  ----   2490 (:.
    #  ----   2098  -_-.
    #  ----   1205 -.
    #  ----   1089 /.
    #  ----    849 ) --.
    #  ----    762  : ).
    #  ----    758  (;.
    #  ----    754 ):.


    #==================================================
    # <NUMBER> meaning dollar amount
    #----
    # s/<NUMBER> (hundred|thousand|million|billion|trillion)s?\b/<NEWNUMBER>/g; 
    # s/<DOLLARAMOUNT> (hundred|thousand|million|billion|trillion)s?\b/<NEWDOLLARAMOUNT>/g; 
    
    #--------------------------------------------------
    # clear row ENDINGS with odd sequences 
    #----

    if( $debug ) { print "O--|$_\n"; print "-----\n"; } else { print "$_\n"; }

    # it does not catch cases like:
    #    text ,1234...
    
}
    
exit;
################################################################################
while(/[^#_[:alnum:]]#[#_[:alnum:]]+\b/gi){print "$&\n";}
while(/[^#_\w\d]#[#_\w\d]+\b/gi){print "$&\n";}
