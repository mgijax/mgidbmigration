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
${PG_DBUTILS}/bin/dumpTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample.bcp '|' >>& $LOG
${PG_DBUTILS}/bin/dumpTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeq ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeq.bcp '|' >>& $LOG
${PG_DBUTILS}/bin/dumpTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeqSetMember ${DBUTILS}/home/lec/mgi/dbutils/mgidbmigration/wts2-1539/GXD_HTSample_RNASeqSetMember.bcp '|' >>& $LOG
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_truncate.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--insert into voc_vocab values(189,22864,1,1,0,'GXD HT RNA-Seq Type', now(), now());
--insert into voc_term values(nextval('voc_term_seq'),189,'bulk RNA-seq',null,null,1,0,1001,1001,now(),now());
--insert into voc_term values(nextval('voc_term_seq'),189,'scRNA-seq',null,null,2,0,1001,1001,now(),now());
--insert into voc_term values(nextval('voc_term_seq'),189,'spatial RNA-seq',null,null,3,0,1001,1001,now(),now());
--insert into voc_term values(nextval('voc_term_seq'),189,'Not Specified',null,null,4,0,1001,1001,now(),now());
--insert into voc_term values(nextval('voc_term_seq'),189,'Not Applicable',null,null,5,0,1001,1001,now(),now());

ALTER TABLE GXD_HTSample RENAME TO GXD_HTSample_old;
ALTER TABLE mgd.GXD_HTSample_old DROP CONSTRAINT GXD_HTSample_pkey CASCADE;

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_create.object | tee -a $LOG 

#
# insert data into new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- if relevance != Yes, then set to 'Not Applicable'
insert into GXD_HTSample
select _sample_key, _experiment_key, _relevance_key , name, age, agemin, agemax, _organism_key, _sex_key, _emapa_key,
_stage_key, _genotype_key, _celltype_term_key, 114866228,
_createdby_key, _modifiedby_key, creation_date, modification_date
from GXD_HTSample_old
where _relevance_key != 20475450
;

-- thse that are single variable in ('bulk RNA-seq', 'scRNA-seq', 'spatial RNA-seq'), 
-- set to experiment variable of same name
select g._experiment_key
into temp table singleVariable
from GXD_HTExperiment e, GXD_HTExperimentVariable g, VOC_Term t
where e._experimenttype_key = 20475437
and e._experiment_key = g._experiment_key
and g._term_key = t._term_key
and t.term in ('bulk RNA-seq', 'scRNA-seq', 'spatial RNA-seq')
and not exists (select 1 from GXD_HTSample gg where gg._experiment_key = g._experiment_key)
group by g._experiment_key having count(*) = 1
order by g._experiment_key
;
insert into GXD_HTSample
select g._sample_key, g._experiment_key, g._relevance_key , g.name, g.age, g.agemin, g.agemax, g._organism_key, g._sex_key, g._emapa_key,
g._stage_key, g._genotype_key, g._celltype_term_key, t2._term_key,
g._createdby_key, g._modifiedby_key, g.creation_date, g.modification_date
from singleVariable s, GXD_HTSample_old g, GXD_HTExperimentVariable v, VOC_Term t1, VOC_Term t2
where s._experiment_key = g._experiment_key
and g._experiment_key = v._experiment_key
and v._term_key = t1._term_key
and t1.term = t2.term
and t2._vocab_key = 189
;

-- those that are left, set to 'Not Specified'
select distinct g1._sample_key
into temp table whatIsLeft
from GXD_HTSample_old g1
where not exists (select 1 from GXD_HTSample g2 where g1._sample_key = g2._sample_key)
;
insert into GXD_HTSample
select g._sample_key, g._experiment_key, g._relevance_key , g.name, g.age, g.agemin, g.agemax, g._organism_key, g._sex_key, g._emapa_key,
g._stage_key, g._genotype_key, g._celltype_term_key, 114866227,
g._createdby_key, g._modifiedby_key, g.creation_date, g.modification_date
from GXD_HTSample_old g, whatIsLeft w
where g._sample_key = w._sample_key
;

select count(*) from GXD_HTSample;
select count(*) from GXD_HTSample_old;

EOSQL

# remove "old" table
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
drop table mgd.GXD_HTSample_old;
EOSQL

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

${PG_DBUTILS}/bin/loadTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeq ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeq.bcp '|' >>& $LOG
${PG_DBUTILS}/bin/loadTableData.csh ${PG_DBSERVER} ${PG_DBNAME} mgd GXD_HTSample_RNASeqSetMember ${DBUTILS}/mgidbmigration/wts2-1539/GXD_HTSample_RNASeqSetMember.bcp '|' >>& $LOG

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd >>& $LOG
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG 

date |tee -a $LOG

