#!/bin/sh

#
# Object Group Script
#
# Executes all *_create.object scripts
#

cd `dirname $0` && . ./Configuration

index=$1

for i in ${index}/*_create.object
do
$i $*
done

