#!/usr/bin/awk -f 

BEGIN{
   FS = "";
}
{
  #for (i = 1; i <= NF; i = i + 1) { print "ch", i, "is : ", $i }
  #for (i = 1; i <= NF; i = i + 1) { print $i }
   for (i = 1; i <= NF; i = i + 1) { printf "[%s]\n", $i }
}
