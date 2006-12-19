#!/bin/csh -fx

#
# Migration for TR7683
#
# Defaults:       6
# Procedures:   108
# Rules:          5
# Triggers:     158
# User Tables:  187
# Views:        213
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

# update schema tag
${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 3.52" | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "mgddbschema-3-5-2" | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./cache.csh | tee -a ${LOG}
./tigr.csh | tee -a ${LOG}
./alleletype.csh | tee -a ${LOG}
./dag.csh | tee -a ${LOG}

########################################

${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

${VOCLOAD}/runOBOIncLoad.sh ${VOCLOAD}/GO.config

# these need to be done after the java libraries are installed

${TREEFAMLOAD}/treefam.sh | tee -a ${LOG}
${PIRSFLOAD}/bin/pirsfload.sh | tee -a ${LOG}
${MRKCACHELOAD}/mrkreference.csh | tee -a ${LOG}

date | tee -a  ${LOG}

