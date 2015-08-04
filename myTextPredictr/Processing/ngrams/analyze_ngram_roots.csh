#!/bin/tcsh -f 


set INFILE="PAP3"

set column=3

egrep -v '^#' $INFILE | awk -v ncol=$column 'BEGIN{FS=";"}{print $ncol}' | sort -k 1n | uniq -c | sort -k 1nr -k 2nr | awk '{n=$1*$2;sum+=n;printf " %7d %7d  %8d\n", $1,$2,n}' >! ${INFILE}_tmp1a
egrep -v '^#' $INFILE | awk -v ncol=$column 'BEGIN{FS=";"}{print $ncol}' | sort -k 1n | uniq -c | sort -k 2nr -k 1nr | awk '{n=$1*$2;sum+=n;printf " %7d %7d  %8d\n", $1,$2,n}' >! ${INFILE}_tmp1b

set Ntot1=` awk '{s+=$1}END{print s}' ${INFILE}_tmp1a `
if( $column == 2 ) set Ntot2=` egrep ' Cumulative ' $INFILE | awk '{print $7}' `
if( $column == 3 ) set Ntot2=` egrep ' processed ' $INFILE | awk '{print $7}' `

awk -v Ntot1=$Ntot1 -v Ntot2=$Ntot2 -v NN=$Ntot2 '{dn1=$1; dn2=$3; Ntot1-=prev1; Ntot2-=prev2; prev1=dn1; prev2=dn2; printf "  %-s  %8d  %9d  %9.5f\n", $0, Ntot1, Ntot2, 100*Ntot2/NN}' ${INFILE}_tmp1a >! ${INFILE}_tmp2a
awk -v Ntot1=$Ntot1 -v Ntot2=$Ntot2 -v NN=$Ntot2 '{dn1=$1; dn2=$3; Ntot1-=prev1; Ntot2-=prev2; prev1=dn1; prev2=dn2; printf "  %-s  %8d  %9d  %9.5f\n", $0, Ntot1, Ntot2, 100*Ntot2/NN}' ${INFILE}_tmp1b >! ${INFILE}_tmp2b

