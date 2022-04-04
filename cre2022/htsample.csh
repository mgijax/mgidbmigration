#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_HTSample ${MGI_LIVE}/dbutils/mgidbmigration/cre2022/GXD_HTSample.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE GXD_HTSample RENAME TO GXD_HTSample_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_HTSample
select _sample_key, _experiment_key, _relevance_key, name ,age, agemin, agemax, _organism_key, _sex_key, _emapa_key, _stage_key, _genotype_key, 
99536377, _createdby_key, _modifiedby_key, creation_date , modification_date
from GXD_HTSample_old
;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from GXD_HTSample_old;
select count(*) from GXD_HTSample;
EOSQL

date |tee -a $LOG

