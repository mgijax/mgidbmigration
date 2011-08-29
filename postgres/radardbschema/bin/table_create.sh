#!/bin/sh

#
# Object Group Script
#
# Executes all *_create.object scripts
#

cd `dirname $0` && . ./Configuration

table=$1

if [ $# -eq 2 ]
then
    findObject=${table}/$1_create.object
else
    findObject=${table}/*_create.object
fi

for i in ${findObject}
do
$i $*
done

