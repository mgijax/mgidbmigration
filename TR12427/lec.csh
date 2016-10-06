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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--insert into ACC_LogicalDB values (191, 'Disease Ontology', 'Disease Ontology', 1, 1001, 1001, now(), now());

--insert into VOC_Vocab values (125, 99561, 191, 0, 0, 'Disease Ontology', now(), now());

--insert into MGI_Set values (1048, 13, 'DO_MGI_slim', 1, 1098, 1098, now(), now());

insert into VOC_AnnotType values (1020, 12, 125, 43, 53, 'DO/Genotype', now(), now());
insert into VOC_AnnotType values (1021, 11, 125, 85, 84, 'DO/Allele', now(), now());
insert into VOC_AnnotType values (1022, 2, 125, 43, 53, 'DO/Human Marker', now(), now());
insert into VOC_AnnotType values (1023, 2, 125, 2, 53, 'DO/Marker (Dervied)', now(), now());

-- same of _AnnotType_key = 1018, but it's vocabulary will be 125 (DO), not 15 (OMIM)
insert into VOC_AnnotType values (1024, 13, 106, 107, 108, 'HPO/DO', now(), now());

--select * from ACC_LogicalDB where name = 'Disease Ontology';

--select * from VOC_Vocab where name = 'Disease Ontology';

--select * from MGI_Set;

select * from VOC_AnnotType;

EOSQL

date |tee -a $LOG

