#!/bin/csh -fx

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.42" | tee -a ${LOG}
#${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-4-2-1" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

sp_rename IMG_ImagePane, IMG_ImagePane_Old
go

EOSQL

date | tee -a ${LOG}
echo "---  add new table ---"
${MGD_DBSCHEMADIR}/table/IMG_ImagePane_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into IMG_ImagePane
select _ImagePane_key, _Image_key, paneLabel, null, null, null, null,
creation_date, modification_date
from IMG_ImagePane_Old
go

EOSQL

date | tee -a ${LOG}
echo "---  add new table ---"
${MGD_DBSCHEMADIR}/index/IMG_ImagePane_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/IMG_Image_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/IMG_ImagePane_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/IMG_Image_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/IMG_ImagePane_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/IMG_ImagePane_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_loadCacheByAssay_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/IMG_setPDO_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/IMG_setPDO_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePane_Assoc_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePane_Assoc_View_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePaneGXD_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/IMG_ImagePaneGXD_View_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

