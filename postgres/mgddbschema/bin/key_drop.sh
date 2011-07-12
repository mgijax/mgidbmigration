#!/bin/sh

#
# Object Group Script
#
# Executes all *_drop.object scripts
#

cd `dirname $0` && . ./Configuration

for i in ${POSTGRESKEY}/*_drop.object
do
$i $*
done

