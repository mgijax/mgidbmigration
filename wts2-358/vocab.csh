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

delete from voc_term where _vocab_key = 174;
delete from voc_vocab where _vocab_key = 174;
insert into voc_vocab values(174,22864,1,1,0,'Allele Inducible',now(), now());

insert into voc_term values(nextval('voc_term_seq'), 174, 'androgen', null, null, 1, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'aminoglycosides', null, null, 2, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'beta-naphthoflavone', null, null, 3, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'cellular stress and tamoxifen', null, null, 4, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'doxycycline', null, null, 5, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'mifepristone', null, null, 6, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'interferon or polyinosinic-polycytidylic acid', null, null, 7, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'rapamycin', null, null, 8, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'tamoxifen', null, null, 9, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'tetracycline', null, null, 10, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'trimethoprim', null, null, 11, 0, 1001, 1001, now(), now());
insert into voc_term values(nextval('voc_term_seq'), 174, 'tamoxifen and tetracycline', null, null, 12, 0, 1001, 1001, now(), now());

EOSQL

date |tee -a $LOG

