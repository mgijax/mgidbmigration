#!/bin/csh -f

#
# Migration for: MLC (TR 6583)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'MLC Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename MLC_Text, MLC_Text_Old
go

end

EOSQL

${newmgddbschema}/table/MLC_Text_create.object | tee -a ${LOG}
${newmgddbschema}/key/MLC_Text_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLC_Text_create.object | tee -a ${LOG}
${newmgddbschema}/default/MLC_Text_bind.object | tee -a ${LOG}
${newmgddbschema}/trigger/MLC_Text_create.object | tee -a ${LOG}

${newmgddbschema}/key/MRK_Marker_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MRK_Marker_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/MRK_Marker_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/MRK_Marker_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_updateKeys_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_updateKeys_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_deletePrivateData_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_deletePrivateData_create.object | tee -a ${LOG}

${newmgddbperms}/public/table/MLC_Text_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/MRK_updateKeys_grant.object | tee -a ${LOG}

${newmgddbperms}/curatorial/table/MLC_revoke.logical | tee -a ${LOG}
${newmgddbperms}/curatorial/table/MLC_grant.logical | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into MLC_Text
select o._Marker_key, o.mode, o.description, o.userID, 0, o.creation_date, o.modification_date
from MLC_Text_Old o
go

drop table MLC_Text_Old
go

end

EOSQL

date >> ${LOG}

