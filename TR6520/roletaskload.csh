#!/bin/csh -f

#
# Wrapper script to create & load new role/task records
#
# Usage:  roletaskload.csh
#

cd `dirname $0`

# DB schema directory; its Configuration file will set up all you need
setenv SCHEMADIR $1
source ${SCHEMADIR}/Configuration

setenv INPUTFILE	roletask.in
setenv MODE		full
setenv CREATEDBY	mgd_dbo

setenv ROLETASKLOAD		.

cd `dirname $0`
setenv LOG	$0.log

date >>& $LOG

${ROLETASKLOAD}/roletaskload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -M${MODE} -I${INPUTFILE} -C${CREATEDBY} >>& $LOG

date >>& $LOG

