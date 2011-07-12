#!/bin/sh

#
# Object Group Script
#
# Executes all *_drop.object scripts
#

cd `dirname $0` && . ./Configuration

table=$1

if [ $# -eq 2 ]
then
    findObject=${table}/$1_drop.object
else
    findObject=${table}/*_drop.object
fi

for i in ${findObject}
do
$i $*
done

