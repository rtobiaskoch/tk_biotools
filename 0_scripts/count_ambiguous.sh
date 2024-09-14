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

echo "fasta file output of the fasta_clean step below:"
printf "%s\n" "$fasta_clean"
echo -e "\n"

printf "%s\n" "$fasta_clean" > 2_mid/clean.fasta
#echo -e $fasta_clean > 2_mid/clean.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#COUNT ALL CALLS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
echo "output of all nucleotide calls per sample:"
all_count=$(printf "%s\n" "$fasta_clean" | awk '!/^>/ { print length($0) }') 
printf "%s\n" "$all_count"
printf "%s\n" "$all_count" > 2_mid/all_count.txt
echo -e "\n"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#NONAMBIG CALLS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#remove the ambiguous characters by only keeping ATCG in lines that arent in the headers
ATCG_fasta=$(echo "$fasta_clean" | sed '/^>/!s/[^ATCG]//gi')

#check your output 
echo "fasta file output of removing ambiguous characters:"
printf "%s\n" "$ATCG_fasta"
echo -e "\n"

#save output
printf "%s\n" "$ATCG_fasta" > 2_mid/atcg.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#GET NONAMBIG COUNTS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#get counts
echo "Count of all nonambiguous nucleotide calls per sample:"
#count the characters in each line that doesn't start with '>'
nonambig_count=$(printf "%s\n" "$ATCG_fasta" | awk '!/^>/ { print length($0) }')
printf "%s\n" "$nonambig_count" #print to console
printf "%s\n" "$nonambig_count" > 2_mid/nonambig_count.txt #save for csv
echo -e "\n"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#GET SEQ NAMES
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
file_name=$(grep '^>' $fasta_file | sed 's/>//g')

printf "%s\n" "$file_name"
printf "%s\n" "$file_name" > 2_mid/file_name.txt 

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#COMBINE DATA AND OUTPUT
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

echo "sample,nonambig,all" > 3_output/output.csv
paste -d ',' 2_mid/file_name.txt 2_mid/nonambig_count.txt 2_mid/all_count.txt >> 3_output/output.csv














