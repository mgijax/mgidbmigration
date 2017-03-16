#!/bin/sh

cd `dirname $0` 

if [ "${MGICONFIG}" = "" ]
then
    MGICONFIG=/usr/local/mgi/live/mgiconfig
    export MGICONFIG
fi

. ${MGICONFIG}/master.config.sh

LOG=$0.log
rm -rf $LOG
touch $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 >> $LOG

select a3.accID, v._annottype_key, v._object_key
from VOC_Annot v, ACC_Accession a3
where v._AnnotType_key = 1024
and v._Object_key = a3._Object_key
and a3._MGIType_key = 13
and a3._LogicalDB_key =  191 
and a3.preferred = 1 
order by a3.accID, v._object_key
;

EOSQL

