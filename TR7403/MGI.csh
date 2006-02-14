#!/bin/csh -fx

#
# Migration for TR 7403 (EI Release)
#
# Defaults:       6
# Procedures:   123
# Rules:          5
# Triggers:     158
# User Tables:  191
# Views:        230
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

date | tee -a  ${LOG}

########################################

./mgips.csh | tee -a ${LOG}
./mgistrain.csh | tee -a ${LOG}

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

date | tee -a  ${LOG}

