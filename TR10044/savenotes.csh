#!/bin/csh -f

#
# save note data before migration in case we have a problem
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

create table MGI_Note_save (
 	_Note_key                      int             not null,
 	_Object_key                    int             not null,
 	_MGIType_key                   int             not null,
 	_NoteType_key                  int             not null,
	_CreatedBy_key                 int             not null,
	_ModifiedBy_key                int             not null,
	creation_date                  datetime        not null,
	modification_date              datetime        not null 
)
go

create table MGI_NoteChunk_save (
 	_Note_key                      int             not null,
	sequenceNum                    int             not null,
	note                           char(255)       not null,
        _CreatedBy_key                 int             not null,
        _ModifiedBy_key                int             not null,
	creation_date                  datetime        not null,
	modification_date              datetime        not null 
)
go

truncate table MGI_Note_save
go
truncate table MGI_NoteChunk_save
go

insert into MGI_Note_save
select n.*
from VOC_Annot a, VOC_Evidence e, MGI_Note n
where a._AnnotType_key = 1000 
and a._Annot_key = e._Annot_key 
and e._AnnotEvidence_key = n._Object_key
go

insert into MGI_NoteChunk_save
select c.*
from VOC_Annot a, VOC_Evidence e, MGI_Note n, MGI_NoteChunk c
where a._AnnotType_key = 1000 
and a._Annot_key = e._Annot_key 
and e._AnnotEvidence_key = n._Object_key
and n._Note_key = c._Note_key
go

checkpoint
go

end

EOSQL

bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_Note_save
bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_NoteChunk_save

date |tee -a $LOG

