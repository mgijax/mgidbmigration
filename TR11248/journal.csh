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
 
setenv LOG1 $0-is-gxd.log
rm -rf $LOG1
touch $LOG1
 
setenv LOG2 $0-not-gxd.log
rm -rf $LOG2
touch $LOG2
 
date | tee -a $LOG
 
psql -h ${PG_DBSERVER} -d ${PG_FE_DBNAME} -U ${PG_DBUSER} --command "(select distinct r.journal from reference as r where journal is not null) order by journal" | tee -a $LOG

psql -h ${PG_DBSERVER} -d ${PG_FE_DBNAME} -U ${PG_DBUSER} --command "(select distinct r.journal from reference as r where journal is not null and indexed_for_gxd = 1) order by journal" | tee -a $LOG1

psql -h ${PG_DBSERVER} -d ${PG_FE_DBNAME} -U ${PG_DBUSER} --command "(select distinct r.journal from reference as r where journal is not null and indexed_for_gxd = 0 and not exists (select 1 from reference as r2 where r.journal = r2.journal and r2.indexed_for_gxd = 1)) order by journal" | tee -a $LOG2

date |tee -a $LOG

