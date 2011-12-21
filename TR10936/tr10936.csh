#!/bin/csh

#
# TR10936
#
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go


/* create new reference types */

declare @nextType integer
select @nextType = max(_RefAssocType_key) + 1 from MGI_RefAssocType

insert MGI_RefAssocType (_RefAssocType_key, _MGIType_key, assocType, allowOnlyOne)
values (@nextType, 11, "Treatment", 0)

go

quit

EOSQL

${MGD_DBSCHEMADIR}/procedure/MGI_updateReferenceAssoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_updateReferenceAssoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a  ${LOG}

