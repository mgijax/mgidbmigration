#!/bin/csh -f

#
# Wrapper script to create & load new user/role records
#
# Usage:  userroleload.csh
#

cd `dirname $0` && source ./Configuration

setenv INPUTFILE	userrole.in
setenv MODE		full
setenv CREATEDBY	mgd_dbo

setenv ROLETASKLOAD		.

cd `dirname $0`
setenv LOG	$0.log
rm -rf ${LOG}

date >>& $LOG

${ROLETASKLOAD}/userroleload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -M${MODE} -I${INPUTFILE} -C${CREATEDBY} >>& $LOG

date >>& $LOG

