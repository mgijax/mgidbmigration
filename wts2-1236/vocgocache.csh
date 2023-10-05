#!/bin/csh -f

#
# vocload
# pgmgddbschema : remove VOC_GO_Cache
# mgicacheload  : remove vocgo.csh, vocgo.py
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
 
${PG_MGD_DBSCHEMADIR}/procedure/VOC_mergeTerms_create.object
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.VOC_GO_Cache DROP CONSTRAINT VOC_GO_Cache__DAG_key_fkey CASCADE;
ALTER TABLE mgd.VOC_GO_Cache DROP CONSTRAINT VOC_GO_Cache__Term_key_fkey CASCADE;
drop table mgd.VOC_GO_Cache CASCADE;
EOSQL
${PG_MGD_DBSCHEMADIR}/key/DAG_DAG_drop.object
${PG_MGD_DBSCHEMADIR}/key/DAG_DAG_create.object
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object
${PG_MGD_DBSCHEMADIR}/objectCounter.sh

date |tee -a $LOG

