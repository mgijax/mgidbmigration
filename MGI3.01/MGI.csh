#!/bin/csh -f

#
# Migration for MGI 3.01
#
# updated:  
# Defaults:	  6
# Procedures:	111
# Rules:	  5
# Triggers:	154
# User Tables:	191
# Views:	197
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
#load_dev1db.csh ${DBNAME} mgd.backup

date | tee -a  ${LOG}

########################################

echo "Update MGI DB Info..." | tee -a  ${LOG}
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

# order is important!
./mgidataset.csh | tee -a ${LOG}
./mgiset.csh | tee -a ${LOG}
./mgiallele.csh | tee -a ${LOG}
./mgiprb.csh | tee -a ${LOG}
./mgigxd.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

select p._Probe_key, p.name, p.repeatUnit
from PRB_Probe_Old p, VOC_Term v
where p._SegmentType_key = v._Term_key
and v.term = "primer"
and p.repeatUnit is not null
go

select p._Probe_key, p.name, p.moreProduct
from PRB_Probe_Old p, VOC_Term v
where p._SegmentType_key = v._Term_key
and v.term = "primer"
and p.moreProduct = 1
go

drop table BIB_Refs_Old
go

drop table PRB_Probe_Old
go

drop table PRB_Reference_Old
go

drop table IMG_ImagePane_Old
go

drop table ALL_Type_Old
go

drop table MGI_Set_Old
go

exec MGI_Table_Column_Cleanup
go

end

EOSQL

${newmgddbperms}/developers/procedure/perm_grant.csh | tee -a ${LOG}
${newmgddbperms}/developers/table/perm_grant.csh | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/perm_grant.csh | tee -a ${LOG}
${newmgddbperms}/curatorial/table/perm_grant.csh | tee -a ${LOG}
${newmgddbperms}/public/table/perm_grant.csh | tee -a ${LOG}
${newmgddbperms}/public/view/perm_grant.csh | tee -a ${LOG}

date | tee -a  ${LOG}
