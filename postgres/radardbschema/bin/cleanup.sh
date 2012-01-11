#!/bin/sh

#
# cleanup for postgres migration
#
# some of the children contain geneid = '-' which do *not*
# exist in the parent (DP_EntrezGene_Info)
#  DP_EntrezGene_History
#  DP_EntrezGene_MIM
#
#

cd `dirname $0` && . ../Configuration

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} $0

delete from radar.APP_FilesProcessed a
where not exists (select 1 from radar.APP_FilesMirrored b where a._File_key = b._File_key)
;

delete from radar.DP_EntrezGene_History a
where not exists (select 1 from radar.DP_EntrezGene_Info b where a.geneid = b.geneid)
;

delete from radar.DP_EntrezGene_MIM a
where not exists (select 1 from radar.DP_EntrezGene_Info b where a.geneid = b.geneid)
;

delete from radar.DP_HomoloGene a
where not exists (select 1 from radar.DP_EntrezGene_Info b where a.geneid = b.geneid)
;

EOSQL

date |tee -a $LOG
