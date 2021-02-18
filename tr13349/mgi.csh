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
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd PWI_Report ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/PWI_Report.bcp "|"

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
insert into VOC_Vocab values(163,22864,1,1,0,'GXD Strength',now(), now());
--already exists insert into VOC_Vocab values(164,22864,1,1,0,'Lit Triage Tumor ignore extracted text',now(), now());
insert into VOC_Vocab values(165,22864,1,1,0,'Lit Triage AP extracted text',now(), now());
insert into VOC_Vocab values(166,22864,1,1,0,'Lit Triage GXD extracted text',now(), now());
insert into VOC_Vocab values(167,22864,1,1,0,'Lit Triage Tumor extracted text',now(), now());
insert into VOC_Vocab values(168,22864,1,1,0,'Lit Triage QTL extracted text',now(), now());
insert into VOC_Vocab values(169,22864,1,1,0,'Lit Triage PRO extracted text',now(), now());
insert into VOC_Vocab values(170,22864,1,1,0,'Lit Triage PRO ignore extracted text',now(), now());

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

insert into VOC_Term values(nextval('voc_term_seq'), 165, ' es cell', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, '-/-', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'crispr', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'cyagen', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'eucomm', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'gene trap', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'gene trapped', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'gene-trap', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'gene-trapped', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'generation of mice', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'generation of mutant mice', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'generation of transgenic mice', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'heterozygote', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'homozygote', null, null, 14 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'induced mutation', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'jax', null, null, 16, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knock-in mice', null, null, 17, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knock-in mouse', null, null, 18, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knock-out mice', null, null, 19, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knock-out mouse', null, null, 20, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knockin mice', null, null, 21, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knockin mouse', null, null, 22, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knockout mice', null, null, 23, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'knockout mouse', null, null, 24, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'komp', null, null, 25, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mice were created', null, null, 26, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mice were generated', null, null, 27, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mmrrc', 'mutant mice', null, null, 28, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mutant mouse', null, null, 29, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'novel mutant', null, null, 30, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'novel mutation', null, null, 31, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'ozgene', null, null, 32, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_imsr', null, null, 33, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_jax', null, null, 34, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_mgi', null, null, 35, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_mmrrc', null, null, 36, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:imsr', null, null, 37, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:jax', null, null, 38, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:mgi', null, null, 39, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:mmrrc', null, null, 40, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'spontaneous mutant', null, null, 41, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'spontaneous mutant', null, null, 42, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'spontaneous mutation', null, null, 43, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'talen', null, null, 44, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'targeted mutation', null, null, 45, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'targeting construct', null, null, 46, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'targeting vector', null, null, 47, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'transgene', null, null, 48, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'transgenic mice', null, null, 49, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'transgenic mouse', null, null, 50, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 166, 'embryo', null, null, 1, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 167, 'tumo', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'inoma', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'adenoma', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'sarcoma', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'lymphoma', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'neoplas', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'gioma', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'papilloma', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'leukemia', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'leukaemia', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'ocytoma', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'thelioma', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'blastoma', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'hepatoma', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'melanoma', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'lipoma', null, null, 16, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'myoma', null, null, 17, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'acanthoma', null, null, 18, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'fibroma', null, null, 19, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'teratoma', null, null, 20, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'glioma', null, null, 21, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 167, 'thymoma', null, null, 22, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 168, 'qtl', null, null, 1, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 169, 'splice variant', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'isoform', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, ' variant', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation at', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated on', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternative translation', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'isotype', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'longer form', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'long form', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'shorter form', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'short form', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'acetylation at', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'acetylation on', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glycosylation at', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glycosylation on', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ubiquitination at', null, null, 16, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ubiquitination on', null, null, 17, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ADP-ribosylation at', null, null, 18, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ADP-ribosylation on', null, null, 19, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'amidation at', null, null, 20, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'amidation on', null, null, 21, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'bromination at', null, null, 22, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'bromination on', null, null, 23, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage at', null, null, 24, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylated on', null, null, 25, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylated at', null, null, 26, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylation on', null, null, 27, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylation at', null, null, 28, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hydroxylation at', null, null, 29, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hydroxylation on', null, null, 30, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'methylation at', null, null, 31, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'methylation on', null, null, 32, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prenylation at', null, null, 33, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prenylation on', null, null, 34, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sumoylation at', null, null, 35, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sumoylation on', null, null, 36, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternatively spliced form', null, null, 37, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'proteolytic processing', null, null, 38, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prepro', null, null, 39, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pre-pro', null, null, 40, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 170, 'heavy chain isoform', null, null, 1, 0, 1001, 1001, now(), now());

drop table mgi_organism_mgitype_old;

delete from gxd_assaytype where _assaytype_key in (-1,-2);

-- remove obsolete pwi_report
delete from pwi_report where id in (9,10,11,12,13,36,17);

EOSQL

# obsolete reports
rm -rf ${QCREPORTDIR}/output/WF_AP_Routed.rpt

date |tee -a $LOG

