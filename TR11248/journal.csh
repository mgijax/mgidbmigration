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
 
psql -h ${PG_DBSERVER} -d ${PG_FE_DBNAME} -U ${PG_DBUSER} --command "(select distinct r.journal from reference as r where journal is not null) order by journal" | tee -a $LOG

date |tee -a $LOG

