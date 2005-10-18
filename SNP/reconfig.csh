#!/bin/csh -x -f

#
# Drop and re-create database keys
#
#

cd `dirname $0` && source ./Configuration

${newmgddbschema}/key/key_drop.csh
${newmgddbschema}/key/key_create.csh

