#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} --command "select distinct drivernote from all_cre_cache order by drivernote" | tee -a $LOG

date |tee -a $LOG

