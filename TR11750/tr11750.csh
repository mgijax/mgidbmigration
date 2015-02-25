#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
       setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

# COMMENT OUT BEFORE RUNNING ON PRODUCTION
# ${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd_dog.backup

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

-- obsolete
drop view MLC_Marker_View
go

drop trigger MLC_Text_Delete
go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG

-- GXD_Expression
${MGD_DBSCHEMADIR}/table/GXD_Expression_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/default/GXD_Expression_bind.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGICACHELOAD}/gxdexpression.csh | tee -a ${LOG}

date | tee -a ${LOG}

