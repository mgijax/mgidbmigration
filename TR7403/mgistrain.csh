#!/bin/csh -f

#
# TR 7153/Strain
#
# Usage:  mgistrain.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename PRB_Strain, PRB_Strain_Old
go

quit

EOSQL

${newmgddbschema}/table/PRB_Strain_create.object | tee -a ${LOG}
${newmgddbschema}/default/PRB_Strain_bind.object | tee -a ${LOG}
${newmgddbschema}/key/PRB_Strain_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into PRB_Strain
select o._Strain_key, o._Species_key, o.strain, o.standard, o.needsReview, o.private, 0,
o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from PRB_Strain_Old o
go

update PRB_Strain
set imsrOK = 1
from PRB_Strain s, MGI_Note_Strain_View n
where n.note = "okay for imsr"
and n._Object_key = s._Strain_key
go

quit

EOSQL

#
# add indexes
#

${newmgddbschema}/index/PRB_Strain_create.object | tee -a ${LOG}

date >> ${LOG}

