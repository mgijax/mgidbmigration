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

select count(*) from acc_accession where _logicaldb_key = 15;
select count(*) from acc_accession where prefixpart = 'OMIM:';
select * from acc_accession where _logicaldb_key = 15 and prefixpart != 'OMIM:';
select * into temp table omim from acc_accession where _logicaldb_key = 15 ;
select * from omim;

update acc_accession a
set prefixpart = 'MIM:', accid = replace(a.accid,'OMIM','MIM')
from omim o
where o._accession_key = a._accession_key
;

select count(*) from acc_accession where prefixpart = 'OMIM:';
select count(*) from acc_accession where prefixpart = 'MIM:';

select * from acc_accession where _logicaldb_key = 15 and prefixpart != 'MIM:';
select * from acc_accession where _logicaldb_key = 15 ;

EOSQL

# pwi/static/ap/edit/voctermdetail/help.html
# vocload/bin/DOpostprocess.py
# vocload/bin/OMIM.py
# vocload/bin/loadTerms.py
# vocload/bin/OBOParser.py
# gxdindexer:src/org/jax/mgi/indexer/Indexer.java
# qcrpeorts_db/weekly/VOC_OMIMDOObsolete.py
# entrezgeneload/humuman/createBuckets.csh

#${ENTREZGENELOAD}/loadAll.csh | tee -a $LOG

date |tee -a $LOG

