#!/bin/csh -f

#
# Load IMAGE libraries
#

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use tempdb
go

drop table MGI_Translation
go

create table MGI_Translation (
	field1	char(1)	null,
        badName varchar(255) null,
        goodName varchar(255) null,
	field4  char(20) not null
)
go

quit

EOSQL

cat $DBPASSWORDFILE | bcp tempdb..MGI_Translation in imagelib.badgood.trans -c -t"\t" -S$DBSERVER -U$DBUSER >>& $LOG

exit 0

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

update PRB_Source
set name = t.badName, modification_date = getdate()
from PRB_Source s, tempdb..MGI_Translation t
where s.name = t.goodName
and t.badName is not null
go

checkpoint
go

quit

EOSQL

libraryload.py -SDEV_MGI -Dmgd_release -Umgd_dbo -P/usr/local/mgi/dbutils/mgidbutilities/.mgd_dbo_password -Mfull -IIMAGE.in.lib

date >> $LOG
