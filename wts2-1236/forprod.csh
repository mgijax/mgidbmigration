#!/bin/csh -f

#
# vocload
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
-- MouseCyc
delete from dag_dag where _dag_key = 48;
EOSQL

# remove old lib/python scripts that are moved to vocload/lib
rm -rf ${LIBDIRS}/dbTable.py  ${LIBDIRS}/loadDAG.py  ${LIBDIRS}/Log.py  ${LIBDIRS}/Ontology.py  ${LIBDIRS}/voc_html.py  ${LIBDIRS}/vocloadDAG.py  ${LIBDIRS}/vocloadlib.py

date |tee -a $LOG

