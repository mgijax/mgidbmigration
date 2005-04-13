#!/bin/csh -f

#
# Migration for: Allele
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

sp_rename ALL_CellLine, ALL_CellLine_Old
go

end

EOSQL

${newmgddbschema}/table/ALL_Allele_create.object | tee -a ${LOG}
${newmgddbschema}/default/ALL_Allele_bind.object | tee -a ${LOG}

${newmgddbschema}/table/ALL_Label_create.object | tee -a ${LOG}
${newmgddbschema}/default/ALL_Label_bind.object | tee -a ${LOG}

${newmgddbschema}/table/ALL_CellLine_create.object | tee -a ${LOG}
${newmgddbschema}/default/ALL_CellLine_bind.object | tee -a ${LOG}

# keys/permissions will be handled in reconfig phase 

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

insert into ALL_Allele
select o._Allele_key, o._Marker_key, o._Strain_key, o._Mode_key, o._Allele_Type_key,
o._Allele_Status_key, o._CellLine_key, -2, o.symbol, o.name, o.nomenSymbol, 0,
o._CreatedBy_key, o._ModifiedBy_key, o._ApprovedBy_key, o.approval_date,
o.creation_date, o.modification_date
from ALL_Allele_Old o
where o.symbol not like '%<+>'
go

insert into ALL_Allele
select o._Allele_key, o._Marker_key, o._Strain_key, o._Mode_key, o._Allele_Type_key,
o._Allele_Status_key, o._CellLine_key, -2, o.symbol, o.name, o.nomenSymbol, 1,
o._CreatedBy_key, o._ModifiedBy_key, o._ApprovedBy_key, o.approval_date,
o.creation_date, o.modification_date
from ALL_Allele_Old o
where o.symbol like '%<+>'
go

update ALL_Allele
set _MutantESCellLine_key = -1
from ALL_Allele a, VOC_Term t
where a._Allele_Type_key = t._Term_key
and t.term = 'Gene trapped'
go

insert into ALL_CellLine
select o._CellLine_key, o.cellLine, o._Strain_key, null, 0, ${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from ALL_CellLine_Old o
go

declare @mgiKey integer
select @mgiKey = max(_MGIType_key + 1) from ACC_MGIType

insert into ACC_MGIType values(@mgiKey, 'ES Cell Line', 'ALL_CellLine', '_CellLine_key', null, null, 
	${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

end

EOSQL

${newmgddbschema}/index/ALL_Allele_create.object | tee -a ${LOG}
${newmgddbschema}/index/ALL_Label_create.object | tee -a ${LOG}
${newmgddbschema}/index/ALL_CellLine_create.object | tee -a ${LOG}

date >> ${LOG}

