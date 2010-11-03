#!/bin/csh -f

#
# Template
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

select n._Note_key, nc.note
from VOC_Annot a, VOC_Evidence e, MGI_Note n, MGI_NoteChunk nc
where a._AnnotType_key = 1000 
and a._Annot_key = e._Annot_key 
and n._NoteType_key = 1008 
and n._Object_key = e._AnnotEvidence_key 
and n._Note_key = nc._Note_key 
and nc.note like '%protein product:%'
order by n._Note_key, nc.sequenceNum

checkpoint
go

end

EOSQL

date |tee -a $LOG

