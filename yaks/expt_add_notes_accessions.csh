#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG

echo "adding notes and accessions to newly reloaded experiments" | tee -a $LOG 
${PYTHON} "${DBUTILS}/mgidbmigration/yaks/expt_add_notes_accessions.py" | tee -a $LOG

echo "updating gxd_htexperiment"  | tee -a $LOG

psql -h ${MGD_DBSERVER} -U ${MGD_DBUSER} -d ${MGD_DBNAME} -e -f GXD_HTExperiment.sql | tee -a ${LOG}

date | tee -a $LOG
