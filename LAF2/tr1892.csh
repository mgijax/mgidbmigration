#!/bin/csh -f

#
# Migration for MRK_Label

cd `dirname $0` && source Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

drop table MRK_Label
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/MRK_Label_create.object >> $LOG
${newmgddbschema}/default/MRK_Label_bind.object >> $LOG
${newmgddbschema}/key/MRK_Marker_drop.object >> $LOG
${newmgddbschema}/key/MRK_Marker_create.object >> $LOG
${newmgddbschema}/key/MRK_Species_drop.object >> $LOG
${newmgddbschema}/key/MRK_Species_create.object >> $LOG
${newmgddbschema}/key/MRK_Status_drop.object >> $LOG
${newmgddbschema}/key/MRK_Status_create.object >> $LOG
${newmgddbschema}/key/MRK_Label_create.object >> $LOG

${LABELLOAD}/mrklabel.sh >> $LOG

${newmgddbschema}/procedure/MRK_reloadLabel_drop.object >> $LOG
${newmgddbschema}/procedure/MRK_reloadLabel_create.object >> $LOG
${newmgddbperms}/curatorial/procedure/MRK_reloadLabel_grant.object >> $LOG
${newmgddbperms}/public/table/MRK_Label_grant.object >> $LOG

date >> $LOG

