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
values (15, 'GXD Index', 'GXD_Index', '_Index_key', null, getdate(), getdate(), getdate())
go

checkpoint
go

quit

EOSQL

date >> $LOG

