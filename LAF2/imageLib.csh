#!/bin/csh -f

#
# Load IMAGE libraries
#

cd `dirname $0` && source Configuration

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

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

update PRB_Source
set name = t.goodName, modification_date = getdate()
from PRB_Source s, tempdb..MGI_Translation t
where s.name = t.badName
go

checkpoint
go

quit

EOSQL

${LIBLOAD}/libraryload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} -Mfull -IIMAGE.in.lib

date >> $LOG
