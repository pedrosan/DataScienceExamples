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
    # [c] remove USELESS tags
    #----
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/ <TAGREMOVED1>/g;
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]])/<TAGREMOVED2>$2/g;
      s/ +<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>/ <TAGREMOVED3>/g;
      s/^<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/<TAGREMOVED4>/g;
      s/<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)> +/<TAGREMOVED5> /g;
      s/([^[:alpha:] ]+)<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:] ]*)$/$1<TAGREMOVED6>/g;
      s/([^[:alpha:] ]+)<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:] ])+/$1<TAGREMOVED7>$3/g;
      s/<(NUMBER|PERCENTAGE|EMOTICON|HASHTAG|TELEPHONENUMBER)>([^[:alpha:]]*)$/<TAGREMOVED8>/g;
    
    #--------------------------------------------------
    # [b] cleaning orphan " ' ) ] at the end match earlier in the sentence
    #----

      s/^([^"'\(]+?)(["'\). ]+?\.|\.["'\). ]+)$/$1.<CAUGHT1>/;
      s/^([^\[]+?) *(\]+\.|\.\]+)$/$1.<CAUGHT2>/;
      s/^([^"'\(]+)(["'\)]+)$/$1<CAUGHT3>/;

    #--------------------------------------------------
    # [c] some dirty ENDS
    #----
      s/[ .,;:~({*_^+=&#$<\/\[-]+\.$/.<CLEANEDEND>/;


    #----
    if( $debug ) { print "O--|$_\n"; print "-----\n"; } else { print "$_\n"; }

    # it does not catch cases like:
    #    text ,1234...
    
}
    
exit;
################################################################################
while(/[^#_[:alnum:]]#[#_[:alnum:]]+\b/gi){print "$&\n";}
while(/[^#_\w\d]#[#_\w\d]+\b/gi){print "$&\n";}
