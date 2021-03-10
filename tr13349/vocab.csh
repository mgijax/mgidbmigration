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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- insert new VOC_Vocab

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

--already existsinsert into VOC_Vocab values(164,22864,1,1,0,'Lit Triage Tumor ignore extracted text',now(), now());
--insert into VOC_Vocab values(165,22864,1,1,0,'Lit Triage AP extracted text',now(), now());
--insert into VOC_Vocab values(166,22864,1,1,0,'Lit Triage GXD extracted text',now(), now());
--insert into VOC_Vocab values(167,22864,1,1,0,'Lit Triage Tumor extracted text',now(), now());
--insert into VOC_Vocab values(168,22864,1,1,0,'Lit Triage QTL extracted text',now(), now());
--insert into VOC_Vocab values(169,22864,1,1,0,'Lit Triage PRO extracted text',now(), now());
--insert into VOC_Vocab values(170,22864,1,1,0,'Lit Triage PRO ignore extracted text',now(), now());

EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from voc_term where _vocab_key in (161,162,165,166,167,168,169,170);

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
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'homozygote', null, null, 14, 0, 1001, 1001, now(), now());
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
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mmrrc', null, null, 28, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mutant mice', null, null, 29, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'mutant mouse', null, null, 30, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'novel mutant', null, null, 31, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'novel mutation', null, null, 32, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'ozgene', null, null, 33, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_imsr', null, null, 34, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_jax', null, null, 35, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_mgi', null, null, 36, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid_mmrrc', null, null, 37, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:imsr', null, null, 38, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:jax', null, null, 39, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:mgi', null, null, 40, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'rrid:mmrrc', null, null, 41, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'spontaneous mutant', null, null, 42, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'spontaneous mutant', null, null, 43, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'spontaneous mutation', null, null, 44, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'talen', null, null, 45, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'targeted mutation', null, null, 46, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'targeting construct', null, null, 47, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'targeting vector', null, null, 48, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'transgene', null, null, 49, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'transgenic mice', null, null, 50, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 165, 'transgenic mouse', null, null, 51, 0, 1001, 1001, now(), now());

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

insert into VOC_Term values(nextval('voc_term_seq'), 169, 'isoform', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, ' a-form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, ' b-form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cytosolic form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'membrane-bound form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'nonsecreted form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'nuclear form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'transmembrane form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'truncated form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'two alternative forms', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'long form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'longer form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'short form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'shorter form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'shortening of the protein', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternate reading frame', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternative exon', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternative gene product', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternative splic', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternative transcription', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternative translation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'alternatively splic', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'different splic', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'differential polyadenyl', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'differential splic', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'gene encodes two', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'splice form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'splice varia', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'spliced form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'spliceform', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'spliced out', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'spliced variant', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'splicing variant', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'variant form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'variant protein', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'variant transcript', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'signal peptide-bearing variant', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prepro', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pre-pro', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pro-enzyme', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pro-peptide', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prohormone', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'protein variant', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'proteolytic cleavage', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'proteolytic processing', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'app processing', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'autoproteolytic cleavage', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage of pro', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage point', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage product', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage sequence', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cleavage site', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'endoproteolytic cleavage', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'induced cleavage', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'post-translational cleavage', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'generation of mature protein', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'processing variant', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'zymogen activation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'acetylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'acetylation dependent', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'acetylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'amidation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'amidation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'bromination at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'bromination on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'chemokine precursor', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cholesterol modification', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cholesterylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 's-farnesylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'farnesylated at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'farnesylated on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylated at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylated on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'galactosylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'n-glycosylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glycosylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glycosylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glycosylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hydroxylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hydroxylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'less phosphorylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'lipid-modified', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'loss of myristoylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'methylated form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'methylated protein', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'methylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'methylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'mitochondrial form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'mono-methylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'myristoylated at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'myristoylated on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'myristoylation is lost', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'myristoylation of', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'myristoylation site', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'non-methylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'non-phosphorylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'nonphosphorylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'palmitoylation of', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'palmitoylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pattern of phosphorylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated ser', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated thr', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated tyr', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated on tyrosine', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated region', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated residue', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylated tyrosine', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation at ser', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation at thr', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation event', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation is required', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation motif', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation of ser', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation of thr', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation of tyr', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation site', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation stat', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'phosphorylation-state-specific', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'polyglutamylation of', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'polyubiquitination of', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'polyubiquitinylated protein', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 's-prenylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prenylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'prenylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ribosylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ribosylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sumoylation at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sumoylation on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sumoylation-defective', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sumoylation-dependent', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'tyrosine phosphorylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'tyrosine phosphorylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'tyrosine-phosphorylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ubiquitination at', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ubiquitination on', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'unphosphorylated', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'asap1a', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'asap1b', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'bcl-xs', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cd137', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glur6a', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'glur6b', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hk1s', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hk1-sa', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hk1-sb', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hk1-sc', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hsp105a', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hsp105alpha', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hsp105b', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'hsp105beta', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'kal7', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'kal9', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'kal10', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'kal12', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, ' pgra', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pgrb', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ps2ccas', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'ps2s', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'piasx', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'rfx4_v1', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'rfx4_v2', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'rfx4_v3', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'rim2a', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'rim2b', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'rim2g', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'sgip1a', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'st2l', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'stat3a', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'stat3b', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'calcitonin gene-related peptide', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'calcitonin', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'cgrp', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'esrage', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'p29 bag1', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'pro-cathepsin', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'soluble st2', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 169, 'soluble form', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 169), 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 170, 'calcitonin receptor', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'axonemal heavy chain isoform', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'dynein heavy chain isoform', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'dynein isoform', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'human isoform', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isoform in bull', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'control isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'ctrl isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype control', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-control', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype ctrl', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype igg', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'iggl isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'igg isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'igg2a isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'igm isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'iga isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype switching', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotypes by class switch', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype primary antibody', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-specific rabbit ig', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-specific sandwich elisa', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-specific elisa', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-specific control', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-specific antibody', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype antibod', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype (rat', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype (mouse', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype (iso', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype (monoclonal', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype treatment', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'immunoglobulin g isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'immunoglobulin isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'stained with isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'matching isotype', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype induced', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype matched', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype-matched', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotypematched', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation on the maternal', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation on the paternal', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation on maternal', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation on paternal', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'DNA methylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'cpg methylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation at these cpg', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'dna hypomethylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'dna hypermethylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation at cpg', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'dna demethylation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'methylation at the promoter', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'pre-process', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'preprocess', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'preprogrammed', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'preprotech', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'pre-procedure', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'preprocedure', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype was igm', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype was igg', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'isotype was iga', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'b-form dna', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'b-form conformation', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'upgrade', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'pre-pro b', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'pre-proximal', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'xist2lox', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 170, 'cgrp expression', null, null, (select max(sequenceNum) + 1 from voc_term where _vocab_key = 170), 0, 1001, 1001, now(), now());

select _vocab_key, count(*) from voc_term where _vocab_key in (161,162,165,166,167,168,169,170) group by _vocab_key order by _vocab_key;

EOSQL

date |tee -a $LOG

