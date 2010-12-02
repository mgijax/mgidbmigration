#!/bin/csh -f

#
# re-fresh the saved note data
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

delete MGI_Note
from VOC_Annot a, VOC_Evidence e, MGI_Note n
where a._AnnotType_key = 1000 
and a._Annot_key = e._Annot_key 
and e._AnnotEvidence_key = n._Object_key
go

checkpoint
go

end

EOSQL

${MGD_DBSCHEMADIR}/index/MGI_Note_drop.object
${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_drop.object
bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_Note . MGI_Note_save.bcp
bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_NoteChunk . MGI_NoteChunk_save.bcp
${MGD_DBSCHEMADIR}/index/MGI_Note_create.object
${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_create.object

date |tee -a $LOG

