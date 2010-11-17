#!/bin/csh -f

#
# Template
#

source ../Configuration

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

print ""
print "GO Annotations: what is left in the notes field?"
print ""

select n._Note_key, m.symbol, a.accID, n.note
into #toDelete
from VOC_Annot_View a, VOC_Evidence e, MGI_Note_VocEvidence_View n, MRK_Marker m
where a._AnnotType_key = 1000 
and a._Annot_key = e._Annot_key 
and n._Object_key = e._AnnotEvidence_key 
and a._Object_key = m._Marker_key
go

select * from #toDelete
go

/*delete MGI_Note from #toDelete d, MGI_Note n where d._Note_key = n._Note_key */
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

