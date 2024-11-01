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
 
#${PG_DBUTILS}/bin/loadTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample.bcp '|' >>& $LOG
#${PG_DBUTILS}/bin/dumpTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample.bcp '|' >>& $LOG
#${PG_DBUTILS}/bin/dumpTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeq ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeq.bcp '|' >>& $LOG
#${PG_DBUTILS}/bin/dumpTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeqSetMember ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeqSetMember.bcp '|' >>& $LOG
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_truncate.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE GXD_HTSample RENAME TO GXD_HTSample_old;
ALTER TABLE mgd.GXD_HTSample_old DROP CONSTRAINT GXD_HTSample_pkey CASCADE;

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_create.object | tee -a $LOG 

#
# insert data into new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- case 1
-- if Experiment Type = transcription profiling by array, then set to "Not Applicable"
-- 65327
insert into GXD_HTSample
select s._sample_key, s._experiment_key, s._relevance_key , s.name, s.age, s.agemin, s.agemax, s._organism_key, s._sex_key, s._emapa_key,
s._stage_key, s._genotype_key, s._celltype_term_key, 114866228,
s._createdby_key, s._modifiedby_key, s.creation_date, s.modification_date
from GXD_HTSample_old s, GXD_HTExperiment e
where e._experimenttype_key = 20475436
and e._experiment_key = s._experiment_key
;

-- case 2
-- if Experiment Type = RNA-Seq, relevance != Yes, then set to 'Not Applicable'
-- 25745
insert into GXD_HTSample
select s._sample_key, s._experiment_key, s._relevance_key , s.name, s.age, s.agemin, s.agemax, s._organism_key, s._sex_key, s._emapa_key,
s._stage_key, s._genotype_key, s._celltype_term_key, 114866228,
s._createdby_key, s._modifiedby_key, s.creation_date, s.modification_date
from GXD_HTSample_old s, GXD_HTExperiment e
where e._experimenttype_key = 20475437
and e._experiment_key = s._experiment_key
and s._relevance_key != 20475450
and not exists (select 1 from GXD_HTSample ss where s._sample_key = ss._sample_key)
;

-- case 3
-- if Experiment Type = RNA-Seq, relevance = Yes, then set to 'Not Applicable'
-- those that are single variable in ('bulk RNA-seq', 'single cell RNA-seq', 'spatial RNA-seq'), 
-- set to experiment variable of same name
-- 65393
WITH experiments AS (
select e._experiment_key
from GXD_HTExperiment e, GXD_HTExperimentVariable v
where e._experimenttype_key = 20475437
and e._experiment_key = v._experiment_key
and v._term_key in (114732569,114732570,114732571)
group by e._experiment_key having count(*) = 1
)
select s._experiment_key, s._sample_key
into temp table singleVariable
from experiments e, GXD_HTSample_old s
where e._experiment_key = s._experiment_key
and s._relevance_key = 20475450
and not exists (select 1 from GXD_HTSample ss where ss._sample_key = s._sample_key)
;
insert into GXD_HTSample
select s._sample_key, s._experiment_key, s._relevance_key , s.name, s.age, s.agemin, s.agemax, s._organism_key, s._sex_key, s._emapa_key,
s._stage_key, s._genotype_key, s._celltype_term_key, t2._term_key,
s._createdby_key, s._modifiedby_key, s.creation_date, s.modification_date
from singleVariable sv, GXD_HTSample_old s, GXD_HTExperimentVariable v, VOC_Term t1, VOC_Term t2
where sv._sample_key = s._sample_key
and s._experiment_key = v._experiment_key
and v._term_key = t1._term_key
and t1.term = t2.term
and t2._vocab_key = 189
;
select distinct e._experiment_key, a.accid
from singleVariable e, acc_accession a
where e._experiment_key = a._object_key and a._logicaldb_key in (189,190)
;

-- case 4
-- those that are left, set to 'Not Specified'
select distinct s._sample_key
into temp table whatIsLeft
from GXD_HTSample_old s
where not exists (select 1 from GXD_HTSample ss where s._sample_key = ss._sample_key)
;
insert into GXD_HTSample
select s._sample_key, s._experiment_key, s._relevance_key , s.name, s.age, s.agemin, s.agemax, s._organism_key, s._sex_key, s._emapa_key,
s._stage_key, s._genotype_key, s._celltype_term_key, 114866227,
s._createdby_key, s._modifiedby_key, s.creation_date, s.modification_date
from GXD_HTSample_old s, whatIsLeft w
where s._sample_key = w._sample_key
;

-- 207336
select count(*) from GXD_HTSample;
select count(*) from GXD_HTSample_old;

EOSQL

# remove "old" table
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#drop table mgd.GXD_HTSample_old;
#EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/VOC_drop.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/VOC_create.logical | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqCombined_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeqSet_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeq_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_RNASeq_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Organism_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Organism_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_create.object | tee -a $LOG 

#${PG_DBUTILS}/bin/loadTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeq ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeq.bcp '|' >>& $LOG
#${PG_DBUTILS}/bin/loadTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeqSetMember ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeqSetMember.bcp '|' >>& $LOG

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd >>& $LOG
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 

./checkMigration.csh | tee -a $LOG

date |tee -a $LOG

