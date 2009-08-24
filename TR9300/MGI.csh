#!/bin/csh -fx

#
# Migration for TR9300
#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

# update schema tag
${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

./mgigxd.csh | tee -a ${LOG}

########################################

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

--drop table GXD_Index_Old
--go

exec MGI_Table_Column_Cleanup
go

quit

EOSQL

date | tee -a  ${LOG}

