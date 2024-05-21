#!/bin/csh -f

#
# change OMIM -> MIM
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

select count(*) from acc_accession where _logicaldb_key = 15;
select count(*) from acc_accession where prefixpart = 'OMIM:' or prefixpart = 'OMIM:PS';
select * from acc_accession where _logicaldb_key = 15 and prefixpart != 'OMIM:';
select * into temp table omim from acc_accession where prefixpart = 'OMIM:' or prefixpart = 'OMIM:PS';
select * from omim;

--update acc_logicaldb set name = 'MIM:PS' where _logicaldb_key = 201;

update acc_accession a
set prefixpart = 'MIM:', accid = replace(a.accid,'OMIM','MIM')
from omim o
where o._accession_key = a._accession_key
;

select count(*) from acc_accession where prefixpart = 'OMIM:';
select count(*) from acc_accession where prefixpart = 'OMIM:PS';
select count(*) from acc_accession where prefixpart = 'MIM:';

EOSQL

# vocload/bin/DOpostprocess.py
# vocload/bin/OMIM.py
# vocload/bin/loadTerms.py
# vocload/bin/OBOParser.py
#scp bhmgiapp01:/data/loads/mgi/vocload/OMIM/omim.txt ${DATALOADSOUTPUT}/mgi/vocload/OMIM
#scp bhmgiapp01:${DATADOWNLOADS}/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/main/src/ontology/doid-merged.obo ${DATADOWNLOADS}/raw.githubusercontent.com/DiseaseOntology/HumanDiseaseOntology/main/src/ontology
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a $LOG
${VOCLOAD}/runOBOIncLoadNoArchive.sh DO.config | tee -a $LOG

# entrezgeneload/human/createBuckets.csh
#${ENTREZGENELOAD}/loadHuman.csh | tee -a $LOG

# qcrpeorts_db/weekly/VOC_OMIMDOObsolete.py
cd ${QCRPTS}
source ./Configuration
cd weekly
${PYTHON} VOC_OMIMDOObsolete.py | tee -a $LOG

# pwi/static/ap/edit/voctermdetail/help.html
# can be done at any time

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from acc_accession where prefixpart = 'OMIM:';
select count(*) from acc_accession where prefixpart = 'MIM:';
select * from acc_accession where _logicaldb_key = 15 and prefixpart != 'MIM:';
select * from acc_accession where _logicaldb_key = 15 ;
EOSQL

date |tee -a $LOG

