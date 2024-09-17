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


# Assign the folder path to a variable
folder_path="2_mid"

# Check if the mid folder exists
if [ ! -d "$folder_path" ]; then
    # If the folder does not exist, create it
    mkdir -p "$folder_path"
    echo "Directory created: $folder_path"
fi


# Assign the folder path to a variable
folder_path="3_output"

# Check if the output folder exists
if [ ! -d "$folder_path" ]; then
    # If the folder does not exist, create it
    mkdir -p "$folder_path"
    echo "Directory created: $folder_path"
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

printf "%s\n" "$fasta_clean" > 2_mid/clean.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#GET SEQ NAMES
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#keep only the sequence names which start with ">" then remove the >
seq_name=$(grep '^>' $fasta_file | sed 's/>//g')

#save file to a mid file to be used for the final output
printf "%s\n" "$seq_name" > 2_mid/seq_name.txt 

#print out number of sequences in the input fileß
seq_num=$(cat 2_mid/seq_name.txt|wc -l)
echo "Processing file with $seq_num sequences..."


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#COUNT ALL CALLS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#echo "output of all nucleotide calls per sample:"
all_count=$(printf "%s\n" "$fasta_clean" | awk '!/^>/ { print length($0) }') 

#save to file
printf "%s\n" "$all_count" > 2_mid/all_count.txt


#get count of total nucleotides by:
#1 removing headers
#2 keep only real characters
#count number
total_nucleotides=$(grep -v '^>' $fasta_file| tr -cd '[:alnum:]' | wc -m)

avg_all=$((total_nucleotides / seq_num))

echo "Average sequence length: $avg_all"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#NONAMBIG CALLS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#remove the ambiguous characters by only keeping ATCG in lines that arent in the headers
ATCG_fasta=$(echo "$fasta_clean" | sed '/^>/!s/[^ATCG]//gi')

#get count of total nucleotides by
#1 removing headers
#2 keeping only ATCG
#3 keep only real characters
#4 counting characters
total_nucleotides=$(grep -v '^>' $fasta_file| sed '/^>/!s/[^ATCG]//gi'| tr -cd '[:alnum:]' | wc -m)

avg_all=$((total_nucleotides / seq_num))

echo "Average nonambiguous sequence length: $avg_all"

#save output
printf "%s\n" "$ATCG_fasta" > 2_mid/atcg.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#GET NONAMBIG COUNTS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#get counts

#count the characters in each line by:
#1 dont count rows that start with header ">"
# print length
nonambig_count=$(printf "%s\n" "$ATCG_fasta" | awk '!/^>/ { print length($0) }')

printf "%s\n" "$nonambig_count" > 2_mid/nonambig_count.txt #save for csv


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#COMBINE DATA AND OUTPUT
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
fasta_file2="${fasta_file##*/}" #keep everything after the last "/"
fasta_file2="${fasta_file2%.*}" #remove everthing last the last "." to remove the file type

outfile=$(echo "3_output/"$fasta_file2"_output.csv")

echo "sample,nonambig,all" > "$outfile"
paste -d ',' 2_mid/seq_name.txt 2_mid/nonambig_count.txt 2_mid/all_count.txt >> "$outfile"


#check if output file exists
if [ -f $outfile ]; then

filesize=$(du -h "$outfile" | cut -f 1)
echo -e "File $outfile with size $filesize exported successfully"

else 

echo "$outfile doesn't exist check your bash file"

fi
