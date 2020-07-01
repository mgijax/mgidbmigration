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

insert into VOC_Vocab values(147, 22864, 1, 1, 0, 'GXD Default Age', now(), now());

insert into VOC_Term values(nextval('voc_term_seq'), 147, 'embryonic', 'embryonic', null, 1, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'embryonic day', 'embryonic day', null, 2, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal', 'postnatal', null, 3, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal day', 'postnatal day', null, 4, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal week', 'postnatal week', null, 5, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal month', 'postnatal month', null, 6, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal year', 'postnatal year', null, 7, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal adult', 'postnatal adult', null, 8, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'postnatal newborn', 'postnatal newborn', null, 9, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'Not Specified', 'Not Specified', null, 10, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'Not Applicable', 'Not Applicable', null, 11, 0, 1000, 1000, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 147, 'Not Loaded', 'Not Loaded', null, 12, 0, 1000, 1000, now(), now());

EOSQL

date |tee -a $LOG

