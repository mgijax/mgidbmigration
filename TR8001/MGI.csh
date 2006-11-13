#!/bin/csh -fx

#
# Migration for TR78002
#

source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./tigr.csh | tee -a ${LOG}

########################################

date | tee -a  ${LOG}

