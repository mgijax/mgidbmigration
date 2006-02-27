#!/bin/csh -fx

cd `dirname $0` && source ./Configuration

source ${newmgddbschema}/Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename MGI_Tables, MGI_Tables_Old
go

quit

EOSQL

${newmgddbschema}/table/MGI_Tables_drop.object | tee -a ${LOG}
${newmgddbschema}/table/MGI_Tables_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_Table_Column_Cleanup_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_Table_Column_Cleanup_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into MGI_Tables select table_name, description, null, null, creation_date, modification_date
from MGI_Tables_Old
go

drop table MGI_Tables_Old
go

quit

EOSQL

date | tee -a  ${LOG}

