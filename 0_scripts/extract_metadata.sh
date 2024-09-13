#!/bin/bash
filename=$1
grep '^>' "$filename" | awk -F"/ " '{OFS=","; print $1, $2}' > headers.csv

