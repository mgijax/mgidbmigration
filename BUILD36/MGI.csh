#!/bin/csh -f

#
# Migration for Build 36
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup
#load_db.csh ${RADAR_DBSERVER} ${RADARDB_DBNAME} /shire/sybase/radar.backup

########################################

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* Add "VEGA Gene Model" term to the Sequence Provider vocab */

update VOC_Term set sequenceNum = sequenceNum + 1
from VOC_Term
where _Vocab_key = 25
and sequenceNum >= 11
go

declare @termKey int
select @termKey = max(_Term_key) + 1 from VOC_Term
insert into VOC_Term values (@termKey, 25, "VEGA Gene Model", "VEGA Gene Model", 11, 0, 1001, 1001, getdate(), getdate())
go

/* Add "VEGA Gene Model" URL to the Actual DB "set" */

declare @memberKey int
select @memberKey = max(_SetMember_key) + 1 from MGI_SetMember
insert into MGI_SetMember values (@memberKey, 1009, 82, 15, 1001, 1001, getdate(), getdate())
go

EOSQL

# snp stuff
#./snp.csh 

# MRK_Location_Cache

${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/MRK_Location_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Location_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/MRK_Location_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/table/MRK_Location_Cache_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/table/MRK_Location_Cache_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/procedure/MRK_reloadLocation_grant.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/procedure/MRK_reloadLocation_grant.object | tee -a ${LOG}
${DBUTILS}/mrkcacheload/mrklocation.csh | tee -a ${LOG}

date | tee -a  ${LOG}

