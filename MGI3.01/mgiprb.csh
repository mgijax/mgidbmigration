#!/bin/csh -f

#
# Migration for: PRB_Probe
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "PRB_Probe Migration..." | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename PRB_Probe, PRB_Probe_Old
go

sp_rename PRB_Reference, PRB_Reference_Old
go

end

EOSQL

#
# create new tables
#
${newmgddbschema}/table/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/table/PRB_Reference_create.object >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into PRB_Probe
select _Probe_key, name, derivedFrom, 
_Source_key, _Vector_key, _SegmentType_key,
primer1Sequence, primer2Sequence, regionCovered, insertSite, insertSize, productSize,
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from PRB_Probe_Old
go

insert into PRB_Reference
select _Reference_key, _Probe_key, _Refs_key, hasRmap, hasSequence, 
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from PRB_Reference_Old
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/partition/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/index/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/index/PRB_Reference_create.object >> ${LOG}

date >> ${LOG}

