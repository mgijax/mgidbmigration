#!/bin/csh -f

#
# Migration for MGI Marker
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Marker Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename MRK_Marker, MRK_Marker_Old
go

sp_rename NOM_Marker, NOM_Marker_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/MRK_Marker_create.object >> ${LOG}
${newmgddbschema}/table/NOM_Marker_create.object >> ${LOG}
${newmgddbschema}/default/MRK_Marker_bind.object >> ${LOG}
${newmgddbschema}/default/NOM_Marker_bind.object >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

/* insert all markers into new table */

insert into MRK_Marker
select m._Marker_key, m._Species_key, m._Marker_Status_key, m._Marker_Type_key, 
m._CurationState_key, m.symbol, m.name, m.chromosome,
m.cytogeneticOffset, m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from MRK_Marker_Old m
go

insert into NOM_Marker
select m._Nomen_key, m._Marker_Type_key, m._NomenStatus_key, 
m._Marker_Event_key, m._Marker_EventReason_key, m._CurationState_key, 
m.symbol, m.name, m.chromosome, m.humanSymbol, m.statusNote, 
m.broadcast_date, m._BroadcastBy_key, m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from NOM_Marker_Old m
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/MRK_Marker_create.object >> ${LOG}
${newmgddbschema}/index/NOM_Marker_create.object >> ${LOG}

date >> ${LOG}

