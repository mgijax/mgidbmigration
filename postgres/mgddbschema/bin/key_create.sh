#!/bin/sh

#
# Object Group Script
#
# Executes all *_create.object scripts
#

cd `dirname $0` && . ./Configuration

for i in ${POSTGRESKEY}/*_create.object
do
$i $*
done

