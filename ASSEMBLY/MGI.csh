#!/bin/csh -f

#
# Migration for Assembly Coordinates
#
# Defaults:       6
# Procedures:   114
# Rules:          5
# Triggers:     156
# User Tables:  192
# Views:        198

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_dev1db.csh ${DBNAME} mgd_3.01.backup

date | tee -a  ${LOG}

########################################

echo "Update MGI DB Info..." | tee -a  ${LOG}
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

# order is important!
./loadVoc.csh | tee -a ${LOG}
./mgiassembly.csh | tee -a ${LOG}

${DBUTILSBINDIR}/dev/reconfig_mgd.csh ${newmgddb} | tee -a ${LOG}

${SEQMARKER} | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

exec SEQ_deriveRepAll
go

end

EOSQL

date | tee -a  ${LOG}
