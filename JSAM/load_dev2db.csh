#!/bin/csh -x -f

#
# Load development database from binary dump
#
# Parameters:
#	DBNAME - the name of the database to load
#	BACKUP - the name of the dump file to use
#

cd `dirname $0` && source ./Configuration

setenv BACKUP $1

load_db.csh ${DBSERVER} ${DBNAME} ${WORKDIR}/${BACKUP}

