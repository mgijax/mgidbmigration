#!/bin/sh

#
# cleanup for postgres migration
#

cd `dirname $0` && . ../Configuration

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} $0

delete from radar.APP_FilesProcessed a
where not exists (select 1 from radar.APP_FilesMirrored b where a._File_key = b._File_key)
;

EOSQL

date |tee -a $LOG
