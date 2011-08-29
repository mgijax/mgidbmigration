#!/bin/sh

#
# Object Group Script
#
# Executes all *_truncate.object scripts
#

cd `dirname $0` && . ./Configuration

table=$1

if [ $# -eq 2 ]
then
    findObject=${table}/$1_truncate.object
else
    findObject=${table}/*_truncate.object
fi

for i in ${findObject}
do
$i $*
done

