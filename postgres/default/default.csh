#!/bin/csh -fx

setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
source ${MGICONFIG}/master.config.csh

cd `dirname $0`

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

echo "--- default---"

cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

use ${MGD_DBNAME}
go

exec sp_unbindefault "PRB_Source.ageMin"
go

exec sp_unbindefault "PRB_Source.ageMax"
go

exec sp_unbindefault "ACC_Accession.preferred"
go

drop default ageminmax_default
go

drop default preferred
go

delete from MGI_UserRole where _Role_key = 6763217
go
delete from MGI_RoleTask where _Role_key = 6763217
go
delete from VOC_Term where _Term_key in (6763217, 6763218)
go

checkpoint
go

quit

EOSQL

date | tee -a ${LOG}
echo "--- default ---"
${MGD_DBSCHEMADIR}/default/view_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/view_create.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- procedure ---"
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

