#!/bin/csh -f

#
# Migration for MRK_History

cd `dirname $0` && source Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename MRK_History, MRK_History_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/MRK_History_create.object >> $LOG
${newmgddbschema}/default/MRK_History_bind.object >> $LOG
${newmgddbschema}/key/BIB_Refs_drop.object >> $LOG
${newmgddbschema}/key/BIB_Refs_create.object >> $LOG
${newmgddbschema}/key/MRK_Marker_drop.object >> $LOG
${newmgddbschema}/key/MRK_Marker_create.object >> $LOG
${newmgddbschema}/key/MRK_Event_drop.object >> $LOG
${newmgddbschema}/key/MRK_Event_create.object >> $LOG
${newmgddbschema}/key/MRK_EventReason_drop.object >> $LOG
${newmgddbschema}/key/MRK_EventReason_create.object >> $LOG
${newmgddbschema}/key/MRK_History_create.object >> $LOG
${newmgddbschema}/procedure/MRK_drop.logical >> $LOG
${newmgddbschema}/procedure/MRK_create.logical >> $LOG
${newmgddbschema}/view/MRK_History_Ref_View_drop.object >> $LOG
${newmgddbschema}/view/MRK_History_Ref_View_create.object >> $LOG
${newmgddbschema}/view/MRK_History_View_drop.object >> $LOG
${newmgddbschema}/view/MRK_History_View_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MRK_History
select _Marker_key, _Marker_Event_key, _Marker_EventReason_key, _History_key, _Refs_key, sequenceNum,
name, event_date, "mgd_dbo", "mgd_dbo", creation_date, modification_date
from MRK_History_Old
go

end

EOSQL

${newmgddbschema}/index/MRK_History_create.object >> $LOG
${newmgddbperms}/curatorial/procedure/MRK_grant.logical >> $LOG
${newmgddbperms}/public/procedure/MRK_grant.logical >> $LOG
${newmgddbperms}/public/view/MRK_History_Ref_View_grant.object >> $LOG
${newmgddbperms}/public/view/MRK_History_View_grant.object >> $LOG
${newmgddbperms}/curatorial/table/MRK_History_grant.object >> $LOG
${newmgddbperms}/public/table/MRK_History_grant.object >> $LOG

date >> $LOG

