#!/bin/csh -f

#
# New values for ACC_MGIType
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_MGIType 
values (17, 'GXD Index', 'GXD_Index', '_Index_key', null, getdate(), getdate(), getdate())
go

sp_rename MLC_Lock_edit, MLC_Lock
go

drop index MLC_Lock.index_Marker_time
go

drop index MLC_Lock.index_time
go

drop index MLC_Lock.index_modification_date
go

drop index MLC_Lock.index_Marker_key
go

drop procedure MLC_transfer
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MLC_Lock_create.object

date >> $LOG

