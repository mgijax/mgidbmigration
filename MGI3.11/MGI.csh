#!/bin/csh -f

#
# Migration for MGI 3.11
#
# Defaults:       6
# Procedures:   113
# Rules:          5
# Triggers:     155
# User Tables:  186
# Views:        209

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
./tr6351.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -P${DBPASSWORDFILE} | tee -a ${LOG}
./markersynonym.csh | tee -a ${LOG}

${DBUTILSBINDIR}/dev/reconfig_mgd.csh ${newmgddb} | tee -a ${LOG}

${MRKREFLOAD | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

drop table MRK_Other
go

end

EOSQL

date | tee -a  ${LOG}
