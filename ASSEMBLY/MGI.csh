#!/bin/csh -f

#
# Migration for Assembly Coordinates
#
# Defaults:       6
# Procedures:   112
# Rules:          5
# Triggers:     156
# User Tables:  188
# Views:        205

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

date | tee -a  ${LOG}

########################################

echo "Update MGI DB Info..." | tee -a  ${LOG}
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

# order is important!
./loadVoc.csh | tee -a ${LOG}
./mgiassembly.csh | tee -a ${LOG}
./mlpstrain.csh | tee -a ${LOG}
./mgisynonym.csh | tee -a ${LOG}

${DBUTILSBINDIR}/dev/reconfig_mgd.csh ${newmgddb} | tee -a ${LOG}

${SEQMARKER} | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

drop procedure MRK_breakpointSplit
go

drop procedure PRB_mergeStandardTissue
go

drop procedure PRB_mergeTissue
go

exec MGI_Table_Column_Cleanup
go

end

EOSQL

date | tee -a  ${LOG}
