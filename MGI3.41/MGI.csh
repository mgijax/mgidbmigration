#!/bin/csh -fx

#
# Migration for 3.41 (TR 7119)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

date | tee -a  ${LOG}

########################################

# TR 6915

${newmgddbschema}/view/HMD_Summary_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/HMD_Summary_View_create.object | tee -a ${LOG}
${newmgddbperms}/public/view/HMD_Summary_View_grant.object | tee -a ${LOG}

${newmgddbschema}/index/MRK_Reference_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MRK_Reference_drop.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_Refs_drop.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

alter table MRK_Reference modify _Marker_key int not null
go

alter table MRK_Reference modify _Refs_key int not null
go

EOSQL

${newmgddbschema}/index/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbschema}/key/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbschema}/key/BIB_Refs_create.object | tee -a ${LOG}

# new radar TXT procedures

${newrdrdbschema}/procedure/TXT_drop.logical | tee -a ${LOG}
${newrdrdbschema}/procedure/TXT_create.logical | tee -a ${LOG}
${newrdrdbperms}/public/procedure/TXT_grant.logical | tee -a ${LOG}

date | tee -a  ${LOG}

