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

#check if fasta file 
if [[ ! $fasta_file =~ \.fasta$|\.fa$ ]] ; then
	echo "file is not a fasta silly goose!"

fi

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#REMOVE LINE BREAKS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#adds # to the beginning and end of each '>'| removes all new lines | #adds new line | removes empty lin
fasta_clean=$(sed -e 's/\(^>.*$\)/#\1#/' "$fasta_file" | tr -d '\n' | sed -e 's/#/\n/g' | grep -v '^$')

#echo "fasta file output of the fasta_clean step below:"
#printf "%s\n" "$fasta_clean"
#echo -e "\n"

printf "%s\n" "$fasta_clean" > 2_mid/clean.fasta
#echo -e $fasta_clean > 2_mid/clean.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#GET SEQ NAMES
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#keep only the sequence names which start with ">" then remove the >
seq_name=$(grep '^>' $fasta_file | sed 's/>//g')

printf "%s\n" "$seq_name" > 2_mid/seq_name.txt 

seq_num=$(cat 2_mid/seq_name.txt|wc -l)
echo "Processing file with $seq_num sequences..."


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#COUNT ALL CALLS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#echo "output of all nucleotide calls per sample:"
all_count=$(printf "%s\n" "$fasta_clean" | awk '!/^>/ { print length($0) }') 
#printf "%s\n" "$all_count"
printf "%s\n" "$all_count" > 2_mid/all_count.txt
#echo -e "\n"


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#NONAMBIG CALLS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#remove the ambiguous characters by only keeping ATCG in lines that arent in the headers
ATCG_fasta=$(echo "$fasta_clean" | sed '/^>/!s/[^ATCG]//gi')

#check your output 
#echo "fasta file output of removing ambiguous characters:"
#printf "%s\n" "$ATCG_fasta"
#echo -e "\n"

#save output
printf "%s\n" "$ATCG_fasta" > 2_mid/atcg.fasta


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#GET NONAMBIG COUNTS
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#get counts
#echo "Count of all nonambiguous nucleotide calls per sample:"

#count the characters in each line that doesn't start with '>'
nonambig_count=$(printf "%s\n" "$ATCG_fasta" | awk '!/^>/ { print length($0) }')
#printf "%s\n" "$nonambig_count" #print to console
printf "%s\n" "$nonambig_count" > 2_mid/nonambig_count.txt #save for csv
#echo -e "\n"




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

echo "$outfile doesn't exist check your bash file'"

fi











