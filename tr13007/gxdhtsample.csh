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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_HTSample ${MGI_LIVE}/dbutils/mgidbmigration/tr10307/GXD_HTSample.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_drop.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/trigger/GXD_HTSample_drop.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Genotype_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Experiment_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Stage_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Organism_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Sex_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Relevance_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample__Emapa_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample DROP CONSTRAINT GXD_HTSample_pkey CASCADE;
ALTER TABLE GXD_HTSample RENAME TO GXD_HTSample_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_create.object | tee -a $LOG || exit 1

#
# re-add Image without _mgitype_key
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_HTSample
select i._Sample_key, i._Experiment_key, i._Relevance_key, i.name,
i.age, null, null,
i._Organism_key, i._Sex_key, i._Emapa_key, i._Stage_key, i._Genotype_key,
i._CreatedBy_key, i._ModifiedBy_key, i.creation_date, i.modification_date
from GXD_HTSample_old i
;

ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Genotype_key) REFERENCES mgd.GXD_Genotype DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Experiment_key) REFERENCES mgd.GXD_HTExperiment ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Stage_key) REFERENCES mgd.GXD_TheilerStage DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Organism_key) REFERENCES mgd.MGI_Organism DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Emapa_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Sex_key) REFERENCES mgd.VOC_Term DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample ADD FOREIGN KEY (_Relevance_key) REFERENCES mgd.VOC_Term DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_create.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/trigger/GXD_HTSample_create.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSamplePane_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_HTSample_old;

select count(*) from GXD_HTSample;

--drop table mgd.GXD_HTSample_old;

EOSQL

# create SP
./gxdhtsampleAgeMinMax.csh

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#select * from zMGI_resetAgeMinMax();
#EOSQL

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0
#DROP FUNCTION IF EXISTS zMGI_resetAgeMinMax();
#EOSQL

date |tee -a $LOG

