#!/bin/csh -f

#
# Migration for TR 4378
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

declare @vocKey integer
declare @termKey integer
declare @annotKey integer

select @vocKey = max(_Vocab_key) + 1 from VOC_Vocab
insert VOC_Vocab (_Vocab_key, _Refs_key, _LogicalDB_key, isSimple, isPrivate, name)
values(@vocKey,22864,-1,1,1,"Super Standard Strain")

select @termKey = max(_Term_key) + 1 from VOC_Term
insert VOC_Term (_Term_key, _Vocab_key, term, abbreviation, sequenceNum, isObsolete)
values(@termKey,@vocKey,"super standard",NULL,1,0)

select @annotKey = max(_Term_key) + 1 from VOC_Term
insert VOC_AnnotType (_AnnotType_key, _MGIType_key, _Vocab_key, _EvidenceVocab_key, name)
values(@annotKey,10,@vocKey,@vocKey,"Strain/Super Standard")
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

date >> $LOG

