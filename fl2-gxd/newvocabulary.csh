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

update voc_vocab set name = 'Lit Triage GXD Category 1 Terms' where _vocab_key = 166;
update voc_vocab set name = 'Lit Triage GXD Category 1 Exclude' where _vocab_key = 135;

insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Lit Triage GXD Age Excluded',now(),now());
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Lit Triage GXD Category 2 Exclude',now(),now());
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Lit Triage GXD Category 2 Terms',now(),now());

EOSQL

date |tee -a $LOG

