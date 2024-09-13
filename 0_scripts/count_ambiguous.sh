#!/bin/bash

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#FILE CHECK
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Assign the input filename to a variable
fasta_file=$1

# Check if the file exists
if [ ! -f "$fasta_file" ]; then
    echo "FASTA file not found!"
    exit 1
fi

#check if fasta file 
if [[ ! $fasta_file =~ \.fasta$|\.fa$ ]] ; then
	echo "file is not a fasta silly goose!"

fi

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#REMOVE LINE BREAKS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#adds # to the beginning and end of each '>'| removes all new lines | #adds new line | removes empty lin
fasta_clean=$(sed -e 's/\(^>.*$\)/#\1#/' "$fasta_file" | tr -d '\n' | sed -e 's/#/\n/g' | grep -v '^$')

echo "output of the fasta_clean step below:"
printf "%s\n" "$fasta_clean"

printf "%s\n" "$fasta_clean" > 2_mid/clean.fasta
#echo -e $fasta_clean > 2_mid/clean.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Get total count of all characters
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
echo "output of all nucleotide calls per sample:"
printf "%s\n" "$fasta_clean" | awk '!/^>/ { print length($0) }' 



#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#keep nonambiguous nucleotides and count them
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ATCG_fasta=$(echo "$fasta_clean" | sed '/^>/!s/[^ATCG]//g')

printf "%s\n" "$ATCG_fasta" > 2_mid/atcg.fasta

echo "output of all nonambiguous nucleotide calls per sample:"
printf "%s\n" "$ATCG_fasta" | awk '!/^>/ { print length($0) }' 


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#calculate nonambiguous/total to get percent nonambiguous coverage
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#echo -e "$ATCG_fasta" | sed -n '/^>/!{p;='}

#need to make it so it doesn't remove the headers
#potentially change so that it only keeps the ATCG instead of the ambiguous calls as that is more complicated


# Define a list of ambiguous nucleotide characters
#ambiguous_chars="NRYSWKMBDHV"
#cleaned_fasta=$(echo "$fasta_clean" | sed '/^>/!s/['"$ambiguous_chars"']//g')
