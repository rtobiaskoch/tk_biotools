
input=$1
length=$2
ambiguous_chars="N|R|Y|S|W|K|M|B|D|H|V"

#remove the headers
grep -v '^>' $input| grep -o -E "$ambiguous_chars" | wc -l

