#!/bin/csh -f

#
# Migration for: Allele, Allele Pair
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Allele Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename ALL_Allele, ALL_Allele_Old
go

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go

end

EOSQL

${newmgddbschema}/table/ALL_Allele_create.object | tee -a ${LOG}
${newmgddbschema}/default/ALL_Allele_bind.object | tee -a ${LOG}

${newmgddbschema}/table/GXD_AllelePair_create.object | tee -a ${LOG}
${newmgddbschema}/default/GXD_AllelePair_bind.object | tee -a ${LOG}

# keys/permissions will be handled in reconfig phase 

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into ALL_Allele
select o._Allele_key, o._Marker_key, o._Strain_key, o._Mode_key, o._Allele_Type_key,
o._CellLine_key, o._Allele_Status_key, o.symbol, o.name, o.nomenSymbol, 0,
o._CreatedBy_key, o._ModifiedBy_key, o._ApprovedBy_key, o.approval_date,
o.creation_date, o.modification_date
from ALL_Allele_Old o
where o.symbol not like '%<+>'
go

insert into ALL_Allele
select o._Allele_key, o._Marker_key, o._Strain_key, o._Mode_key, o._Allele_Type_key,
o._CellLine_key, o._Allele_Status_key, o.symbol, o.name, o.nomenSymbol, 1,
o._CreatedBy_key, o._ModifiedBy_key, o._ApprovedBy_key, o.approval_date,
o.creation_date, o.modification_date
from ALL_Allele_Old o
where o.symbol like '%<+>'
go

end

EOSQL

${newmgddbschema}/index/ALL_Allele_create.object | tee -a ${LOG}
${newmgddbschema}/index/GXD_AllelePair_create.object | tee -a ${LOG}

date >> ${LOG}

