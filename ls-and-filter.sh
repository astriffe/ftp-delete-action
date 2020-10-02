#!/bin/sh -l

echo "" > lscmd
if [ "$INPUT_IGNORESSL" -eq "1" ]
then
    echo "set ftp:ssl-allow no;" >> lscmd
fi

echo "user $INPUT_USER \"$INPUT_PASSWORD\"" >> lscmd
echo  "cd \"$INPUT_WORKINGDIR\"" >> lscmd


echo "ls | grep -v '^d'" >> lscmd
echo "quit;\n" >> lscmd

lftp  ftp://$INPUT_HOST < lscmd > dirls.out
cat dirls.out  | tail -n +3 | awk '{print $9}' | awk -v pattern="$INPUT_PATTERN" 'pattern' > files-to-delete.out