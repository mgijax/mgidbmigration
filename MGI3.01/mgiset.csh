#!/bin/csh -f

#
# Migration for: Alleles (TR 5750)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Set Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename MGI_Set, MGI_Set_Old
go

end

EOSQL

${newmgddbschema}/table/MGI_Set_create.object | tee -a ${LOG}
${newmgddbschema}/index/MGI_Set_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into MGI_Set
select o._Set_key, o._MGIType_key, o.name, 1, 
o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from MGI_Set_Old o
go

update MGI_Set set sequenceNum = 2 where _Set_key = 1004
update MGI_Set set sequenceNum = 3 where _Set_key = 1005
update MGI_Set set sequenceNum = 4 where _Set_key = 1006
update MGI_Set set sequenceNum = 5 where _Set_key = 1007
update MGI_Set set sequenceNum = 6 where _Set_key = 1008
go

end

EOSQL

date >> ${LOG}

