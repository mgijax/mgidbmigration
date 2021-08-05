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

insert into VOC_Vocab values(172,22864,1,1,0,'GXD Gel RNA Type',now(), now());

delete from VOC_Term where _vocab_key = 158;
delete from VOC_Term where _vocab_key = 172;

insert into VOC_Term values(nextval('voc_term_seq'), 158, 'RNA in situ', 'InSitu', null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'Northern blot', 'North', null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'Nuclease S1', 'S1Nuc', null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'RNase protection', 'RNAse', null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'RT-PCR', 'RTPCR', null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'Immunohistochemistry', 'Immuno', null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'Western blot', 'West', null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'In situ reporter (knock in)', 'Knock', null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'In situ reporter (transgenic)', 'Transg', null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 158, 'Recombinase reporter', 'Recomb', null, 10, 0, 1001, 1001, now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 172, 'Not Specified', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'Not Applicable', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'poly-A+', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'total', null, null, 4, 0, 1001, 1001, now(), now());

EOSQL

date |tee -a $LOG

