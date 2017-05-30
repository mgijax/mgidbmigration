#!/bin/csh -f

#
# TR12250/Lit Triage/load vocabularies
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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from VOC_Term where _Vocab_key in (128,129,130);
delete from VOC_Vocab where _Vocab_key in (128,129,130);
EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Reference Type',now(),now());
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Workflow Group',now(),now());
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Workflow Status',now(),now());
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Workflow Tag',now(),now());
EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Article',null,1,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Book',null,2,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Direct Submission',null,3,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Personal Communication',null,4,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'GenBank Submission',null,5,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Newsletter',null,6,0,1001,1001,now(),now());

insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Group'), 
'Alleles & Phenotypes','AP',1,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Group'), 
'Expression','Expr',2,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Group'), 
'Gene Ontology','GO',3,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Group'), 
'Tumor','Tumor',4,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Group'), 
'QTL','QTL',5,0,1001,1001,now(),now());

insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Status'), 
'Not Routed',null,1,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Status'), 
'Routed',null,2,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Status'), 
'Chosen',null,3,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Status'), 
'Rejected',null,4,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Status'), 
'Indexed',null,5,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Workflow Status'), 
'Fully curated',null,6,0,1001,1001,now(),now());

EOSQL

./vocabulary.py | tee -a $LOG

date |tee -a $LOG

