#!/bin/csh -f

#
# at some point, we may run out of the ability to create more /data/pixeldb nodes
# if so, use the same techique as littriageload, and store pixeldb ids in sets of 1000
#
# 1. Migrate /data/pixeldb to basepath = int(nextPixKey / 1000) * 1000
#	from /data/pixeldb to /data/pixeldb/1000, 2000, etc.
#
# 2. mgd_java_api/src/main/java/org/jax/mgi/mgd/api/model/img/service/ImageSubmissionService.java/submit
#
# 3. pgmgddbschema/procedure/IMG_setPDO_create.object
#
# 4. fewi, fedatamodel, webshare (config/GlobalConfig), etc.
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

EOSQL

date |tee -a $LOG

