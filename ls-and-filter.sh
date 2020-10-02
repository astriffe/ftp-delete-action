#!/bin/sh -l

echo "" > lscmd
INPUT_IGNORESSL=1
if [ "$INPUT_IGNORESSL" -eq "1" ]
then
    echo "set ftp:ssl-allow no;" >> lscmd
fi
INPUT_HOST=striffeler.ch
INPUT_USER=gefaessc
INPUT_PASSWORD=HGsd54hfgvkmad
INPUT_WORKINGDIR=www/alexanderstriff/volley/test

echo "user $INPUT_USER \"$INPUT_PASSWORD\"" >> lscmd
echo  "cd \"$INPUT_WORKINGDIR\"" >> lscmd


echo "ls" >> lscmd
echo "quit;\n" >> lscmd

lftp  ftp://$INPUT_HOST < lscmd > dirls.out

cat dirls.out  | tail -n +3 | awk '{print $9}' | awk $INPUT_FILTER > files-to-delete.out