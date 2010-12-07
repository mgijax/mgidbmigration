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

checkpoint
go

end

EOSQL

date |tee -a $LOG

