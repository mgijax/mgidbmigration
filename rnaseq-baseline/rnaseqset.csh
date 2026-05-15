#!/bin/csh -f

#
# rnaseqload
# pgmgddbschema
# femover/gather/reference_counts_gatherer.py
# reports_db/gxdrnaseq/GXD_RnaSeq.py
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
 
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqSet_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqSet_drop.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqCombined_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqCombined_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.GXD_HTSample_RNASeqSet DROP CONSTRAINT GXD_HTSample_RNASeqSet__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet DROP CONSTRAINT GXD_HTSample_RNASeqSet__CreatedBy_key_fkey CASCADE;

ALTER TABLE GXD_HTSample_RNASeqSet RENAME TO GXD_HTSample_RNASeqSet_old;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet_old DROP CONSTRAINT GXD_HTSample_RNASeqSet_pkey CASCADE;

ALTER TABLE mgd.GXD_HTSample_RNASeqCombined DROP CONSTRAINT GXD_HTSample_RNASeqCombined__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined DROP CONSTRAINT GXD_HTSample_RNASeqCombined__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined DROP CONSTRAINT GXD_HTSample_RNASeqCombined__Marker_key_fkey CASCADE;

ALTER TABLE GXD_HTSample_RNASeqCombined RENAME TO GXD_HTSample_RNASeqCombined_old;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined_old DROP CONSTRAINT GXD_HTSample_RNASeqCombined_pkey CASCADE;

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG 

#
# insert data into new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_HTSample_RNASeqSet
select 
_rnaseqset_key ,
_experiment_key ,
null,
null,
age ,
_organism_key ,
_sex_key ,
_emapa_key ,
_stage_key ,
_genotype_key ,
note ,
_createdby_key ,
_modifiedby_key ,
creation_date ,
modification_date
from GXD_HTSample_RNASeqSet_old
;

select count(*) from GXD_HTSample_RNASeqSet;
select count(*) from GXD_HTSample_RNASeqSet_old;

insert into GXD_HTSample_RNASeqCombined
select
c._rnaseqcombined_key ,
d._rnaseqset_key,
c._marker_key ,
c._level_key ,
c.numberofbiologicalreplicates ,
c.averagequantilenormalizedtpm ,
c._createdby_key ,
c._modifiedby_key ,
c.creation_date    ,
c.modification_date
from GXD_HTSample_RNASeqCombined_old c, GXD_HTSample_RNASeqSet_Cache d
where c._RNASeqCombined_key = d._RNASeqCombined_key
;

select count(*) from GXD_HTSample_RNASeqCombined;
select count(*) from GXD_HTSample_RNASeqCombined_old;

EOSQL

# remove "old" table
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
drop table mgd.GXD_HTSample_RNASeqSet_old;
drop table mgd.GXD_HTSample_RNASeqCombined_old;
drop table mgd.GXD_HTSample_RNASeqSet_Cache;
EOSQL

${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG 

${PG_MGD_DBSCHEMADIR}/autosequence/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqSet ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.GXD_HTSample_RNASeqCombined ADD FOREIGN KEY (_RNASeqSet_key) REFERENCES mgd.GXD_HTSample_RNASeqSet ON DELETE CASCADE DEFERRABLE;

EOSQL

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd >>& $LOG
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 

date |tee -a $LOG

