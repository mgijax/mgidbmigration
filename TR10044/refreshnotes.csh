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

insert into MGI_Note
select * from MGI_Note_save
go

insert into MGI_NoteChunk
select * from MGI_NoteChunk_save
go

checkpoint
go

end

EOSQL

#${MGD_DBSCHEMADIR}/index/MGI_Note_drop.object
#${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_drop.object
#bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_Note . MGI_Note_save.bcp
#bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_NoteChunk . MGI_NoteChunk_save.bcp
#${MGD_DBSCHEMADIR}/index/MGI_Note_create.object
#${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_create.object

date |tee -a $LOG

