#!/bin/bash
#
# Increments the build number found in the given file and rewrites
# the file with that content.
#

FILE=project/build_number.tres

NUMBER=`cat $FILE`
echo "Found build number $NUMBER"
NUMBER=$((NUMBER +1))
echo "Incremented to $NUMBER"
echo $NUMBER > $FILE

