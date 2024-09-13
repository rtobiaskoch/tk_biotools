#!/usr/bin/env bash
 
# Make a backup directory if it doesn't already exist
mkdir -p backups
 
# Acquire the input filename. ## Hint - change this line to acquire multiple files
inputfile=$1
 
## Hint - Start loop here
 
# Substring replacement to create an output file name
outputfile=${inputfile/.txt/_bkp.txt}
 
# Save the backup 
echo -e "\nBacking up $inputfile. Saviing it as $outputfile in backup directory\n"
 
cp $inputfile backups/$outputfile
 
## Hint - Stop loop here
 
echo -e "saveBackups.sh program complete\n"