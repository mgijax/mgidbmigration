#!/bin/csh -f -x

# Script to recompute all or part of the ALL_Cache cache table.  Relies on
# mgiconfig to know which server & database to use.  (only changes are to the
# ALL_Cache table)

cd `dirname $0` && source ./Configuration

setenv USAGE "Usage: $0 [-a <key> | -g <key> | -m <key>] \
	-a : specify single allele key \
	-g : specify genotype key \
	-m : specify marker key \
	If no flags are used, entire table will be recomputed. \
"

if ( ${#argv} == 0 ) then
	setenv FLAGS ""
else if ( ${#argv} == 2 ) then
	setenv FLAGS "$1 $2"
else
	echo $USAGE
	echo "Error: Incorrect command-line parameters"
	exit 1
endif

setenv DB_PARMS "${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_DBUSER} ${MGI_DBPASSWORDFILE}"

echo "Executing: update_ALL_Cache.py ${FLAGS} ${DB_PARMS}"
update_ALL_Cache.py ${FLAGS} ${DB_PARMS}

