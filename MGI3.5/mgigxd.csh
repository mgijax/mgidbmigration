#!/bin/csh -fx

#
# TR 7598/add created by/modified by to GXD_Antigen, GXD_Antibody
#

source ./Configuration

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename GXD_Antigen, GXD_Antigen_Old
go

sp_rename GXD_Antibody, GXD_Antibody_Old
go

quit

EOSQL

${newmgddbschema}/table/GXD_Antigen_create.object | tee -a ${LOG}
${newmgddbschema}/default/GXD_Antigen_bind.object | tee -a ${LOG}
${newmgddbschema}/key/GXD_Antigen_create.object | tee -a ${LOG}
${newmgddbschema}/table/GXD_Antibody_create.object | tee -a ${LOG}
${newmgddbschema}/default/GXD_Antibody_bind.object | tee -a ${LOG}
${newmgddbschema}/key/GXD_Antibody_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into GXD_Antigen
select _Antigen_key, _Source_key, antigenName, regionCovered, antigenNote,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from GXD_Antigen_Old
go

insert into GXD_Antibody
select _Antibody_key, _Refs_key, _AntibodyClass_key, _AntibodyType_key, _Organism_key,
_Antigen_key, antibodyName, antibodyNote, recogWestern, recogImmunPrecip, recogNote,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from GXD_Antibody_Old
go

quit

EOSQL

${newmgddbschema}/index/GXD_Antigen_create.object | tee -a ${LOG}
${newmgddbschema}/index/GXD_Antibody_create.object | tee -a ${LOG}

date | tee -a ${LOG}

