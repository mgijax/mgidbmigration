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

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_HTExperiment ${MGI_LIVE}/dbutils/mgidbmigration/yaks/GXD_HTExperiment.bcp "|"

${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperimentVariable_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE GXD_HTExperiment RENAME TO GXD_HTExperiment_old;

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_HTExperiment_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_HTExperiment
select m._Experiment_key, m._Source_key, m.name, m.description, m.release_date, m.lastupdate_date, m.evaluated_date, m._EvaluationState_key, m._CurationState_key, m._StudyType_key, m._ExperimentType_key, m._EvaluatedBy_key, m._InitialCuratedBy_key, m._LastCuratedBy_key, m.initial_curated_date, m.last_curated_date, 0.0, m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from GXD_HTExperiment_old m
;

EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_HTExperiment_old;

select count(*) from GXD_HTExperiment;

drop table GXD_HTExperiment_old;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GXD_HTExperiment_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/comments/GXD_HTExperiment_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTExperiment_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperimentVariable_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1

date |tee -a $LOG
