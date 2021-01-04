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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MGI_Organism_MGIType ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/MGI_Organism_MGIType.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MGI_Organism_MGIType RENAME TO MGI_Organism_MGIType_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/MGI_Organism_MGIType_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/MGI_Organism_MGIType_create.object | tee -a $LOG 

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into MGI_Organism_MGIType
select nextval('mgi_organism_mgitype_seq'), m._organism_key, m._mgitype_key, m.sequenceNum,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MGI_Organism_MGIType_old m
;

delete from mgi_organism_mgitype where _mgitype_key in (18, 19)
;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/MGI_Organism_MGIType_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MGI_Organism_MGIType_old;
select count(*) from MGI_Organism_MGIType;

update acc_logicaldb set _organism_key = 76 where _organism_key is null;

insert into VOC_Vocab values(151,22864,1,1,0,'GXD Antibody Class',now(), now());
insert into VOC_Vocab values(152,22864,1,1,0,'GXD Label',now(), now());
insert into VOC_Vocab values(153,22864,1,1,0,'GXD Pattern',now(), now());
insert into VOC_Vocab values(154,22864,1,1,0,'GXD Gel Control',now(), now());
insert into VOC_Vocab values(155,22864,1,1,0,'GXD Embedding Method',now(), now());
insert into VOC_Vocab values(156,22864,1,1,0,'GXD Fixation Method',now(), now());
insert into VOC_Vocab values(157,22864,1,1,0,'GXD Visualization Method',now(), now());
insert into VOC_Vocab values(158,22864,1,1,0,'GXD Assay Type',now(), now());
insert into VOC_Vocab values(159,22864,1,1,0,'GXD Probe Sense',now(), now());
insert into VOC_Vocab values(160,22864,1,1,0,'GXD Secondary',now(), now());
insert into VOC_Vocab values(161,22864,1,1,0,'GXD Assay Age',now(), now());
insert into VOC_Vocab values(162,22864,1,1,0,'GXD Hybridization',now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 161, 'embryonic day', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal day', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal week', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal month', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal year', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal adult', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'postnatal newborn', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 161, 'Not Applicable', null, null, 9, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 162, 'whole mount', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 162, 'section', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 162, 'section from whole mount', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 162, 'optical section', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 162, 'Not Specified', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 162, 'Not Applicable', null, null, 6, 0, 1001, 1001, now(), now());

drop table mgi_organism_mgitype_old;

delete from gxd_assaytype where _assaytype_key in (-1,-2);

EOSQL

date |tee -a $LOG

