#!/bin/csh -f

#
# Migration for MRK_Reference to MGI_Reference_Assoc
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "Marker Reference Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

select r._Marker_key, r._Refs_key, seq = identity(5), r.creation_date, r.modification_date
into #refs
from MRK_Reference r
where r.auto = 0
go

declare @maxKey integer
select @maxKey = max(_Assoc_key) from MGI_Reference_Assoc

declare @reftypeKey integer
select @reftypeKey = max(_RefAssocType_key) + 1 from MGI_RefAssocType

insert into MGI_RefAssocType values(@refTypeKey, 2, 'General', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())

insert into MGI_Reference_Assoc
select seq + @maxKey, _Refs_key, _Marker_key, 2, refsTypeKey, '${CREATEDBY}', '${CREATEDBY}', creation_date, modification_date
from #refs
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/table/MRK_Reference_drop.object | tee -a ${LOG}
${newmgddbschema}/table/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbschema}/default/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbschema}/key/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/MRK_Reference_grant.object | tee -a ${LOG}

${MRKREFLOAD}/mrkrefload.sh | tee -a ${LOG}

date | tee -a $LOG

