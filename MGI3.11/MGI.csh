#!/bin/csh -f

#
# Migration for MGI 3.11
#
# Defaults:       6
# Procedures:   113
# Rules:          5
# Triggers:     155
# User Tables:  186
# Views:        208

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
#load_db.csh ${DBSERVER} ${RADARDB} /shire/sybase/radar.backup

date | tee -a  ${LOG}

########################################

echo "Update MGI DB Info..." | tee -a  ${LOG}
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

# order is important!
./tr6351.py >>& ${LOG}
./deletesyns.py >>& ${LOG}
./markersynonym.csh | tee -a ${LOG}

${DBUTILSBINDIR}/dev/reconfig_mgd.csh ${newmgddb} | tee -a ${LOG}

${radardbschema}/table/DP_EntrezGene_Synonym_drop.object | tee -a ${LOG}
${radardbschema}/table/DP_EntrezGene_DBXRef_drop.object | tee -a ${LOG}

${radardbschema}/table/DP_EntrezGene_Synonym_create.object | tee -a ${LOG}
${radardbschema}/table/DP_EntrezGene_DBXRef_create.object | tee -a ${LOG}
${radardbschema}/table/WRK_EntrezGene_Synonym_create.object | tee -a ${LOG}

${radardbschema}/index/DP_EntrezGene_Synonym_create.object | tee -a ${LOG}
${radardbschema}/index/DP_EntrezGene_DBXRef_create.object | tee -a ${LOG}
${radardbschema}/index/WRK_EntrezGene_Synonym_create.object | tee -a ${LOG}

${radardbschema}/key/DP_EntrezGene_Info_drop.object | tee -a ${LOG}
${radardbschema}/key/DP_EntrezGene_Info_create.object | tee -a ${LOG}

${radardbperms}/public/table/DP_EntrezGene_Synonym_grant.object | tee -a ${LOG}
${radardbperms}/public/table/DP_EntrezGene_DBXRef_grant.object | tee -a ${LOG}
${radardbperms}/public/table/WRK_EntrezGene_Synonym_grant.object | tee -a ${LOG}

${EGLOADFILES} | tee -a ${LOG}
${EGLOADHUMAN} | tee -a ${LOG}
${EGLOADRAT} | tee -a ${LOG}

${MRKREFLOAD} | tee -a ${LOG}
${MRKLABELLOAD} | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

drop table MRK_Other
go

drop procedure MRK_insertOtherName
go

drop view MRK_Other_View
go

end

EOSQL

date | tee -a  ${LOG}
