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

sp_rename ACC_MGIType, ACC_MGIType_Old
go

quit

EOSQL

${newmgddbschema}/table/ACC_MGIType_create.object >> $LOG
${newmgddbschema}/default/ACC_MGIType_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_MGIType
select o._MGIType_key, o.name, o.tableName, o.primaryKeyName, null, o.dbView,
o.creation_date, o.modification_date, o.release_date
from ACC_MGIType_Old o
go

update ACC_MGIType set identityColumnName = 'name' where name = 'Actual DB'
update ACC_MGIType set identityColumnName = 'symbol' where name = 'Allele'
update ACC_MGIType set identityColumnName = 'antibodyName' where name = 'Antibody'
update ACC_MGIType set identityColumnName = 'antigenName' where name = 'Antigen'
update ACC_MGIType set identityColumnName = 'name' where name = 'Logical DB'
update ACC_MGIType set identityColumnName = 'symbol' where name = 'Marker'
update ACC_MGIType set identityColumnName = 'strain' where name = 'Strain'
update ACC_MGIType set identityColumnName = 'tissue' where name = 'Tissue'
update ACC_MGIType set identityColumnName = 'name' where name = 'Segment'
update ACC_MGIType set identityColumnName = 'name' where name = 'Source'
update ACC_MGIType set identityColumnName = 'name' where name = 'Vocabulary'
update ACC_MGIType set identityColumnName = 'term' where name = 'Vocabulary Term'
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_MGIType 
values (17, 'GXD Index', 'GXD_Index', '_Index_key', null, null, getdate(), getdate(), getdate())
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

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MLC_Lock_create.object
${newmgddbschema}/index/ACC_MGIType_create.object >> $LOG


date >> $LOG

