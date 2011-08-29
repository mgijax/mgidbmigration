#!/bin/sh

#
# Object Group Script
#
# Executes all *_drop.object scripts
#

cd `dirname $0` && . ./Configuration

index=$1

for i in ${index}/*_drop.object
do
$i $*
done

